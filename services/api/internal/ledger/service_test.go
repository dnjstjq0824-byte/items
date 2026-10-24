package ledger_test

import (
	"context"
	"testing"

	"github.com/bookingnetwork/bn-gameex/services/api/internal/domain"
	"github.com/bookingnetwork/bn-gameex/services/api/internal/ledger"
	"github.com/google/uuid"
)

func TestLedgerService_DoubleEntryBalanceInvariants(t *testing.T) {
	svc := ledger.NewService()
	ctx := context.Background()

	pspAccID := uuid.New()
	sellerPayableAccID := uuid.New()
	feeRevenueAccID := uuid.New()

	orderID := uuid.New()

	// 1. Balanced Multi-entry:
	// Subtotal = $100.00 (10000 minor)
	// BuyerFee = $0.00 (0 minor)
	// SellerFee = $5.00 (500 minor)
	// Buyer Pays: $100.00 (Debit PSP Clearing: 10000)
	// Seller Receives: $95.00 (Credit Seller Payable: 9500)
	// Platform Fee: $5.00 (Credit Fee Revenue: 500)
	// Total Debits: 10000, Total Credits: 9500 + 500 = 10000. Balanced!
	tx, err := svc.RecordPaymentCapture(ctx, orderID, pspAccID, sellerPayableAccID, feeRevenueAccID, 10000, 0, 500, "USD")
	if err != nil {
		t.Fatalf("expected balanced ledger transaction to succeed, got: %v", err)
	}

	if tx.Status != "POSTED" || len(tx.Entries) != 3 {
		t.Fatalf("invalid transaction status or entries count: %v", tx)
	}

	// 2. Unbalanced Entry: Debits != Credits
	badEntries := []domain.LedgerEntry{
		{
			LedgerAccountID: pspAccID,
			DebitMinor:      5000,
			CreditMinor:     0,
			CurrencyCode:    "USD",
		},
		{
			LedgerAccountID: sellerPayableAccID,
			DebitMinor:      0,
			CreditMinor:     4000, // 1000 minor discrepancy!
			CurrencyCode:    "USD",
		},
	}

	_, err = svc.PostTransaction(ctx, "DISCREPANCY_TEST", uuid.New(), badEntries)
	if err == nil {
		t.Fatalf("expected unbalanced ledger entry to fail, but it posted")
	}
}
