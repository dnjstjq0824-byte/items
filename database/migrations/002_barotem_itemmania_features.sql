-- BN GAMEEX: BaroTem & ItemMania Feature Extension Schema
-- Migration: 002_barotem_itemmania_features.sql
-- Enables P2P Trade Articles (Sell/Buy), User Mileage Wallets, 24/7 Withdrawal Ledger,
-- 200% Safety Compensation Guarantees, and In-Game Trade Handover Cancellation Mediation.

-- ============================================================================
-- 1. P2P TRADE ARTICLES (팝니다 / 삽니다 게시글 원장)
-- ============================================================================

CREATE TABLE IF NOT EXISTS trade_articles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    article_type VARCHAR(10) NOT NULL CHECK (article_type IN ('SELL', 'BUY')), -- 팝니다 / 삽니다
    game_id UUID NOT NULL REFERENCES games(id),
    server_id UUID REFERENCES game_servers(id),
    category VARCHAR(30) NOT NULL CHECK (category IN ('GAME_MONEY', 'GAME_ITEM', 'PACKAGE_CODE', 'APPROVED_GOODS')),
    title VARCHAR(255) NOT NULL,
    content TEXT,
    unit_name VARCHAR(50) NOT NULL DEFAULT '개', -- 예: '골드', '만 메소', '다이아', '개'
    unit_price_minor BIGINT NOT NULL CHECK (unit_price_minor >= 0),
    total_quantity BIGINT NOT NULL CHECK (total_quantity > 0),
    available_quantity BIGINT NOT NULL CHECK (available_quantity >= 0),
    min_trade_quantity BIGINT NOT NULL DEFAULT 1 CHECK (min_trade_quantity > 0),
    max_trade_quantity BIGINT NOT NULL CHECK (max_trade_quantity >= min_trade_quantity),
    is_split_trade_enabled BOOLEAN NOT NULL DEFAULT FALSE, -- 분할판매 가능 여부
    character_name VARCHAR(100) NOT NULL, -- 판매자/구매자 인게임 캐릭터명
    contact_safety_phone VARCHAR(50), -- 0504 가상 안심번호
    safety_warranty_type VARCHAR(30) NOT NULL DEFAULT 'STANDARD' CHECK (safety_warranty_type IN ('STANDARD', '200_PERCENT_GUARANTEE')),
    safety_warranty_fee_rate NUMERIC(5, 2) NOT NULL DEFAULT 0.0,
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE', 'TRADING', 'COMPLETED', 'CANCELLED', 'PAUSED')),
    view_count BIGINT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_trade_articles_lookup ON trade_articles(game_id, server_id, article_type, category, status);
CREATE INDEX idx_trade_articles_user ON trade_articles(user_id, status);

-- ============================================================================
-- 2. USER MILEAGE & CASH WALLET LEDGER (마일리지 및 예치금 원장)
-- ============================================================================

CREATE TABLE IF NOT EXISTS user_mileage_wallets (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    currency_code VARCHAR(3) NOT NULL DEFAULT 'KRW',
    balance_minor BIGINT NOT NULL DEFAULT 0 CHECK (balance_minor >= 0), -- 총 보유 마일리지
    withdrawable_minor BIGINT NOT NULL DEFAULT 0 CHECK (withdrawable_minor >= 0), -- 출금 가능 마일리지
    escrow_locked_minor BIGINT NOT NULL DEFAULT 0 CHECK (escrow_locked_minor >= 0), -- 거래 중 묶인 마일리지
    deposit_pledge_minor BIGINT NOT NULL DEFAULT 0 CHECK (deposit_pledge_minor >= 0), -- 안전거래 보증금
    version BIGINT NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT check_wallet_balance_consistency CHECK (balance_minor = withdrawable_minor + escrow_locked_minor + deposit_pledge_minor)
);

CREATE TABLE IF NOT EXISTS mileage_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    wallet_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    tx_type VARCHAR(35) NOT NULL CHECK (tx_type IN (
        'CHARGE_PG',                    -- PG사/가상계좌 마일리지 충전
        'PURCHASE_ESCROW_LOCK',         -- 구매신청 대금 에스크로 잠금
        'PURCHASE_REFUND',              -- 거래취소 구매자 에스크로 환불
        'SALE_PROCEEDS_SETTLED',        -- 거래완료 판매자 정산 입금
        'PLATFORM_FEE_DEDUCTION',       -- 판매 수수료 차감
        'WITHDRAWAL_REQUEST_HOLD',      -- 은행 계좌 출금신청 보류
        'WITHDRAWAL_COMPLETED',         -- 은행 이체 완료 확정
        'WITHDRAWAL_REJECTED_REFUND',   -- 출금 반려 복구
        'COMPENSATION_200_PAYOUT'       -- 200% 보상금 지급
    )),
    amount_minor BIGINT NOT NULL, -- 양수(증가) 또는 음수(감소)
    balance_after_minor BIGINT NOT NULL,
    reference_id VARCHAR(100), -- order_id, order_number, 또는 withdrawal_id
    description TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_mileage_tx_user ON mileage_transactions(wallet_user_id, created_at DESC);
CREATE INDEX idx_mileage_tx_ref ON mileage_transactions(reference_id);

-- ============================================================================
-- 3. REAL-TIME MILEAGE WITHDRAWAL REQUESTS (24시간 은행 출금 신청 원장)
-- ============================================================================

CREATE TABLE IF NOT EXISTS mileage_withdrawal_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    bank_name VARCHAR(50) NOT NULL,
    account_number VARCHAR(100) NOT NULL,
    account_holder_name VARCHAR(100) NOT NULL,
    amount_minor BIGINT NOT NULL CHECK (amount_minor >= 10000), -- 최소 출금단위 10,000원
    fee_minor BIGINT NOT NULL DEFAULT 1000, -- 이체수수료 1,000원
    net_payout_minor BIGINT NOT NULL CHECK (net_payout_minor > 0),
    status VARCHAR(30) NOT NULL DEFAULT 'PENDING' CHECK (status IN (
        'PENDING',                      -- 출금 접수
        'FDS_REVIEW',                   -- 이상금융거래 탐지 수동 심사
        'APPROVED',                     -- 관리자/시스템 승인
        'TRANSFERRED',                  -- 펌뱅킹 이체 완료
        'REJECTED'                      -- 출금 반려
    )),
    rejection_reason TEXT,
    fds_risk_score INT DEFAULT 0,
    reviewed_by UUID REFERENCES users(id),
    reviewed_at TIMESTAMPTZ,
    bank_tx_reference VARCHAR(100),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_withdrawals_status ON mileage_withdrawal_requests(status, created_at DESC);
CREATE INDEX idx_withdrawals_user ON mileage_withdrawal_requests(user_id);

-- ============================================================================
-- 4. TRADE CANCELLATION REQUESTS & MEDIATION (거래취소 및 중재 요청서)
-- ============================================================================

CREATE TABLE IF NOT EXISTS trade_cancellation_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    requested_by UUID NOT NULL REFERENCES users(id),
    reason_category VARCHAR(50) NOT NULL CHECK (reason_category IN (
        'SELLER_NO_RESPONSE',           -- 판매자 장기 미응답/잠수
        'BUYER_NO_RESPONSE',            -- 구매자 장기 미응답
        'CHARACTER_NAME_MISMATCH',      -- 인게임 캐릭터명 불일치
        'PRICE_OR_QUANTITY_DISAGREEMENT',-- 수량/금액 오기재
        'MUTUAL_AGREEMENT',             -- 상호 거래 취소 합의
        'SUSPECTED_FRAUD'               -- 사칭/사기 의심
    )),
    reason_detail TEXT NOT NULL,
    counterparty_consent VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (counterparty_consent IN ('PENDING', 'AGREED', 'REJECTED', 'ADMIN_FORCED')),
    admin_arbiter_id UUID REFERENCES users(id),
    admin_decision VARCHAR(30),
    admin_note TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'OPEN' CHECK (status IN ('OPEN', 'RESOLVED_CANCELLED', 'RESOLVED_REJECTED')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    resolved_at TIMESTAMPTZ
);

CREATE INDEX idx_cancellation_order ON trade_cancellation_requests(order_id);
CREATE INDEX idx_cancellation_status ON trade_cancellation_requests(status);

-- ============================================================================
-- 5. 200% SAFETY COMPENSATION WARRANTY CLAIMS (바로템형 200% 안심보상 심사 원장)
-- ============================================================================

CREATE TABLE IF NOT EXISTS safety_warranty_claims (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    claimant_id UUID NOT NULL REFERENCES users(id),
    claim_type VARCHAR(50) NOT NULL CHECK (claim_type IN (
        '200_PERCENT_RECOVERY_ACCIDENT',-- 거래 후 게임사 회수/정지 사고
        'ACCOUNT_RETRIEVAL_FRAUD',      -- 1대 본주 계정 회수 사기
        'DUPLICATED_CURRENCY_SEIZURE'   -- 복제 버그 머니 압류 사고
    )),
    damage_amount_minor BIGINT NOT NULL,
    compensation_requested_minor BIGINT NOT NULL, -- 피해액의 200%
    compensation_awarded_minor BIGINT DEFAULT 0,
    evidence_summary TEXT NOT NULL,
    game_inquiry_ticket_number VARCHAR(100), -- 게임사 고객센터 문의 번호
    status VARCHAR(30) NOT NULL DEFAULT 'SUBMITTED' CHECK (status IN (
        'SUBMITTED',                    -- 사고 접수
        'INVESTIGATING',                -- 진위 조사 중
        'APPROVED',                     -- 보상 승인
        'PAYOUT_COMPLETED',             -- 200% 보상금 지급 완료
        'REJECTED'                      -- 허위/기각
    )),
    investigator_id UUID REFERENCES users(id),
    decision_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    decided_at TIMESTAMPTZ
);

CREATE INDEX idx_safety_claims_order ON safety_warranty_claims(order_id);
CREATE INDEX idx_safety_claims_status ON safety_warranty_claims(status);
