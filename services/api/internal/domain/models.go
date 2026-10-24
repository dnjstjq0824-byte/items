package domain

import (
	"errors"
	"time"

	"github.com/google/uuid"
)

// Common Error Definitions
var (
	ErrNotFound             = errors.New("resource not found")
	ErrUnauthorized         = errors.New("unauthorized")
	ErrForbidden            = errors.New("forbidden")
	ErrInvalidStateTransition = errors.New("invalid state transition")
	ErrInsufficientInventory = errors.New("insufficient inventory available")
	ErrPolicyProhibited     = errors.New("trade is prohibited by regulatory or game policy")
	ErrUnverifiedSeller     = errors.New("seller is not verified for this trade tier")
	ErrIdempotencyConflict  = errors.New("idempotency key conflict: request already processed")
	ErrLedgerUnbalanced     = errors.New("double-entry ledger transaction is unbalanced (debits != credits)")
	ErrPaymentAlreadyCaptured = errors.New("payment intent has already been captured")
	ErrInvalidWebhookSignature = errors.New("invalid webhook signature")
	ErrAccountTradeProhibited = errors.New("game account transfers are strictly prohibited under v1.0 compliance rules")
)

// Product Types
const (
	ProductTypeGameItem             = "GAME_ITEM"
	ProductTypeGameCurrency         = "GAME_CURRENCY"
	ProductTypeTransferableEntitlement = "TRANSFERABLE_ENTITLEMENT"
	ProductTypeOfficialGiftCode     = "OFFICIAL_GIFT_CODE"
	ProductTypeDigitalVoucher       = "DIGITAL_VOUCHER"
	ProductTypeGameAccount          = "GAME_ACCOUNT"
	ProductTypeGameService          = "GAME_SERVICE"
	ProductTypeOtherApproved        = "OTHER_APPROVED_DIGITAL_GOOD"
)

// Order Lifecycle Status
const (
	OrderStatusCreated            = "CREATED"
	OrderStatusPolicyChecked      = "POLICY_CHECKED"
	OrderStatusAwaitingPayment    = "AWAITING_PAYMENT"
	OrderStatusPaymentPending     = "PAYMENT_PENDING"
	OrderStatusPaymentConfirmed   = "PAYMENT_CONFIRMED"
	OrderStatusFulfillmentPending = "FULFILLMENT_PENDING"
	OrderStatusDeliveryClaimed    = "DELIVERY_CLAIMED"
	OrderStatusBuyerReview        = "BUYER_REVIEW"
	OrderStatusDisputed           = "DISPUTED"
	OrderStatusCompleted          = "COMPLETED"
	OrderStatusCancelled          = "CANCELLED"
	OrderStatusExpired            = "EXPIRED"
	OrderStatusRefundPending      = "REFUND_PENDING"
	OrderStatusRefunded           = "REFUNDED"
)

// Payment Status
const (
	PaymentStatusNotStarted          = "NOT_STARTED"
	PaymentStatusCheckoutCreated     = "CHECKOUT_CREATED"
	PaymentStatusAuthorizationPending = "AUTHORIZATION_PENDING"
	PaymentStatusAuthorized          = "AUTHORIZED"
	PaymentStatusCaptured            = "CAPTURED"
	PaymentStatusFailed              = "FAILED"
	PaymentStatusCancelled           = "CANCELLED"
	PaymentStatusPartiallyRefunded   = "PARTIALLY_REFUNDED"
	PaymentStatusRefunded            = "REFUNDED"
	PaymentStatusChargebackOpen      = "CHARGEBACK_OPEN"
	PaymentStatusChargebackResolved  = "CHARGEBACK_RESOLVED"
)

// Payout Status
const (
	PayoutStatusNotEligible    = "NOT_ELIGIBLE"
	PayoutStatusPendingProvider = "PENDING_PROVIDER"
	PayoutStatusHeldByProvider = "HELD_BY_PROVIDER"
	PayoutStatusEligible       = "ELIGIBLE"
	PayoutStatusRequested      = "PAYOUT_REQUESTED"
	PayoutStatusProcessing     = "PAYOUT_PROCESSING"
	PayoutStatusPaid           = "PAID"
	PayoutStatusFailed         = "PAYOUT_FAILED"
	PayoutStatusReversed       = "REVERSED"
)

// User & Identity
type User struct {
	ID                uuid.UUID  `json:"id"`
	Email             string     `json:"email"`
	PasswordHash      string     `json:"-"`
	DisplayName       string     `json:"display_name"`
	CountryCode       string     `json:"country_code"`
	Locale            string     `json:"locale"`
	PreferredCurrency string     `json:"preferred_currency"`
	Status            string     `json:"status"`
	EmailVerifiedAt   *time.Time `json:"email_verified_at,omitempty"`
	CreatedAt         time.Time  `json:"created_at"`
	UpdatedAt         time.Time  `json:"updated_at"`
}

// Game Catalog
type Game struct {
	ID            uuid.UUID `json:"id"`
	Slug          string    `json:"slug"`
	Name          string    `json:"name"`
	PublisherName string    `json:"publisher_name"`
	DeveloperName string    `json:"developer_name"`
	OfficialSite  string    `json:"official_site"`
	Status        string    `json:"status"`
	CreatedAt     time.Time `json:"created_at"`
	UpdatedAt     time.Time `json:"updated_at"`
}

type GamePlatform struct {
	ID           uuid.UUID `json:"id"`
	GameID       uuid.UUID `json:"game_id"`
	PlatformCode string    `json:"platform_code"`
	Status       string    `json:"status"`
}

type GameRegion struct {
	ID          uuid.UUID `json:"id"`
	GameID      uuid.UUID `json:"game_id"`
	RegionCode  string    `json:"region_code"`
	DisplayName string    `json:"display_name"`
	Status      string    `json:"status"`
}

type GameServer struct {
	ID           uuid.UUID `json:"id"`
	GameID       uuid.UUID `json:"game_id"`
	GameRegionID uuid.UUID `json:"game_region_id"`
	ServerCode   string    `json:"server_code"`
	Name         string    `json:"name"`
	Status       string    `json:"status"`
}

// Policy Engine
type GameTradePolicy struct {
	ID                    uuid.UUID  `json:"id"`
	GameID                uuid.UUID  `json:"game_id"`
	CountryCode           string     `json:"country_code"`
	ProductType           string     `json:"product_type"`
	LegalReviewStatus     string     `json:"legal_review_status"`
	PublisherPolicyStatus string     `json:"publisher_policy_status"`
	PaymentPartnerStatus  string     `json:"payment_partner_status"`
	TradeEnabled          bool       `json:"trade_enabled"`
	ApprovedBy            *uuid.UUID `json:"approved_by,omitempty"`
	ApprovedAt            *time.Time `json:"approved_at,omitempty"`
	ReviewedAt            *time.Time `json:"reviewed_at,omitempty"`
	CreatedAt             time.Time  `json:"created_at"`
	UpdatedAt             time.Time  `json:"updated_at"`
}

// Seller
type Seller struct {
	ID                   uuid.UUID `json:"id"`
	UserID               uuid.UUID `json:"user_id"`
	SellerType           string    `json:"seller_type"`
	DisplayName          string    `json:"display_name"`
	CountryCode          string    `json:"country_code"`
	VerificationStatus   string    `json:"verification_status"`
	SalesStatus          string    `json:"sales_status"`
	CompletedOrdersCount int       `json:"completed_orders_count"`
	DisputeCount         int       `json:"dispute_count"`
	RatingScoreSum       int64     `json:"rating_score_sum"`
	RatingCount          int       `json:"rating_count"`
	JoinedAt             time.Time `json:"joined_at"`
	CreatedAt            time.Time `json:"created_at"`
	UpdatedAt            time.Time `json:"updated_at"`
}

// Listing & Inventory
type Listing struct {
	ID                 uuid.UUID  `json:"id"`
	SellerID           uuid.UUID  `json:"seller_id"`
	GameID             uuid.UUID  `json:"game_id"`
	GamePlatformID     uuid.UUID  `json:"game_platform_id"`
	GameRegionID       *uuid.UUID `json:"game_region_id,omitempty"`
	GameServerID       *uuid.UUID `json:"game_server_id,omitempty"`
	ProductType        string     `json:"product_type"`
	Title              string     `json:"title"`
	Description        string     `json:"description"`
	UnitPriceMinor     int64      `json:"unit_price_minor"`
	CurrencyCode       string     `json:"currency_code"`
	MinimumQuantity    int        `json:"minimum_quantity"`
	MaximumQuantity    int        `json:"maximum_quantity"`
	AvailableQuantity  int        `json:"available_quantity"`
	ReservedQuantity   int        `json:"reserved_quantity"`
	SoldQuantity       int        `json:"sold_quantity"`
	DeliveryMethod     string     `json:"delivery_method"`
	DeliveryEtaMinutes int        `json:"delivery_eta_minutes"`
	Status             string     `json:"status"`
	PolicyApprovalID   *uuid.UUID `json:"policy_approval_id,omitempty"`
	PublishedAt        *time.Time `json:"published_at,omitempty"`
	CreatedAt          time.Time  `json:"created_at"`
	UpdatedAt          time.Time  `json:"updated_at"`
}

type InventoryReservation struct {
	ID        uuid.UUID `json:"id"`
	ListingID uuid.UUID `json:"listing_id"`
	OrderID   uuid.UUID `json:"order_id"`
	Quantity  int       `json:"quantity"`
	Status    string    `json:"status"`
	ExpiresAt time.Time `json:"expires_at"`
	CreatedAt time.Time `json:"created_at"`
}

// Quotes & Orders
type OrderQuote struct {
	ID               uuid.UUID `json:"id"`
	BuyerUserID      uuid.UUID `json:"buyer_user_id"`
	ListingID        uuid.UUID `json:"listing_id"`
	Quantity         int       `json:"quantity"`
	UnitPriceMinor   int64     `json:"unit_price_minor"`
	SubtotalMinor    int64     `json:"subtotal_minor"`
	PlatformFeeMinor int64     `json:"platform_fee_minor"`
	PaymentFeeMinor  int64     `json:"payment_fee_minor"`
	TaxMinor         int64     `json:"tax_minor"`
	TotalMinor       int64     `json:"total_minor"`
	CurrencyCode     string    `json:"currency_code"`
	FeePolicyVersion string    `json:"fee_policy_version"`
	ExpiresAt        time.Time `json:"expires_at"`
	CreatedAt        time.Time `json:"created_at"`
}

type Order struct {
	ID                uuid.UUID  `json:"id"`
	OrderNumber       string     `json:"order_number"`
	BuyerUserID       uuid.UUID  `json:"buyer_user_id"`
	SellerID          uuid.UUID  `json:"seller_id"`
	ListingID         uuid.UUID  `json:"listing_id"`
	QuoteID           uuid.UUID  `json:"quote_id"`
	Quantity          int        `json:"quantity"`
	CurrencyCode      string     `json:"currency_code"`
	SubtotalMinor     int64      `json:"subtotal_minor"`
	BuyerFeeMinor     int64      `json:"buyer_fee_minor"`
	SellerFeeMinor    int64      `json:"seller_fee_minor"`
	TaxMinor          int64      `json:"tax_minor"`
	TotalMinor        int64      `json:"total_minor"`
	OrderStatus       string     `json:"order_status"`
	PaymentStatus     string     `json:"payment_status"`
	FulfillmentStatus string     `json:"fulfillment_status"`
	PayoutStatus      string     `json:"payout_status"`
	DeliveryNote      string     `json:"delivery_note,omitempty"`
	Version           int64      `json:"version"`
	PlacedAt          time.Time  `json:"placed_at"`
	CreatedAt         time.Time  `json:"created_at"`
	UpdatedAt         time.Time  `json:"updated_at"`
}

type OrderStatusHistory struct {
	ID        uuid.UUID  `json:"id"`
	OrderID   uuid.UUID  `json:"order_id"`
	FromStatus string     `json:"from_status"`
	ToStatus   string     `json:"to_status"`
	ActorType  string     `json:"actor_type"`
	ActorID    *uuid.UUID `json:"actor_id,omitempty"`
	Reason     string     `json:"reason"`
	CreatedAt  time.Time  `json:"created_at"`
}

// Payment & Ledger
type PaymentIntent struct {
	ID                       uuid.UUID `json:"id"`
	OrderID                  uuid.UUID `json:"order_id"`
	ProviderID               string    `json:"provider_id"`
	ProviderPaymentReference string    `json:"provider_payment_reference"`
	AmountMinor              int64     `json:"amount_minor"`
	CurrencyCode             string    `json:"currency_code"`
	Status                   string    `json:"status"`
	IdempotencyKey           string    `json:"idempotency_key"`
	CheckoutURL              string    `json:"checkout_url"`
	CreatedAt                time.Time `json:"created_at"`
	UpdatedAt                time.Time `json:"updated_at"`
}

type PaymentEvent struct {
	ID              uuid.UUID  `json:"id"`
	ProviderID      string     `json:"provider_id"`
	ProviderEventID string     `json:"provider_event_id"`
	PaymentIntentID *uuid.UUID `json:"payment_intent_id,omitempty"`
	EventType       string     `json:"event_type"`
	Payload         string     `json:"payload"`
	Status          string     `json:"status"`
	ProcessedAt     *time.Time `json:"processed_at,omitempty"`
	CreatedAt       time.Time  `json:"created_at"`
}

// Double-Entry Ledger
type LedgerAccount struct {
	ID           uuid.UUID `json:"id"`
	AccountCode  string    `json:"account_code"`
	AccountType  string    `json:"account_type"`
	CurrencyCode string    `json:"currency_code"`
	Description  string    `json:"description"`
}

type LedgerTransaction struct {
	ID            uuid.UUID     `json:"id"`
	ReferenceType string        `json:"reference_type"`
	ReferenceID   uuid.UUID     `json:"reference_id"`
	Status        string        `json:"status"`
	Entries       []LedgerEntry `json:"entries,omitempty"`
	CreatedAt     time.Time     `json:"created_at"`
}

type LedgerEntry struct {
	ID                  uuid.UUID `json:"id"`
	LedgerTransactionID uuid.UUID `json:"ledger_transaction_id"`
	LedgerAccountID     uuid.UUID `json:"ledger_account_id"`
	DebitMinor          int64     `json:"debit_minor"`
	CreditMinor         int64     `json:"credit_minor"`
	CurrencyCode        string    `json:"currency_code"`
	CreatedAt           time.Time `json:"created_at"`
}

// Payout
type PayoutRequest struct {
	ID                       uuid.UUID  `json:"id"`
	SellerID                 uuid.UUID  `json:"seller_id"`
	ProviderID               string     `json:"provider_id"`
	ProviderPayoutReference  string     `json:"provider_payout_reference,omitempty"`
	AmountMinor              int64      `json:"amount_minor"`
	CurrencyCode             string     `json:"currency_code"`
	Status                   string     `json:"status"`
	ApprovedBy               *uuid.UUID `json:"approved_by,omitempty"`
	RequestedAt              time.Time  `json:"requested_at"`
	CompletedAt              *time.Time `json:"completed_at,omitempty"`
}

// Delivery & Evidence
type Delivery struct {
	ID               uuid.UUID  `json:"id"`
	OrderID          uuid.UUID  `json:"order_id"`
	DeliveryMethod   string     `json:"delivery_method"`
	SellerClaimedAt  *time.Time `json:"seller_claimed_at,omitempty"`
	BuyerConfirmedAt *time.Time `json:"buyer_confirmed_at,omitempty"`
	Status           string     `json:"status"`
	CreatedAt        time.Time  `json:"created_at"`
	UpdatedAt        time.Time  `json:"updated_at"`
}

type DeliveryEvidence struct {
	ID                 uuid.UUID `json:"id"`
	DeliveryID         uuid.UUID `json:"delivery_id"`
	SubmittedByUserID  uuid.UUID `json:"submitted_by_user_id"`
	MediaAssetID       uuid.UUID `json:"media_asset_id"`
	EvidenceType       string    `json:"evidence_type"`
	Description        string    `json:"description"`
	Checksum           string    `json:"checksum"`
	CreatedAt          time.Time `json:"created_at"`
}

// Disputes
type Dispute struct {
	ID              uuid.UUID  `json:"id"`
	OrderID         uuid.UUID  `json:"order_id"`
	OpenedByUserID  uuid.UUID  `json:"opened_by_user_id"`
	ReasonCode      string     `json:"reason_code"`
	Description     string     `json:"description"`
	Status          string     `json:"status"`
	AssignedAdminID *uuid.UUID `json:"assigned_admin_id,omitempty"`
	OpenedAt        time.Time  `json:"opened_at"`
	ResolvedAt      *time.Time `json:"resolved_at,omitempty"`
}

type DisputeDecision struct {
	ID             uuid.UUID  `json:"id"`
	DisputeID      uuid.UUID  `json:"dispute_id"`
	DecisionCode   string     `json:"decision_code"`
	DecisionReason string     `json:"decision_reason"`
	DecidedBy      uuid.UUID  `json:"decided_by"`
	ApprovalStatus string     `json:"approval_status"`
	ApprovedBy     *uuid.UUID `json:"approved_by,omitempty"`
	CreatedAt      time.Time  `json:"created_at"`
}

type DisputeEvidence struct {
	ID                uuid.UUID  `json:"id"`
	DisputeID         uuid.UUID  `json:"dispute_id"`
	SubmittedByUserID uuid.UUID  `json:"submitted_by_user_id"`
	MediaAssetID      *uuid.UUID `json:"media_asset_id,omitempty"`
	Description       string     `json:"description"`
	CreatedAt         time.Time  `json:"created_at"`
}

// Trust & Risk
type RiskEvent struct {
	ID        uuid.UUID  `json:"id"`
	UserID    *uuid.UUID `json:"user_id,omitempty"`
	OrderID   *uuid.UUID `json:"order_id,omitempty"`
	EventType string     `json:"event_type"`
	RiskLevel string     `json:"risk_level"`
	Action    string     `json:"action"`
	Status    string     `json:"status"`
	CreatedAt time.Time  `json:"created_at"`
}

// Real-Time Chat
type Conversation struct {
	ID        uuid.UUID   `json:"id"`
	ListingID *uuid.UUID  `json:"listing_id,omitempty"`
	OrderID   *uuid.UUID  `json:"order_id,omitempty"`
	Members   []uuid.UUID `json:"members"`
	CreatedAt time.Time   `json:"created_at"`
	UpdatedAt time.Time   `json:"updated_at"`
}

type ChatMessage struct {
	ID              uuid.UUID `json:"id"`
	ConversationID  uuid.UUID `json:"conversation_id"`
	SenderUserID    uuid.UUID `json:"sender_user_id"`
	ClientMessageID uuid.UUID `json:"client_message_id"`
	SequenceNo      int64     `json:"sequence_no"`
	MessageType     string    `json:"message_type"`
	Body            string    `json:"body"`
	Status          string    `json:"status"`
	CreatedAt       time.Time `json:"created_at"`
}

// Audit Log
type AuditLog struct {
	ID               uuid.UUID  `json:"id"`
	ActorType        string     `json:"actor_type"`
	ActorID          *uuid.UUID `json:"actor_id,omitempty"`
	Action           string     `json:"action"`
	ResourceType     string     `json:"resource_type"`
	ResourceID       string     `json:"resource_id"`
	Result           string     `json:"result"`
	RequestID        string     `json:"request_id"`
	MetadataRedacted string     `json:"metadata_redacted"`
	CreatedAt        time.Time  `json:"created_at"`
}
