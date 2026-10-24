package main

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/bookingnetwork/bn-gameex/services/api/internal/domain"
	"github.com/bookingnetwork/bn-gameex/services/api/internal/server"
	"github.com/google/uuid"
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	container := server.NewAPIContainer()
	seedInitialData(container)

	srv := &http.Server{
		Addr:         ":" + port,
		Handler:      container.Mux,
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	go func() {
		log.Printf("[BN GAMEEX API] Server running on port :%s (PID: %d)", port, os.Getpid())
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("Server ListenAndServe error: %v", err)
		}
	}()

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	log.Println("[BN GAMEEX API] Shutting down server gracefully...")
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := srv.Shutdown(ctx); err != nil {
		log.Fatalf("Server forced to shutdown: %v", err)
	}

	log.Println("[BN GAMEEX API] Server exited cleanly.")
}

func seedInitialData(c *server.APIContainer) {
	// Game 1: Ethereal Odyssey
	g1ID := uuid.MustParse("c0000000-0000-0000-0000-000000000001")
	g1 := &domain.Game{
		ID:            g1ID,
		Slug:          "ethereal-odyssey",
		Name:          "Ethereal Odyssey Online",
		PublisherName: "Aether Interactive Inc.",
		DeveloperName: "Studio Horizon",
		OfficialSite:  "https://ethereal-odyssey.example.com",
		Status:        "ACTIVE",
		CreatedAt:     time.Now(),
		UpdatedAt:     time.Now(),
	}
	c.Games[g1ID] = g1

	// Policy: US + GAME_ITEM -> APPROVED & ENABLED
	c.PolicyEngine.RegisterPolicy(&domain.GameTradePolicy{
		ID:                    uuid.New(),
		GameID:                g1ID,
		CountryCode:           "US",
		ProductType:           domain.ProductTypeGameItem,
		LegalReviewStatus:     "APPROVED",
		PublisherPolicyStatus: "PERMITTED",
		PaymentPartnerStatus:  "APPROVED",
		TradeEnabled:          true,
	})

	// Policy: KR + GAME_ITEM -> APPROVED & ENABLED
	c.PolicyEngine.RegisterPolicy(&domain.GameTradePolicy{
		ID:                    uuid.New(),
		GameID:                g1ID,
		CountryCode:           "KR",
		ProductType:           domain.ProductTypeGameItem,
		LegalReviewStatus:     "APPROVED",
		PublisherPolicyStatus: "PERMITTED",
		PaymentPartnerStatus:  "APPROVED",
		TradeEnabled:          true,
	})

	// Policy: KR + GAME_CURRENCY -> REVIEW_REQUIRED & DISABLED (Article 3.3 compliance gate)
	c.PolicyEngine.RegisterPolicy(&domain.GameTradePolicy{
		ID:                    uuid.New(),
		GameID:                g1ID,
		CountryCode:           "KR",
		ProductType:           domain.ProductTypeGameCurrency,
		LegalReviewStatus:     "REVIEW_REQUIRED",
		PublisherPolicyStatus: "REVIEW_REQUIRED",
		PaymentPartnerStatus:  "PENDING",
		TradeEnabled:          false,
	})

	// Policy: ALL + GAME_ACCOUNT -> PROHIBITED & DISABLED (Article 3.4)
	c.PolicyEngine.RegisterPolicy(&domain.GameTradePolicy{
		ID:                    uuid.New(),
		GameID:                g1ID,
		CountryCode:           "US",
		ProductType:           domain.ProductTypeGameAccount,
		LegalReviewStatus:     "PROHIBITED",
		PublisherPolicyStatus: "PROHIBITED",
		PaymentPartnerStatus:  "PROHIBITED",
		TradeEnabled:          false,
	})

	// Listing
	sellerID := uuid.MustParse("60000000-0000-0000-0000-000000000001")
	l1 := &domain.Listing{
		ID:                 uuid.MustParse("80000000-0000-0000-0000-000000000001"),
		SellerID:           sellerID,
		GameID:             g1ID,
		ProductType:        domain.ProductTypeGameItem,
		Title:              "+12 Celestial Greatsword (Trade-Permitted)",
		Description:        "Verified transferable in-game item on Altair Prime.",
		UnitPriceMinor:     4500, // $45.00
		CurrencyCode:       "USD",
		MinimumQuantity:    1,
		MaximumQuantity:    5,
		AvailableQuantity:  5,
		ReservedQuantity:   0,
		SoldQuantity:       0,
		DeliveryMethod:     "IN_GAME_MANUAL",
		DeliveryEtaMinutes: 15,
		Status:             "ACTIVE",
		CreatedAt:          time.Now(),
		UpdatedAt:          time.Now(),
	}
	c.InvService.SeedListing(l1)

	// Ledger Accounts
	c.LedgerService.RegisterAccount(&domain.LedgerAccount{
		ID:           uuid.MustParse("40000000-0000-0000-0000-000000000001"),
		AccountCode:  "1010-USD-PSP-CLEARING",
		AccountType:  "ASSET",
		CurrencyCode: "USD",
	})
	c.LedgerService.RegisterAccount(&domain.LedgerAccount{
		ID:           uuid.MustParse("40000000-0000-0000-0000-000000000002"),
		AccountCode:  "2010-USD-SELLER-PAYABLE",
		AccountType:  "LIABILITY",
		CurrencyCode: "USD",
	})
	c.LedgerService.RegisterAccount(&domain.LedgerAccount{
		ID:           uuid.MustParse("40000000-0000-0000-0000-000000000003"),
		AccountCode:  "4010-USD-FEE-REVENUE",
		AccountType:  "REVENUE",
		CurrencyCode: "USD",
	})

	fmt.Println("[BN GAMEEX API] Canonical game catalog, compliance policies, listings, and ledger seeded.")
}

