package disputes

import (
	"context"
	"fmt"
	"sync"
	"time"

	"github.com/bookingnetwork/bn-gameex/services/api/internal/domain"
	"github.com/bookingnetwork/bn-gameex/services/api/internal/orders"
	"github.com/google/uuid"
)

type Service struct {
	mu           sync.Mutex
	orderService *orders.Service
	disputes     map[uuid.UUID]*domain.Dispute
	decisions    map[uuid.UUID]*domain.DisputeDecision
	evidences    map[uuid.UUID][]domain.DisputeEvidence
}

func NewService(orderService *orders.Service) *Service {
	return &Service{
		orderService: orderService,
		disputes:     make(map[uuid.UUID]*domain.Dispute),
		decisions:    make(map[uuid.UUID]*domain.DisputeDecision),
		evidences:    make(map[uuid.UUID][]domain.DisputeEvidence),
	}
}

// OpenDispute halts normal progression and marks order disputed (Article 18)
func (s *Service) OpenDispute(ctx context.Context, orderID, userID uuid.UUID, reasonCode, description string) (*domain.Dispute, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	order, err := s.orderService.GetOrder(orderID)
	if err != nil {
		return nil, err
	}

	if order.BuyerUserID != userID && order.SellerID != userID {
		return nil, domain.ErrForbidden
	}

	disputeID := uuid.New()
	dispute := &domain.Dispute{
		ID:             disputeID,
		OrderID:        orderID,
		OpenedByUserID: userID,
		ReasonCode:     reasonCode,
		Description:    description,
		Status:         "OPEN",
		OpenedAt:       time.Now(),
	}

	s.disputes[disputeID] = dispute

	// Transition order to DISPUTED
	actor := "BUYER"
	if order.SellerID == userID {
		actor = "SELLER"
	}
	if err := s.orderService.TransitionOrder(ctx, orderID, domain.OrderStatusDisputed, actor, &userID, fmt.Sprintf("Dispute opened: %s", reasonCode)); err != nil {
		return nil, err
	}

	return dispute, nil
}

// DecideDispute registers an adjudicating decision.
// Enforces Dual-Approval (Article 29): Refunds require secondary approval before execution.
func (s *Service) DecideDispute(ctx context.Context, disputeID uuid.UUID, decisionCode, reason string, deciderID uuid.UUID) (*domain.DisputeDecision, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	dispute, exists := s.disputes[disputeID]
	if !exists {
		return nil, domain.ErrNotFound
	}

	decisionID := uuid.New()
	needsDualApproval := decisionCode == "BUYER_FAVOR_FULL_REFUND" || decisionCode == "BUYER_FAVOR_PARTIAL_REFUND"

	approvalStatus := "APPROVED"
	if needsDualApproval {
		approvalStatus = "PENDING_APPROVAL" // 4-Eyes rule (Article 29)
	}

	decision := &domain.DisputeDecision{
		ID:             decisionID,
		DisputeID:      disputeID,
		DecisionCode:   decisionCode,
		DecisionReason: reason,
		DecidedBy:      deciderID,
		ApprovalStatus: approvalStatus,
		CreatedAt:      time.Now(),
	}

	s.decisions[decisionID] = decision

	if !needsDualApproval {
		now := time.Now()
		dispute.Status = "DECIDED"
		dispute.ResolvedAt = &now
		if decisionCode == "SELLER_FAVOR_COMPLETE_ORDER" {
			_ = s.orderService.TransitionOrder(ctx, dispute.OrderID, domain.OrderStatusCompleted, "ADMIN", &deciderID, "Dispute decided in seller favor")
		}
	}

	return decision, nil
}

// ApproveDisputeDecision executes the dual-approval for refund-related dispute decisions
func (s *Service) ApproveDisputeDecision(ctx context.Context, decisionID, approverID uuid.UUID) error {
	s.mu.Lock()
	defer s.mu.Unlock()

	decision, exists := s.decisions[decisionID]
	if !exists {
		return domain.ErrNotFound
	}

	if decision.DecidedBy == approverID {
		return fmt.Errorf("segregation of duties violation: approver cannot be the same as decider (Article 29)")
	}

	decision.ApprovalStatus = "APPROVED"
	decision.ApprovedBy = &approverID

	dispute := s.disputes[decision.DisputeID]
	now := time.Now()
	dispute.Status = "DECIDED"
	dispute.ResolvedAt = &now

	if decision.DecisionCode == "BUYER_FAVOR_FULL_REFUND" {
		_ = s.orderService.TransitionOrder(ctx, dispute.OrderID, domain.OrderStatusRefundPending, "ADMIN", &approverID, "Dual-approved dispute full refund")
	}

	return nil
}

