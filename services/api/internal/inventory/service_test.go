package inventory_test

import (
	"context"
	"testing"
	"time"

	"github.com/bookingnetwork/bn-gameex/services/api/internal/domain"
	"github.com/bookingnetwork/bn-gameex/services/api/internal/inventory"
	"github.com/google/uuid"
)

func TestInventoryService_AtomicReservationAndInvariants(t *testing.T) {
	svc := inventory.NewService()
	listingID := uuid.New()

	listing := &domain.Listing{
		ID:                listingID,
		AvailableQuantity: 10,
		ReservedQuantity:  0,
		SoldQuantity:      0,
	}
	svc.SeedListing(listing)

	ctx := context.Background()
	orderID := uuid.New()

	// 1. Reserve 3 items
	res, err := svc.ReserveStock(ctx, listingID, orderID, 3, 100*time.Millisecond)
	if err != nil {
		t.Fatalf("unexpected error reserving stock: %v", err)
	}

	l, _ := svc.GetListing(listingID)
	if l.AvailableQuantity != 7 || l.ReservedQuantity != 3 {
		t.Fatalf("expected available=7, reserved=3; got available=%d, reserved=%d", l.AvailableQuantity, l.ReservedQuantity)
	}

	// 2. Attempt to reserve more than available (8 > 7) -> should fail
	_, err = svc.ReserveStock(ctx, listingID, uuid.New(), 8, 1*time.Minute)
	if err == nil {
		t.Fatalf("expected oversell reservation to fail, but it succeeded")
	}

	// 3. Consume reservation on payment capture -> moves to sold
	if err := svc.ConsumeReservation(ctx, res.ID); err != nil {
		t.Fatalf("unexpected error consuming reservation: %v", err)
	}

	l, _ = svc.GetListing(listingID)
	if l.ReservedQuantity != 0 || l.SoldQuantity != 3 || l.AvailableQuantity != 7 {
		t.Fatalf("invariant broken after consumption: available=%d, reserved=%d, sold=%d", l.AvailableQuantity, l.ReservedQuantity, l.SoldQuantity)
	}

	// 4. Test expiration cleanup
	orderID2 := uuid.New()
	res2, err := svc.ReserveStock(ctx, listingID, orderID2, 2, 10*time.Millisecond)
	if err != nil {
		t.Fatalf("failed reserving for expiration test: %v", err)
	}
	_ = res2

	time.Sleep(30 * time.Millisecond)
	expiredCount := svc.ExpireStaleReservations(ctx)
	if expiredCount != 1 {
		t.Fatalf("expected 1 expired reservation, got %d", expiredCount)
	}

	l, _ = svc.GetListing(listingID)
	if l.AvailableQuantity != 7 || l.ReservedQuantity != 0 {
		t.Fatalf("expected rolled back stock available=7, reserved=0; got available=%d, reserved=%d", l.AvailableQuantity, l.ReservedQuantity)
	}
}
