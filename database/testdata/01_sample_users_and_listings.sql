-- Database Testdata: 01_sample_users_and_listings.sql
-- Seed sample users, verified sellers, and compliant listings

-- 1. Users (Passwords hashed for: 'Password123!')
-- Admin User
INSERT INTO users (id, email, password_hash, display_name, country_code, locale, preferred_currency, status, email_verified_at) VALUES
('50000000-0000-0000-0000-000000000001', 'admin@bookingnetwork.example.com', '$2a$10$7EqJtq98hPqEX7fNZaFWoO.d0bE309z5E5q4xP3o5uKxO0GqWkZ6a', 'SuperOpsAdmin', 'US', 'en', 'USD', 'ACTIVE', NOW())
ON CONFLICT (email) DO NOTHING;

-- Verified Seller User
INSERT INTO users (id, email, password_hash, display_name, country_code, locale, preferred_currency, status, email_verified_at) VALUES
('50000000-0000-0000-0000-000000000002', 'seller1@gametrade.example.com', '$2a$10$7EqJtq98hPqEX7fNZaFWoO.d0bE309z5E5q4xP3o5uKxO0GqWkZ6a', 'AetherTraderPro', 'US', 'en', 'USD', 'ACTIVE', NOW())
ON CONFLICT (email) DO NOTHING;

-- Buyer User
INSERT INTO users (id, email, password_hash, display_name, country_code, locale, preferred_currency, status, email_verified_at) VALUES
('50000000-0000-0000-0000-000000000003', 'buyer1@gamer.example.com', '$2a$10$7EqJtq98hPqEX7fNZaFWoO.d0bE309z5E5q4xP3o5uKxO0GqWkZ6a', 'DragonSlayer99', 'US', 'en', 'USD', 'ACTIVE', NOW())
ON CONFLICT (email) DO NOTHING;

-- Assign Admin Role
INSERT INTO admin_user_roles (admin_user_id, role_id) VALUES
('50000000-0000-0000-0000-000000000001', 'a0000000-0000-0000-0000-000000000001')
ON CONFLICT DO NOTHING;

-- 2. Seller Profile
INSERT INTO sellers (
    id, user_id, seller_type, display_name, country_code,
    verification_status, sales_status, completed_orders_count, rating_score_sum, rating_count
) VALUES (
    '60000000-0000-0000-0000-000000000001',
    '50000000-0000-0000-0000-000000000002',
    'PRO_SELLER',
    'AetherTraderPro',
    'US',
    'VERIFIED',
    'ACTIVE',
    142,
    698, -- 698/142 ~ 4.92 rating
    142
) ON CONFLICT (user_id) DO NOTHING;

-- Seller Payout Account (Tokenized reference via mock PSP)
INSERT INTO seller_payout_accounts (
    id, seller_id, provider_id, provider_account_reference, currency_code, verification_status, status
) VALUES (
    '70000000-0000-0000-0000-000000000001',
    '60000000-0000-0000-0000-000000000001',
    'stripe_sandbox',
    'acct_tok_sandbox_seller_001',
    'USD',
    'VERIFIED',
    'ACTIVE'
) ON CONFLICT (seller_id, provider_id, provider_account_reference) DO NOTHING;

-- 3. Compliant Listings
-- Listing 1: Transferable Mythic Blade in Ethereal Odyssey (NA-ALTAIR Server)
INSERT INTO listings (
    id, seller_id, game_id, game_platform_id, game_region_id, game_server_id,
    product_type, title, description, unit_price_minor, currency_code,
    minimum_quantity, maximum_quantity, available_quantity, reserved_quantity, sold_quantity,
    delivery_method, delivery_eta_minutes, status, policy_approval_id, published_at
) VALUES (
    '80000000-0000-0000-0000-000000000001',
    '60000000-0000-0000-0000-000000000001',
    'c0000000-0000-0000-0000-000000000001',
    'd0000000-0000-0000-0000-000000000001',
    'e0000000-0000-0000-0000-000000000001',
    'f0000000-0000-0000-0000-000000000001',
    'GAME_ITEM',
    '+12 Celestial Greatsword (Trade-Permitted)',
    'Verified transferable in-game item on Altair Prime. Full evidence recorded upon in-game manual trade.',
    4500, -- $45.00
    'USD',
    1,
    5,
    3,
    0,
    12,
    'IN_GAME_MANUAL',
    15,
    'ACTIVE',
    '20000000-0000-0000-0000-000000000001',
    NOW()
) ON CONFLICT (id) DO NOTHING;

-- Listing 2: Official Digital Publisher Gift Code (Ethereal Odyssey 30-Day Pass)
INSERT INTO listings (
    id, seller_id, game_id, game_platform_id, game_region_id, game_server_id,
    product_type, title, description, unit_price_minor, currency_code,
    minimum_quantity, maximum_quantity, available_quantity, reserved_quantity, sold_quantity,
    delivery_method, delivery_eta_minutes, status, policy_approval_id, published_at
) VALUES (
    '80000000-0000-0000-0000-000000000002',
    '60000000-0000-0000-0000-000000000001',
    'c0000000-0000-0000-0000-000000000001',
    'd0000000-0000-0000-0000-000000000001',
    'e0000000-0000-0000-0000-000000000001',
    NULL,
    'OFFICIAL_GIFT_CODE',
    'Official 30-Day Adventurer Pass Code (Global/NA)',
    'Authorized retail digital activation key. Delivered instantly with digital receipt verification.',
    1499, -- $14.99
    'USD',
    1,
    20,
    15,
    0,
    45,
    'AUTHORIZED_DIGITAL_CODE',
    5,
    'ACTIVE',
    '20000000-0000-0000-0000-000000000007',
    NOW()
) ON CONFLICT (id) DO NOTHING;
