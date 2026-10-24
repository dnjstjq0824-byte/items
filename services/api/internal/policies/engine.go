package policies

import (
	"context"
	"fmt"
	"sync"

	"github.com/bookingnetwork/bn-gameex/services/api/internal/domain"
	"github.com/google/uuid"
)

// PolicyEngine enforces Article 3 Global Product Policy & Legal Gate
type PolicyEngine struct {
	mu       sync.RWMutex
	policies map[string]*domain.GameTradePolicy
}

func NewPolicyEngine() *PolicyEngine {
	return &PolicyEngine{
		policies: make(map[string]*domain.GameTradePolicy),
	}
}

func policyKey(gameID uuid.UUID, countryCode, productType string) string {
	return fmt.Sprintf("%s:%s:%s", gameID.String(), countryCode, productType)
}

// RegisterPolicy registers a policy into the engine
func (e *PolicyEngine) RegisterPolicy(policy *domain.GameTradePolicy) {
	e.mu.Lock()
	defer e.mu.Unlock()
	key := policyKey(policy.GameID, policy.CountryCode, policy.ProductType)
	e.policies[key] = policy
}

// ValidateTrade evaluates whether a trade is permitted under the multi-gate compliance model
func (e *PolicyEngine) ValidateTrade(ctx context.Context, gameID uuid.UUID, countryCode, productType string) error {
	// Article 3.4 Absolute Prohibition: Game Account trading is unconditionally disabled in v1.0
	if productType == domain.ProductTypeGameAccount {
		return domain.ErrAccountTradeProhibited
	}

	e.mu.RLock()
	defer e.mu.RUnlock()

	key := policyKey(gameID, countryCode, productType)
	policy, exists := e.policies[key]
	if !exists {
		return fmt.Errorf("%w: no policy defined for game %s, country %s, type %s (status: REVIEW_REQUIRED)",
			domain.ErrPolicyProhibited, gameID, countryCode, productType)
	}

	if !policy.TradeEnabled {
		return fmt.Errorf("%w: trade not enabled (legal: %s, publisher: %s, psp: %s)",
			domain.ErrPolicyProhibited, policy.LegalReviewStatus, policy.PublisherPolicyStatus, policy.PaymentPartnerStatus)
	}

	if policy.LegalReviewStatus != "APPROVED" || policy.PublisherPolicyStatus != "PERMITTED" || policy.PaymentPartnerStatus != "APPROVED" {
		return fmt.Errorf("%w: compliance gate incomplete (legal: %s, publisher: %s, psp: %s)",
			domain.ErrPolicyProhibited, policy.LegalReviewStatus, policy.PublisherPolicyStatus, policy.PaymentPartnerStatus)
	}

	return nil
}
