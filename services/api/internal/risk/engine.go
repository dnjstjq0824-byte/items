package risk

import (
	"context"
	"regexp"
	"strings"
	"sync"
	"time"

	"github.com/bookingnetwork/bn-gameex/services/api/internal/domain"
	"github.com/google/uuid"
)

var (
	// Off-platform leakage detection patterns (Article 20)
	offPlatformRegex = regexp.MustCompile(`(?i)(discord\.gg|t\.me/|wa\.me/|kakaotalk|telegram|whatsapp|skype|wechat)`)
	phishingRegex    = regexp.MustCompile(`(?i)(steamcommunlty|steam-trade-gift|free-skins-event|login-verify)`)
)

type Engine struct {
	mu     sync.RWMutex
	events map[uuid.UUID]*domain.RiskEvent
}

func NewEngine() *Engine {
	return &Engine{
		events: make(map[uuid.UUID]*domain.RiskEvent),
	}
}

// EvaluateMessageContent checks for external contact leakage or phishing attempts
func (e *Engine) EvaluateMessageContent(ctx context.Context, userID uuid.UUID, content string) (string, error) {
	e.mu.Lock()
	defer e.mu.Unlock()

	if phishingRegex.MatchString(content) {
		event := &domain.RiskEvent{
			ID:        uuid.New(),
			UserID:    &userID,
			EventType: "PHISHING_URL_DETECTED",
			RiskLevel: "CRITICAL",
			Action:    "BLOCK",
			Status:    "OPEN",
			CreatedAt: time.Now(),
		}
		e.events[event.ID] = event
		return "BLOCK", nil
	}

	if offPlatformRegex.MatchString(content) {
		event := &domain.RiskEvent{
			ID:        uuid.New(),
			UserID:    &userID,
			EventType: "OFF_PLATFORM_TRADING_LEAKAGE",
			RiskLevel: "MEDIUM",
			Action:    "MANUAL_REVIEW",
			Status:    "OPEN",
			CreatedAt: time.Now(),
		}
		e.events[event.ID] = event
		return "WARNING", nil
	}

	return "ALLOW", nil
}

// EvaluateOrderRisk checks high-value velocity and seller trustworthiness
func (e *Engine) EvaluateOrderRisk(ctx context.Context, seller *domain.Seller, amountMinor int64, currency string) (string, error) {
	e.mu.Lock()
	defer e.mu.Unlock()

	// High value threshold: $1,000 USD (100,000 minor)
	isHighValue := (currency == "USD" && amountMinor >= 100000) || (currency == "KRW" && amountMinor >= 100000000)

	if isHighValue && seller.VerificationStatus != "VERIFIED" {
		event := &domain.RiskEvent{
			ID:        uuid.New(),
			UserID:    &seller.UserID,
			EventType: "HIGH_VALUE_UNVERIFIED_SELLER",
			RiskLevel: "HIGH",
			Action:    "MANUAL_REVIEW",
			Status:    "OPEN",
			CreatedAt: time.Now(),
		}
		e.events[event.ID] = event
		return "MANUAL_REVIEW", nil
	}

	if strings.ToUpper(seller.SalesStatus) == "RESTRICTED" || strings.ToUpper(seller.SalesStatus) == "BANNED" {
		return "BLOCK", nil
	}

	return "ALLOW", nil
}
