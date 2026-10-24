-- Database Fixtures: 04_fee_policies.sql
-- Fee Policy seed table per Article 16.5 & Article 27.14

-- Default Global Platform Fee for Sellers: 5.0%
INSERT INTO fee_policies (
    id, country_code, game_id, product_type,
    fee_type, fee_rate, fixed_fee_minor, currency_code, effective_from
) VALUES 
('30000000-0000-0000-0000-000000000001', 'US', NULL, NULL, 'PLATFORM_SELLER', 0.0500, 0, 'USD', '2026-01-01 00:00:00Z'),
('30000000-0000-0000-0000-000000000002', 'KR', NULL, NULL, 'PLATFORM_SELLER', 0.0500, 0, 'KRW', '2026-01-01 00:00:00Z'),
('30000000-0000-0000-0000-000000000003', 'EU', NULL, NULL, 'PLATFORM_SELLER', 0.0500, 0, 'EUR', '2026-01-01 00:00:00Z'),
-- Buyer Platform Fee: 0% (Promotional zero buyer fee)
('30000000-0000-0000-0000-000000000004', 'US', NULL, NULL, 'PLATFORM_BUYER', 0.0000, 0, 'USD', '2026-01-01 00:00:00Z'),
('30000000-0000-0000-0000-000000000005', 'KR', NULL, NULL, 'PLATFORM_BUYER', 0.0000, 0, 'KRW', '2026-01-01 00:00:00Z');
