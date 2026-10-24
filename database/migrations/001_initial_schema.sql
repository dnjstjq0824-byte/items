-- BN GAMEEX Master Database Schema
-- Migration: 001_initial_schema.sql
-- Compatible with PostgreSQL 15+
-- Strictly adheres to ARTICLE 22 and ARTICLE 23 of Master PO Order BN-GAMEEX-MASTER-001

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- 1. IDENTITY & USERS
-- ============================================================================

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    country_code VARCHAR(2) NOT NULL, -- ISO 3166-1 alpha-2
    locale VARCHAR(10) NOT NULL DEFAULT 'en',
    preferred_currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('PENDING_VERIFICATION', 'ACTIVE', 'SUSPENDED', 'BANNED', 'DELETED')),
    email_verified_at TIMESTAMPTZ,
    version BIGINT NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_country_status ON users(country_code, status);

CREATE TABLE user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    refresh_token_hash VARCHAR(255) NOT NULL UNIQUE,
    device_id VARCHAR(255),
    ip_address VARCHAR(45),
    user_agent TEXT,
    expires_at TIMESTAMPTZ NOT NULL,
    revoked_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_user_sessions_user_id ON user_sessions(user_id);
CREATE INDEX idx_user_sessions_expires_at ON user_sessions(expires_at);

CREATE TABLE user_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    theme VARCHAR(20) NOT NULL DEFAULT 'dark' CHECK (theme IN ('dark', 'light', 'system')),
    language VARCHAR(10) NOT NULL DEFAULT 'en',
    currency VARCHAR(3) NOT NULL DEFAULT 'USD',
    notification_preferences JSONB NOT NULL DEFAULT '{"email": true, "push": true, "order_updates": true, "chat_messages": true}'::jsonb,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE user_blocks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    blocker_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    blocked_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reason VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_user_blocks UNIQUE (blocker_user_id, blocked_user_id),
    CONSTRAINT chk_user_cannot_block_self CHECK (blocker_user_id <> blocked_user_id)
);

CREATE INDEX idx_user_blocks_blocker ON user_blocks(blocker_user_id);

-- ============================================================================
-- 2. MEDIA ASSETS
-- ============================================================================

CREATE TABLE media_assets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    storage_key VARCHAR(512) NOT NULL UNIQUE,
    original_filename VARCHAR(255) NOT NULL,
    mime_type VARCHAR(100) NOT NULL,
    file_size_bytes BIGINT NOT NULL CHECK (file_size_bytes > 0),
    sha256 VARCHAR(64) NOT NULL,
    scan_status VARCHAR(30) NOT NULL DEFAULT 'PENDING' CHECK (scan_status IN ('PENDING', 'CLEAN', 'INFECTED', 'REJECTED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_media_assets_owner ON media_assets(owner_user_id);
CREATE INDEX idx_media_assets_sha256 ON media_assets(sha256);

-- ============================================================================
-- 3. GAME CATALOG & TRADE POLICIES
-- ============================================================================

CREATE TABLE games (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(150) NOT NULL,
    publisher_name VARCHAR(150) NOT NULL,
    developer_name VARCHAR(150),
    official_site VARCHAR(512),
    logo_asset_id UUID REFERENCES media_assets(id) ON DELETE SET NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'MAINTENANCE', 'RESTRICTED', 'INACTIVE')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    version BIGINT NOT NULL DEFAULT 1
);

CREATE INDEX idx_games_slug ON games(slug);
CREATE INDEX idx_games_status ON games(status);

CREATE TABLE game_platforms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    game_id UUID NOT NULL REFERENCES games(id) ON DELETE CASCADE,
    platform_code VARCHAR(30) NOT NULL CHECK (platform_code IN ('PC', 'ANDROID', 'IOS', 'CONSOLE', 'CROSS_PLATFORM')),
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE')),
    CONSTRAINT uq_game_platform UNIQUE (game_id, platform_code)
);

CREATE TABLE game_regions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    game_id UUID NOT NULL REFERENCES games(id) ON DELETE CASCADE,
    region_code VARCHAR(50) NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE')),
    CONSTRAINT uq_game_region UNIQUE (game_id, region_code)
);

CREATE TABLE game_servers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    game_id UUID NOT NULL REFERENCES games(id) ON DELETE CASCADE,
    game_region_id UUID REFERENCES game_regions(id) ON DELETE CASCADE,
    server_code VARCHAR(50) NOT NULL,
    name VARCHAR(100) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE')),
    CONSTRAINT uq_game_server UNIQUE (game_id, game_region_id, server_code)
);

CREATE TABLE game_product_types (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    game_id UUID NOT NULL REFERENCES games(id) ON DELETE CASCADE,
    product_type VARCHAR(50) NOT NULL CHECK (product_type IN (
        'GAME_ITEM',
        'GAME_CURRENCY',
        'TRANSFERABLE_ENTITLEMENT',
        'OFFICIAL_GIFT_CODE',
        'DIGITAL_VOUCHER',
        'GAME_ACCOUNT',
        'GAME_SERVICE',
        'OTHER_APPROVED_DIGITAL_GOOD'
    )),
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'REVIEW_REQUIRED', 'INACTIVE')),
    CONSTRAINT uq_game_product_type UNIQUE (game_id, product_type)
);

CREATE TABLE game_trade_policies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    game_id UUID NOT NULL REFERENCES games(id) ON DELETE CASCADE,
    country_code VARCHAR(2) NOT NULL,
    product_type VARCHAR(50) NOT NULL,
    legal_review_status VARCHAR(30) NOT NULL DEFAULT 'REVIEW_REQUIRED' CHECK (legal_review_status IN ('APPROVED', 'REVIEW_REQUIRED', 'PROHIBITED')),
    publisher_policy_status VARCHAR(30) NOT NULL DEFAULT 'REVIEW_REQUIRED' CHECK (publisher_policy_status IN ('PERMITTED', 'TOLERATED', 'REVIEW_REQUIRED', 'PROHIBITED')),
    payment_partner_status VARCHAR(30) NOT NULL DEFAULT 'REVIEW_REQUIRED' CHECK (payment_partner_status IN ('APPROVED', 'PENDING', 'PROHIBITED')),
    trade_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    approved_by UUID REFERENCES users(id) ON DELETE SET NULL,
    approved_at TIMESTAMPTZ,
    reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_game_trade_policy UNIQUE (game_id, country_code, product_type)
);

CREATE INDEX idx_game_trade_policies_lookup ON game_trade_policies(game_id, country_code, product_type, trade_enabled);

CREATE TABLE game_policy_sources (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    game_id UUID NOT NULL REFERENCES games(id) ON DELETE CASCADE,
    source_type VARCHAR(50) NOT NULL CHECK (source_type IN ('TERMS_OF_SERVICE', 'PUBLISHER_API_AGREEMENT', 'LEGAL_STATUTE', 'PSP_ACCEPTABLE_USE')),
    source_url VARCHAR(1024),
    source_version VARCHAR(50),
    verified_at TIMESTAMPTZ,
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- 4. SELLERS & VERIFICATION
-- ============================================================================

CREATE TABLE sellers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    seller_type VARCHAR(30) NOT NULL DEFAULT 'INDIVIDUAL' CHECK (seller_type IN ('INDIVIDUAL', 'BUSINESS', 'PRO_SELLER')),
    display_name VARCHAR(100) NOT NULL,
    country_code VARCHAR(2) NOT NULL,
    verification_status VARCHAR(30) NOT NULL DEFAULT 'UNVERIFIED' CHECK (verification_status IN ('UNVERIFIED', 'PENDING_SUBMISSION', 'PENDING_PROVIDER_REVIEW', 'VERIFIED', 'REJECTED', 'SUSPENDED')),
    sales_status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE' CHECK (sales_status IN ('ACTIVE', 'PAUSED', 'RESTRICTED', 'BANNED')),
    completed_orders_count INTEGER NOT NULL DEFAULT 0 CHECK (completed_orders_count >= 0),
    dispute_count INTEGER NOT NULL DEFAULT 0 CHECK (dispute_count >= 0),
    rating_score_sum BIGINT NOT NULL DEFAULT 0 CHECK (rating_score_sum >= 0),
    rating_count INTEGER NOT NULL DEFAULT 0 CHECK (rating_count >= 0),
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    version BIGINT NOT NULL DEFAULT 1
);

CREATE INDEX idx_sellers_user ON sellers(user_id);
CREATE INDEX idx_sellers_status ON sellers(verification_status, sales_status);

CREATE TABLE seller_verifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    seller_id UUID NOT NULL REFERENCES sellers(id) ON DELETE CASCADE,
    provider_reference VARCHAR(255) NOT NULL,
    verification_type VARCHAR(50) NOT NULL CHECK (verification_type IN ('ID_DOCUMENT', 'BUSINESS_REGISTRATION', 'PHONE_SMS', 'BANK_OWNERSHIP')),
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'VERIFIED', 'REJECTED', 'EXPIRED')),
    verified_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE seller_payout_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    seller_id UUID NOT NULL REFERENCES sellers(id) ON DELETE CASCADE,
    provider_id VARCHAR(50) NOT NULL,
    provider_account_reference VARCHAR(255) NOT NULL,
    currency_code VARCHAR(3) NOT NULL,
    verification_status VARCHAR(30) NOT NULL DEFAULT 'PENDING' CHECK (verification_status IN ('PENDING', 'VERIFIED', 'FAILED')),
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'INACTIVE', 'SUSPENDED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_seller_payout_account UNIQUE (seller_id, provider_id, provider_account_reference)
);

-- ============================================================================
-- 5. LISTINGS & INVENTORY
-- ============================================================================

CREATE TABLE listings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    seller_id UUID NOT NULL REFERENCES sellers(id) ON DELETE RESTRICT,
    game_id UUID NOT NULL REFERENCES games(id) ON DELETE RESTRICT,
    game_platform_id UUID NOT NULL REFERENCES game_platforms(id) ON DELETE RESTRICT,
    game_region_id UUID REFERENCES game_regions(id) ON DELETE RESTRICT,
    game_server_id UUID REFERENCES game_servers(id) ON DELETE RESTRICT,
    product_type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    unit_price_minor BIGINT NOT NULL CHECK (unit_price_minor > 0),
    currency_code VARCHAR(3) NOT NULL,
    minimum_quantity INTEGER NOT NULL DEFAULT 1 CHECK (minimum_quantity > 0),
    maximum_quantity INTEGER NOT NULL DEFAULT 1000 CHECK (maximum_quantity >= minimum_quantity),
    available_quantity INTEGER NOT NULL DEFAULT 0 CHECK (available_quantity >= 0),
    reserved_quantity INTEGER NOT NULL DEFAULT 0 CHECK (reserved_quantity >= 0),
    sold_quantity INTEGER NOT NULL DEFAULT 0 CHECK (sold_quantity >= 0),
    delivery_method VARCHAR(50) NOT NULL CHECK (delivery_method IN ('IN_GAME_MANUAL', 'OFFICIAL_TRANSFER_API', 'AUTHORIZED_DIGITAL_CODE', 'OTHER_APPROVED_METHOD')),
    delivery_eta_minutes INTEGER NOT NULL DEFAULT 30 CHECK (delivery_eta_minutes > 0),
    status VARCHAR(30) NOT NULL DEFAULT 'DRAFT' CHECK (status IN (
        'DRAFT',
        'PENDING_POLICY_REVIEW',
        'PENDING_CONTENT_REVIEW',
        'ACTIVE',
        'PAUSED',
        'OUT_OF_STOCK',
        'SOLD_OUT',
        'SUSPENDED',
        'REJECTED',
        'ARCHIVED'
    )),
    policy_approval_id UUID REFERENCES game_trade_policies(id) ON DELETE RESTRICT,
    version BIGINT NOT NULL DEFAULT 1,
    published_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT chk_listing_stock_non_negative CHECK (available_quantity >= 0 AND reserved_quantity >= 0)
);

CREATE INDEX idx_listings_search ON listings(game_id, status, unit_price_minor);
CREATE INDEX idx_listings_seller ON listings(seller_id);

CREATE TABLE listing_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    media_asset_id UUID NOT NULL REFERENCES media_assets(id) ON DELETE RESTRICT,
    sort_order INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE listing_attributes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    attribute_key VARCHAR(100) NOT NULL,
    attribute_value VARCHAR(255) NOT NULL,
    CONSTRAINT uq_listing_attribute UNIQUE (listing_id, attribute_key)
);

CREATE TABLE listing_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    from_status VARCHAR(30) NOT NULL,
    to_status VARCHAR(30) NOT NULL,
    actor_id UUID REFERENCES users(id) ON DELETE SET NULL,
    reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE listing_favorites (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, listing_id)
);

-- ============================================================================
-- 6. ORDER QUOTES & ORDERS
-- ============================================================================

CREATE TABLE order_quotes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    buyer_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price_minor BIGINT NOT NULL CHECK (unit_price_minor > 0),
    subtotal_minor BIGINT NOT NULL CHECK (subtotal_minor >= 0),
    fee_total_minor BIGINT NOT NULL DEFAULT 0 CHECK (fee_total_minor >= 0),
    tax_total_minor BIGINT NOT NULL DEFAULT 0 CHECK (tax_total_minor >= 0),
    total_minor BIGINT NOT NULL CHECK (total_minor >= 0),
    currency_code VARCHAR(3) NOT NULL,
    fee_policy_version VARCHAR(50) NOT NULL DEFAULT 'v1.0',
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_order_quotes_buyer ON order_quotes(buyer_user_id);

CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_number VARCHAR(50) NOT NULL UNIQUE,
    buyer_user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    seller_id UUID NOT NULL REFERENCES sellers(id) ON DELETE RESTRICT,
    listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE RESTRICT,
    quote_id UUID REFERENCES order_quotes(id) ON DELETE RESTRICT,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    currency_code VARCHAR(3) NOT NULL,
    subtotal_minor BIGINT NOT NULL CHECK (subtotal_minor >= 0),
    buyer_fee_minor BIGINT NOT NULL DEFAULT 0 CHECK (buyer_fee_minor >= 0),
    seller_fee_minor BIGINT NOT NULL DEFAULT 0 CHECK (seller_fee_minor >= 0),
    tax_minor BIGINT NOT NULL DEFAULT 0 CHECK (tax_minor >= 0),
    total_minor BIGINT NOT NULL CHECK (total_minor >= 0),
    order_status VARCHAR(30) NOT NULL DEFAULT 'CREATED' CHECK (order_status IN (
        'CREATED',
        'POLICY_CHECKED',
        'AWAITING_PAYMENT',
        'PAYMENT_PENDING',
        'PAYMENT_CONFIRMED',
        'FULFILLMENT_PENDING',
        'DELIVERY_CLAIMED',
        'BUYER_REVIEW',
        'DISPUTED',
        'COMPLETED',
        'CANCELLED',
        'EXPIRED',
        'REFUND_PENDING',
        'REFUNDED'
    )),
    payment_status VARCHAR(30) NOT NULL DEFAULT 'NOT_STARTED' CHECK (payment_status IN (
        'NOT_STARTED',
        'CHECKOUT_CREATED',
        'AUTHORIZATION_PENDING',
        'AUTHORIZED',
        'CAPTURED',
        'FAILED',
        'CANCELLED',
        'PARTIALLY_REFUNDED',
        'REFUNDED',
        'CHARGEBACK_OPEN',
        'CHARGEBACK_RESOLVED'
    )),
    fulfillment_status VARCHAR(30) NOT NULL DEFAULT 'UNFULFILLED' CHECK (fulfillment_status IN (
        'UNFULFILLED',
        'FULFILLMENT_IN_PROGRESS',
        'DELIVERED_CLAIMED',
        'CONFIRMED_BY_BUYER',
        'CANCELLED'
    )),
    payout_status VARCHAR(30) NOT NULL DEFAULT 'NOT_ELIGIBLE' CHECK (payout_status IN (
        'NOT_ELIGIBLE',
        'PENDING_PROVIDER',
        'HELD_BY_PROVIDER',
        'ELIGIBLE',
        'PAYOUT_REQUESTED',
        'PAYOUT_PROCESSING',
        'PAID',
        'PAYOUT_FAILED',
        'REVERSED'
    )),
    delivery_note TEXT,
    version BIGINT NOT NULL DEFAULT 1,
    placed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_orders_buyer ON orders(buyer_user_id);
CREATE INDEX idx_orders_seller ON orders(seller_id);
CREATE INDEX idx_orders_status ON orders(order_status, payment_status);

CREATE TABLE inventory_reservations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE RESTRICT,
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'CONSUMED', 'RELEASED', 'EXPIRED')),
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_inventory_reservations_listing ON inventory_reservations(listing_id, status);
CREATE INDEX idx_inventory_reservations_expires_at ON inventory_reservations(expires_at) WHERE status = 'ACTIVE';

CREATE TABLE order_status_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    from_status VARCHAR(30) NOT NULL,
    to_status VARCHAR(30) NOT NULL,
    actor_type VARCHAR(30) NOT NULL CHECK (actor_type IN ('BUYER', 'SELLER', 'SYSTEM', 'ADMIN', 'PSP')),
    actor_id UUID REFERENCES users(id) ON DELETE SET NULL,
    reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE order_fees (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    fee_type VARCHAR(50) NOT NULL CHECK (fee_type IN ('PLATFORM_BUYER', 'PLATFORM_SELLER', 'PAYMENT_PROCESSING', 'TAX')),
    amount_minor BIGINT NOT NULL CHECK (amount_minor >= 0),
    currency_code VARCHAR(3) NOT NULL,
    policy_version VARCHAR(50) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE price_negotiations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id UUID NOT NULL REFERENCES listings(id) ON DELETE CASCADE,
    buyer_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    seller_id UUID NOT NULL REFERENCES sellers(id) ON DELETE CASCADE,
    proposed_amount_minor BIGINT NOT NULL CHECK (proposed_amount_minor > 0),
    currency_code VARCHAR(3) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'ACCEPTED', 'DECLINED', 'EXPIRED', 'CANCELLED')),
    expires_at TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- 7. CHAT & REALTIME
-- ============================================================================

CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    listing_id UUID REFERENCES listings(id) ON DELETE SET NULL,
    order_id UUID REFERENCES orders(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE conversation_participants (
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    last_read_sequence BIGINT NOT NULL DEFAULT 0 CHECK (last_read_sequence >= 0),
    joined_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (conversation_id, user_id)
);

CREATE TABLE chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    sender_user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    client_message_id UUID NOT NULL UNIQUE,
    sequence_no BIGINT NOT NULL,
    message_type VARCHAR(30) NOT NULL DEFAULT 'TEXT' CHECK (message_type IN ('TEXT', 'IMAGE', 'ORDER_CARD', 'OFFER_CARD', 'SYSTEM_NOTICE')),
    body TEXT NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'SENT' CHECK (status IN ('SENT', 'DELIVERED', 'READ', 'FLAGGED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_conversation_sequence UNIQUE (conversation_id, sequence_no)
);

CREATE INDEX idx_chat_messages_conv ON chat_messages(conversation_id, sequence_no);

CREATE TABLE chat_attachments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    message_id UUID NOT NULL REFERENCES chat_messages(id) ON DELETE CASCADE,
    media_asset_id UUID NOT NULL REFERENCES media_assets(id) ON DELETE RESTRICT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- 8. PAYMENTS & WEBHOOKS
-- ============================================================================

CREATE TABLE payment_providers (
    id VARCHAR(50) PRIMARY KEY, -- e.g. 'stripe_sandbox', 'adyen_sandbox', 'test_provider'
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'SANDBOX_ONLY', 'INACTIVE')),
    supported_countries JSONB NOT NULL DEFAULT '["KR", "US", "JP", "EU", "GB"]'::jsonb,
    configuration_reference VARCHAR(255) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE payment_intents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE RESTRICT,
    provider_id VARCHAR(50) NOT NULL REFERENCES payment_providers(id) ON DELETE RESTRICT,
    provider_payment_reference VARCHAR(255) NOT NULL UNIQUE,
    amount_minor BIGINT NOT NULL CHECK (amount_minor > 0),
    currency_code VARCHAR(3) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'CHECKOUT_CREATED' CHECK (status IN (
        'CHECKOUT_CREATED',
        'AUTHORIZATION_PENDING',
        'AUTHORIZED',
        'CAPTURED',
        'FAILED',
        'CANCELLED'
    )),
    idempotency_key VARCHAR(255) NOT NULL UNIQUE,
    checkout_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_payment_intents_order ON payment_intents(order_id);

CREATE TABLE payment_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider_id VARCHAR(50) NOT NULL REFERENCES payment_providers(id) ON DELETE RESTRICT,
    provider_event_id VARCHAR(255) NOT NULL UNIQUE, -- Crucial for idempotency
    payment_intent_id UUID REFERENCES payment_intents(id) ON DELETE SET NULL,
    event_type VARCHAR(100) NOT NULL,
    payload_reference JSONB NOT NULL,
    verified_at TIMESTAMPTZ,
    processed_at TIMESTAMPTZ,
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'PROCESSED', 'FAILED', 'IGNORED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE refunds (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE RESTRICT,
    payment_intent_id UUID NOT NULL REFERENCES payment_intents(id) ON DELETE RESTRICT,
    provider_refund_reference VARCHAR(255) UNIQUE,
    amount_minor BIGINT NOT NULL CHECK (amount_minor > 0),
    currency_code VARCHAR(3) NOT NULL,
    reason_code VARCHAR(50) NOT NULL CHECK (reason_code IN ('BUYER_CANCEL', 'SELLER_CANCEL', 'DISPUTE_DECISION', 'FRAUD_SUSPECTED', 'ADMIN_ADJUSTMENT')),
    status VARCHAR(30) NOT NULL DEFAULT 'REQUESTED' CHECK (status IN ('REQUESTED', 'APPROVED_BY_OPS', 'SUBMITTED_TO_PSP', 'COMPLETED', 'FAILED', 'REJECTED')),
    requested_by UUID REFERENCES users(id) ON DELETE SET NULL,
    approved_by UUID REFERENCES users(id) ON DELETE SET NULL,
    requested_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);

CREATE TABLE chargebacks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE RESTRICT,
    provider_case_reference VARCHAR(255) NOT NULL UNIQUE,
    amount_minor BIGINT NOT NULL CHECK (amount_minor > 0),
    currency_code VARCHAR(3) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'UNDER_REVIEW', 'WON', 'LOST')),
    opened_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    resolved_at TIMESTAMPTZ
);

-- ============================================================================
-- 9. INTERNAL FINANCIAL RECONCILIATION & DOUBLE-ENTRY LEDGER
-- ============================================================================

CREATE TABLE ledger_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    account_code VARCHAR(50) NOT NULL UNIQUE,
    account_type VARCHAR(30) NOT NULL CHECK (account_type IN ('ASSET', 'LIABILITY', 'EQUITY', 'REVENUE', 'EXPENSE')),
    currency_code VARCHAR(3) NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE ledger_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reference_type VARCHAR(50) NOT NULL CHECK (reference_type IN ('ORDER_PAYMENT', 'ORDER_REFUND', 'SELLER_PAYOUT', 'PLATFORM_FEE_COLLECTION', 'CHARGEBACK')),
    reference_id UUID NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'POSTED' CHECK (status IN ('PENDING', 'POSTED', 'VOIDED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_ledger_transactions_ref ON ledger_transactions(reference_type, reference_id);

CREATE TABLE ledger_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ledger_transaction_id UUID NOT NULL REFERENCES ledger_transactions(id) ON DELETE CASCADE,
    ledger_account_id UUID NOT NULL REFERENCES ledger_accounts(id) ON DELETE RESTRICT,
    debit_minor BIGINT NOT NULL DEFAULT 0 CHECK (debit_minor >= 0),
    credit_minor BIGINT NOT NULL DEFAULT 0 CHECK (credit_minor >= 0),
    currency_code VARCHAR(3) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_ledger_entry_positive CHECK (debit_minor > 0 OR credit_minor > 0),
    CONSTRAINT chk_ledger_entry_exclusive CHECK (NOT (debit_minor > 0 AND credit_minor > 0))
);

CREATE INDEX idx_ledger_entries_account ON ledger_entries(ledger_account_id);
CREATE INDEX idx_ledger_entries_tx ON ledger_entries(ledger_transaction_id);

CREATE TABLE payout_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    seller_id UUID NOT NULL REFERENCES sellers(id) ON DELETE RESTRICT,
    provider_id VARCHAR(50) NOT NULL,
    provider_payout_reference VARCHAR(255) UNIQUE,
    amount_minor BIGINT NOT NULL CHECK (amount_minor > 0),
    currency_code VARCHAR(3) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'REQUESTED' CHECK (status IN (
        'REQUESTED',
        'APPROVED_BY_FINANCE',
        'SUBMITTED_TO_PROVIDER',
        'PAID',
        'FAILED',
        'HELD'
    )),
    approved_by UUID REFERENCES users(id) ON DELETE SET NULL,
    requested_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);

CREATE INDEX idx_payout_requests_seller ON payout_requests(seller_id);

CREATE TABLE settlement_batches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    provider_id VARCHAR(50) NOT NULL,
    settlement_period_start TIMESTAMPTZ NOT NULL,
    settlement_period_end TIMESTAMPTZ NOT NULL,
    currency_code VARCHAR(3) NOT NULL,
    reported_total_minor BIGINT NOT NULL DEFAULT 0,
    reconciled_total_minor BIGINT NOT NULL DEFAULT 0,
    status VARCHAR(30) NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'BALANCED', 'DISCREPANCY_FLAGGED', 'CLOSED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE reconciliation_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    settlement_batch_id UUID NOT NULL REFERENCES settlement_batches(id) ON DELETE CASCADE,
    order_id UUID REFERENCES orders(id) ON DELETE SET NULL,
    payment_intent_id UUID REFERENCES payment_intents(id) ON DELETE SET NULL,
    payout_request_id UUID REFERENCES payout_requests(id) ON DELETE SET NULL,
    difference_minor BIGINT NOT NULL DEFAULT 0,
    currency_code VARCHAR(3) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'RESOLVED', 'MANUAL_REVIEW_REQUIRED')),
    notes TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- 10. DELIVERY & PROOF SYSTEM
-- ============================================================================

CREATE TABLE deliveries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL UNIQUE REFERENCES orders(id) ON DELETE CASCADE,
    delivery_method VARCHAR(50) NOT NULL,
    seller_claimed_at TIMESTAMPTZ,
    buyer_confirmed_at TIMESTAMPTZ,
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING' CHECK (status IN (
        'PENDING',
        'DELIVERY_CLAIMED',
        'CONFIRMED',
        'DISPUTED',
        'CANCELLED'
    )),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE delivery_evidence (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    delivery_id UUID NOT NULL REFERENCES deliveries(id) ON DELETE CASCADE,
    submitted_by_user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    media_asset_id UUID NOT NULL REFERENCES media_assets(id) ON DELETE RESTRICT,
    evidence_type VARCHAR(50) NOT NULL CHECK (evidence_type IN ('SCREENSHOT', 'VIDEO_CLIP', 'TRANSFER_LOG', 'CODE_RECEIPT')),
    description TEXT,
    checksum VARCHAR(64) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE delivery_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    delivery_id UUID NOT NULL REFERENCES deliveries(id) ON DELETE CASCADE,
    reviewed_by UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    review_result VARCHAR(30) NOT NULL CHECK (review_result IN ('ACCEPTED', 'REJECTED', 'NEEDS_MORE_EVIDENCE')),
    reason TEXT,
    reviewed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- 11. DISPUTES & ESCALATION
-- ============================================================================

CREATE TABLE disputes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE RESTRICT,
    opened_by_user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    reason_code VARCHAR(50) NOT NULL CHECK (reason_code IN (
        'NON_DELIVERY',
        'PARTIAL_DELIVERY',
        'WRONG_ITEM',
        'WRONG_QUANTITY',
        'NOT_AS_DESCRIBED',
        'UNAUTHORIZED_PAYMENT',
        'PAYMENT_DISPUTE',
        'SELLER_NON_RESPONSE',
        'BUYER_NON_RESPONSE',
        'OTHER'
    )),
    description TEXT NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'OPEN' CHECK (status IN (
        'OPEN',
        'UNDER_REVIEW',
        'EVIDENCE_REQUIRED',
        'DECIDED',
        'APPEALED',
        'CLOSED'
    )),
    assigned_admin_id UUID REFERENCES users(id) ON DELETE SET NULL,
    opened_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    resolved_at TIMESTAMPTZ
);

CREATE INDEX idx_disputes_order ON disputes(order_id);
CREATE INDEX idx_disputes_status ON disputes(status);

CREATE TABLE dispute_evidence (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dispute_id UUID NOT NULL REFERENCES disputes(id) ON DELETE CASCADE,
    submitted_by_user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    media_asset_id UUID REFERENCES media_assets(id) ON DELETE RESTRICT,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE dispute_decisions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dispute_id UUID NOT NULL REFERENCES disputes(id) ON DELETE CASCADE,
    decision_code VARCHAR(50) NOT NULL CHECK (decision_code IN (
        'BUYER_FAVOR_FULL_REFUND',
        'BUYER_FAVOR_PARTIAL_REFUND',
        'SELLER_FAVOR_COMPLETE_ORDER',
        'DISMISSED'
    )),
    decision_reason TEXT NOT NULL,
    decided_by UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    approval_status VARCHAR(30) NOT NULL DEFAULT 'PENDING_APPROVAL' CHECK (approval_status IN ('PENDING_APPROVAL', 'APPROVED', 'REJECTED')),
    approved_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE dispute_appeals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    dispute_id UUID NOT NULL REFERENCES disputes(id) ON DELETE CASCADE,
    appellant_user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    reason TEXT NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'ACCEPTED', 'REJECTED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    resolved_at TIMESTAMPTZ
);

-- ============================================================================
-- 12. TRUST, REVIEWS & RISK ENGINE
-- ============================================================================

CREATE TABLE seller_reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL UNIQUE REFERENCES orders(id) ON DELETE CASCADE,
    buyer_user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    seller_id UUID NOT NULL REFERENCES sellers(id) ON DELETE RESTRICT,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    body TEXT,
    status VARCHAR(30) NOT NULL DEFAULT 'PUBLISHED' CHECK (status IN ('PUBLISHED', 'MODERATED', 'HIDDEN')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE risk_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    order_id UUID REFERENCES orders(id) ON DELETE SET NULL,
    event_type VARCHAR(100) NOT NULL,
    risk_level VARCHAR(30) NOT NULL CHECK (risk_level IN ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL')),
    action VARCHAR(50) NOT NULL CHECK (action IN ('ALLOW', 'REQUEST_VERIFICATION', 'MANUAL_REVIEW', 'TEMPORARILY_HOLD', 'BLOCK')),
    status VARCHAR(30) NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'INVESTIGATING', 'RESOLVED', 'FALSE_POSITIVE')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_risk_events_user ON risk_events(user_id);
CREATE INDEX idx_risk_events_level ON risk_events(risk_level, status);

CREATE TABLE risk_decisions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    risk_event_id UUID NOT NULL REFERENCES risk_events(id) ON DELETE CASCADE,
    decision VARCHAR(50) NOT NULL,
    reason_codes JSONB NOT NULL DEFAULT '[]'::jsonb,
    reviewed_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================================
-- 13. CONTENT & SUPPORT
-- ============================================================================

CREATE TABLE support_tickets (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    order_id UUID REFERENCES orders(id) ON DELETE SET NULL,
    subject VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'ASSIGNED', 'PENDING_USER', 'RESOLVED', 'CLOSED')),
    assigned_admin_id UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE support_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    ticket_id UUID NOT NULL REFERENCES support_tickets(id) ON DELETE CASCADE,
    sender_type VARCHAR(30) NOT NULL CHECK (sender_type IN ('USER', 'ADMIN', 'SYSTEM')),
    sender_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
    body TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE articles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    slug VARCHAR(100) NOT NULL,
    locale VARCHAR(10) NOT NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'DRAFT' CHECK (status IN ('DRAFT', 'PUBLISHED', 'ARCHIVED')),
    published_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_article_slug_locale UNIQUE (slug, locale)
);

-- ============================================================================
-- 14. SYSTEM, RBAC & ADMIN
-- ============================================================================

CREATE TABLE admin_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL
);

CREATE TABLE admin_permissions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    code VARCHAR(100) NOT NULL UNIQUE,
    resource VARCHAR(100) NOT NULL,
    action VARCHAR(50) NOT NULL
);

CREATE TABLE admin_user_roles (
    admin_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES admin_roles(id) ON DELETE CASCADE,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (admin_user_id, role_id)
);

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    actor_type VARCHAR(50) NOT NULL CHECK (actor_type IN ('USER', 'ADMIN', 'SYSTEM', 'PSP_WEBHOOK')),
    actor_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    resource_type VARCHAR(100) NOT NULL,
    resource_id VARCHAR(100) NOT NULL,
    result VARCHAR(30) NOT NULL CHECK (result IN ('SUCCESS', 'FAILURE', 'DENIED')),
    request_id VARCHAR(100),
    metadata_redacted JSONB NOT NULL DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_resource ON audit_logs(resource_type, resource_id);
CREATE INDEX idx_audit_logs_actor ON audit_logs(actor_id, created_at);

CREATE TABLE country_compliance_policies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    country_code VARCHAR(2) NOT NULL,
    policy_type VARCHAR(100) NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'RESTRICTED', 'PROHIBITED')),
    document_reference VARCHAR(255),
    reviewed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_country_compliance UNIQUE (country_code, policy_type)
);

CREATE TABLE fee_policies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    country_code VARCHAR(2) NOT NULL,
    game_id UUID REFERENCES games(id) ON DELETE SET NULL,
    product_type VARCHAR(50),
    fee_type VARCHAR(50) NOT NULL CHECK (fee_type IN ('PLATFORM_BUYER', 'PLATFORM_SELLER', 'PAYMENT_PROCESSING')),
    fee_rate NUMERIC(6, 4) NOT NULL DEFAULT 0.0000, -- e.g. 0.0500 for 5%
    fixed_fee_minor BIGINT NOT NULL DEFAULT 0,
    currency_code VARCHAR(3) NOT NULL,
    effective_from TIMESTAMPTZ NOT NULL,
    effective_until TIMESTAMPTZ,
    approved_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE feature_flags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    key VARCHAR(100) NOT NULL,
    environment VARCHAR(30) NOT NULL DEFAULT 'all',
    country_code VARCHAR(2),
    enabled BOOLEAN NOT NULL DEFAULT FALSE,
    updated_by UUID REFERENCES users(id) ON DELETE SET NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_feature_flags UNIQUE (key, environment, country_code)
);

CREATE TABLE outbox_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_type VARCHAR(100) NOT NULL,
    aggregate_id VARCHAR(100) NOT NULL,
    payload JSONB NOT NULL,
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'PROCESSING', 'PUBLISHED', 'FAILED')),
    attempt_count INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    processed_at TIMESTAMPTZ
);

CREATE INDEX idx_outbox_events_status ON outbox_events(status, created_at);
