-- Database Fixtures: 01_admin_roles.sql
-- Seed Admin Roles and Initial Permissions

INSERT INTO admin_roles (id, code, name) VALUES
('a0000000-0000-0000-0000-000000000001', 'SUPER_ADMIN', 'Super Administrator'),
('a0000000-0000-0000-0000-000000000002', 'OPERATIONS_ADMIN', 'Operations Administrator'),
('a0000000-0000-0000-0000-000000000003', 'GAME_CATALOG_MANAGER', 'Game Catalog Manager'),
('a0000000-0000-0000-0000-000000000004', 'COMPLIANCE_MANAGER', 'Global Compliance & Legal Manager'),
('a0000000-0000-0000-0000-000000000005', 'SELLER_VERIFICATION_ADMIN', 'Seller Trust & Verification Admin'),
('a0000000-0000-0000-0000-000000000006', 'TRUST_SAFETY_ADMIN', 'Trust & Safety / Fraud Officer'),
('a0000000-0000-0000-0000-000000000007', 'DISPUTE_MANAGER', 'Dispute Resolution Manager'),
('a0000000-0000-0000-0000-000000000008', 'FINANCE_OPERATOR', 'Finance Operations Specialist'),
('a0000000-0000-0000-0000-000000000009', 'FINANCE_APPROVER', 'Finance Dual-Approval Officer'),
('a0000000-0000-0000-0000-000000000010', 'SUPPORT_AGENT', 'Customer Support Representative'),
('a0000000-0000-0000-0000-000000000011', 'ANALYST', 'Business & Risk Analyst'),
('a0000000-0000-0000-0000-000000000012', 'READ_ONLY_AUDITOR', 'Independent Compliance Auditor')
ON CONFLICT (code) DO NOTHING;

INSERT INTO admin_permissions (id, code, resource, action) VALUES
('b0000000-0000-0000-0000-000000000001', 'catalog:read', 'catalog', 'read'),
('b0000000-0000-0000-0000-000000000002', 'catalog:write', 'catalog', 'write'),
('b0000000-0000-0000-0000-000000000003', 'policy:approve', 'policy', 'approve'),
('b0000000-0000-0000-0000-000000000004', 'seller:verify', 'seller', 'verify'),
('b0000000-0000-0000-0000-000000000005', 'order:view', 'order', 'read'),
('b0000000-0000-0000-0000-000000000006', 'dispute:decide', 'dispute', 'decide'),
('b0000000-0000-0000-0000-000000000007', 'refund:request', 'refund', 'request'),
('b0000000-0000-0000-0000-000000000008', 'refund:approve', 'refund', 'approve'),
('b0000000-0000-0000-0000-000000000009', 'payout:request', 'payout', 'request'),
('b0000000-0000-0000-0000-000000000010', 'payout:approve', 'payout', 'approve'),
('b0000000-0000-0000-0000-000000000011', 'reconciliation:run', 'reconciliation', 'run'),
('b0000000-0000-0000-0000-000000000012', 'audit:view', 'audit', 'read')
ON CONFLICT (code) DO NOTHING;
