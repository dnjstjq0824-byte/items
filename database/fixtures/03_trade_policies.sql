-- Database Fixtures: 03_trade_policies.sql
-- Seed Canonical Trade Policies Demonstrating Compliance Gating

-- 1. Ethereal Odyssey + US + GAME_ITEM -> APPROVED & ENABLED
INSERT INTO game_trade_policies (
    id, game_id, country_code, product_type,
    legal_review_status, publisher_policy_status, payment_partner_status,
    trade_enabled, reviewed_at
) VALUES (
    '20000000-0000-0000-0000-000000000001',
    'c0000000-0000-0000-0000-000000000001',
    'US',
    'GAME_ITEM',
    'APPROVED',
    'PERMITTED',
    'APPROVED',
    TRUE,
    NOW()
) ON CONFLICT (game_id, country_code, product_type) DO NOTHING;

-- 2. Ethereal Odyssey + KR + GAME_ITEM -> APPROVED & ENABLED (In-game transferable items without illegal gambling mechanics)
INSERT INTO game_trade_policies (
    id, game_id, country_code, product_type,
    legal_review_status, publisher_policy_status, payment_partner_status,
    trade_enabled, reviewed_at
) VALUES (
    '20000000-0000-0000-0000-000000000002',
    'c0000000-0000-0000-0000-000000000001',
    'KR',
    'GAME_ITEM',
    'APPROVED',
    'PERMITTED',
    'APPROVED',
    TRUE,
    NOW()
) ON CONFLICT (game_id, country_code, product_type) DO NOTHING;

-- 3. Ethereal Odyssey + KR + GAME_CURRENCY -> REVIEW_REQUIRED & DISABLED (Article 3.3 / Korean Game Industry Promotion Act compliance gate)
INSERT INTO game_trade_policies (
    id, game_id, country_code, product_type,
    legal_review_status, publisher_policy_status, payment_partner_status,
    trade_enabled, reviewed_at
) VALUES (
    '20000000-0000-0000-0000-000000000003',
    'c0000000-0000-0000-0000-000000000001',
    'KR',
    'GAME_CURRENCY',
    'REVIEW_REQUIRED',
    'REVIEW_REQUIRED',
    'PENDING',
    FALSE,
    NOW()
) ON CONFLICT (game_id, country_code, product_type) DO NOTHING;

-- 4. Ethereal Odyssey + ALL COUNTRIES + GAME_ACCOUNT -> PROHIBITED & DISABLED (Article 3.4: Account trade disabled in v1.0)
INSERT INTO game_trade_policies (
    id, game_id, country_code, product_type,
    legal_review_status, publisher_policy_status, payment_partner_status,
    trade_enabled, reviewed_at
) VALUES 
('20000000-0000-0000-0000-000000000004', 'c0000000-0000-0000-0000-000000000001', 'US', 'GAME_ACCOUNT', 'PROHIBITED', 'PROHIBITED', 'PROHIBITED', FALSE, NOW()),
('20000000-0000-0000-0000-000000000005', 'c0000000-0000-0000-0000-000000000001', 'KR', 'GAME_ACCOUNT', 'PROHIBITED', 'PROHIBITED', 'PROHIBITED', FALSE, NOW()),
('20000000-0000-0000-0000-000000000006', 'c0000000-0000-0000-0000-000000000001', 'JP', 'GAME_ACCOUNT', 'PROHIBITED', 'PROHIBITED', 'PROHIBITED', FALSE, NOW())
ON CONFLICT (game_id, country_code, product_type) DO NOTHING;

-- 5. Official Gift Code -> APPROVED & ENABLED
INSERT INTO game_trade_policies (
    id, game_id, country_code, product_type,
    legal_review_status, publisher_policy_status, payment_partner_status,
    trade_enabled, reviewed_at
) VALUES (
    '20000000-0000-0000-0000-000000000007',
    'c0000000-0000-0000-0000-000000000001',
    'US',
    'OFFICIAL_GIFT_CODE',
    'APPROVED',
    'PERMITTED',
    'APPROVED',
    TRUE,
    NOW()
) ON CONFLICT (game_id, country_code, product_type) DO NOTHING;

