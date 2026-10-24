package ledger

import (
	"context"
	"fmt"
	"sync"
	"time"

	"github.com/bookingnetwork/bn-gameex/services/api/internal/domain"
	"github.com/google/uuid"
)

// Service provides strict double-entry ledger management per Article 16.6
type Service struct {
	mu           sync.RWMutex
	accounts     map[uuid.UUID]*domain.LedgerAccount
	transactions map[uuid.UUID]*domain.LedgerTransaction
}

func NewService() *Service {
	return &Service{
		accounts:     make(map[uuid.UUID]*domain.LedgerAccount),
		transactions: make(map[uuid.UUID]*domain.LedgerTransaction),
	}
}

func (s *Service) RegisterAccount(account *domain.LedgerAccount) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.accounts[account.ID] = account
}

// PostTransaction records a balanced multi-entry transaction
func (s *Service) PostTransaction(ctx context.Context, refType string, refID uuid.UUID, entries []domain.LedgerEntry) (*domain.LedgerTransaction, error) {
	s.mu.Lock()
	defer s.mu.Unlock()

	if len(entries) < 2 {
		return nil, fmt.Errorf("%w: at least two entries required for double-entry ledger", domain.ErrLedgerUnbalanced)
	}

	// Validate currency uniformity & balance invariant: sum(debits) == sum(credits)
	var totalDebits int64
	var totalCredits int64
	currency := entries[0].CurrencyCode

	for _, entry := range entries {
		if entry.CurrencyCode != currency {
			return nil, fmt.Errorf("%w: mixed currencies in single transaction (%s != %s)", domain.ErrLedgerUnbalanced, entry.CurrencyCode, currency)
		}
		if entry.DebitMinor < 0 || entry.CreditMinor < 0 {
			return nil, fmt.Errorf("negative amount forbidden in ledger entry")
		}
		if entry.DebitMinor > 0 && entry.CreditMinor > 0 {
			return nil, fmt.Errorf("single entry cannot have both debit and credit")
		}
		if entry.DebitMinor == 0 && entry.CreditMinor == 0 {
			return nil, fmt.Errorf("entry must have a non-zero debit or credit")
		}

		totalDebits += entry.DebitMinor
		totalCredits += entry.CreditMinor
	}

	if totalDebits != totalCredits {
		return nil, fmt.Errorf("%w: total debits (%d) != total credits (%d)", domain.ErrLedgerUnbalanced, totalDebits, totalCredits)
	}

	txID := uuid.New()
	tx := &domain.LedgerTransaction{
		ID:            txID,
		ReferenceType: refType,
		ReferenceID:   refID,
		Status:        "POSTED",
		Entries:       make([]domain.LedgerEntry, len(entries)),
		CreatedAt:     time.Now(),
	}

	for i, e := range entries {
		e.ID = uuid.New()
		e.LedgerTransactionID = txID
		e.CreatedAt = time.Now()
		tx.Entries[i] = e
	}

	s.transactions[txID] = tx
	return tx, nil
}

// RecordPaymentCapture records double-entry booking upon verified payment capture:
// Debit: PSP Clearing (Total Buyer Paid = Subtotal + BuyerFee)
// Credit: Seller Payable (Net Seller Receives = Subtotal - SellerFee)
// Credit: Platform Fee Revenue (Marketplace Commission = BuyerFee + SellerFee)
func (s *Service) RecordPaymentCapture(
	ctx context.Context,
	orderID uuid.UUID,
	pspAccountID, sellerPayableAccountID, feeRevenueAccountID uuid.UUID,
	subtotalMinor, buyerFeeMinor, sellerFeeMinor int64,
	currency string,
) (*domain.LedgerTransaction, error) {
	totalBuyerPaid := subtotalMinor + buyerFeeMinor
	netSellerPayable := subtotalMinor - sellerFeeMinor
	totalPlatformFee := buyerFeeMinor + sellerFeeMinor

	entries := []domain.LedgerEntry{
		{
			LedgerAccountID: pspAccountID,
			DebitMinor:      totalBuyerPaid,
			CreditMinor:     0,
			CurrencyCode:    currency,
		},
		{
			LedgerAccountID: sellerPayableAccountID,
			DebitMinor:      0,
			CreditMinor:     netSellerPayable,
			CurrencyCode:    currency,
		},
		{
			LedgerAccountID: feeRevenueAccountID,
			DebitMinor:      0,
			CreditMinor:     totalPlatformFee,
			CurrencyCode:    currency,
		},
	}

	return s.PostTransaction(ctx, "ORDER_PAYMENT", orderID, entries)
}

func (s *Service) GetTransaction(id uuid.UUID) (*domain.LedgerTransaction, error) {
	s.mu.RLock()
	defer s.mu.RUnlock()
	tx, exists := s.transactions[id]
	if !exists {
		return nil, domain.ErrNotFound
	}
	return tx, nil
}

