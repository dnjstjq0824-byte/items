-- Database Fixtures: 05_ledger_accounts.sql
-- Chart of Accounts for Internal Double-Entry Accounting Ledger (Article 16.6 & 22.8)

INSERT INTO ledger_accounts (id, account_code, account_type, currency_code, description) VALUES
-- USD Accounts
('40000000-0000-0000-0000-000000000001', '1010-USD-PSP-CLEARING', 'ASSET', 'USD', 'Funds held by external licensed PSP pending settlement'),
('40000000-0000-0000-0000-000000000002', '2010-USD-SELLER-PAYABLE', 'LIABILITY', 'USD', 'Liability owed to verified sellers for completed deliveries'),
('40000000-0000-0000-0000-000000000003', '4010-USD-FEE-REVENUE', 'REVENUE', 'USD', 'Marketplace platform fee commission revenue'),
('40000000-0000-0000-0000-000000000004', '2020-USD-REFUND-PAYABLE', 'LIABILITY', 'USD', 'Liability for pending refunds to buyers'),

-- KRW Accounts
('40000000-0000-0000-0000-000000000005', '1010-KRW-PSP-CLEARING', 'ASSET', 'KRW', 'Funds held by external licensed PSP pending settlement in KRW'),
('40000000-0000-0000-0000-000000000006', '2010-KRW-SELLER-PAYABLE', 'LIABILITY', 'KRW', 'Liability owed to verified sellers for completed deliveries in KRW'),
('40000000-0000-0000-0000-000000000007', '4010-KRW-FEE-REVENUE', 'REVENUE', 'KRW', 'Marketplace platform fee commission revenue in KRW'),
('40000000-0000-0000-0000-000000000008', '2020-KRW-REFUND-PAYABLE', 'LIABILITY', 'KRW', 'Liability for pending refunds to buyers in KRW')
ON CONFLICT (account_code) DO NOTHING;

-- Seed Sandbox Payment Provider
INSERT INTO payment_providers (id, code, name, status, supported_countries, configuration_reference) VALUES
('stripe_sandbox', 'STRIPE_SANDBOX', 'Stripe Connect (Sandbox Test Mode)', 'SANDBOX_ONLY', '["US", "KR", "JP", "EU", "GB"]'::jsonb, 'cfg_stripe_sandbox_v1'),
('adyen_sandbox', 'ADYEN_SANDBOX', 'Adyen MarketPay (Sandbox Test Mode)', 'SANDBOX_ONLY', '["US", "KR", "JP", "EU", "GB"]'::jsonb, 'cfg_adyen_sandbox_v1')
ON CONFLICT (id) DO NOTHING;

