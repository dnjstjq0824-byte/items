# 28. RBAC PERMISSIONS MATRIX

**Document ID:** BN-DOC-028  
**Ref:** Master PO Execution Order BN-GAMEEX-MASTER-001 (Article 29)  

---

## 1. Role-to-Permission Mapping

| Permission Code | SUPER_ADMIN | OPERATIONS_ADMIN | DISPUTE_MANAGER | FINANCE_OPERATOR | FINANCE_APPROVER | SUPPORT_AGENT |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| `catalog:read` | Yes | Yes | Yes | Yes | Yes | Yes |
| `catalog:write` | Yes | Yes | No | No | No | No |
| `policy:approve` | Yes | Yes | No | No | No | No |
| `seller:verify` | Yes | Yes | No | No | No | No |
| `order:view` | Yes | Yes | Yes | Yes | Yes | Yes |
| `dispute:decide` | Yes | No | **Yes** | No | No | No |
| `refund:request` | Yes | Yes | Yes | **Yes** | No | No |
| `refund:approve` | Yes | No | No | No | **Yes** | No |
| `payout:request` | Yes | No | No | **Yes** | No | No |
| `payout:approve` | Yes | No | No | No | **Yes** | No |
| `reconciliation:run` | Yes | No | No | **Yes** | **Yes** | No |
| `audit:view` | Yes | Yes | Yes | Yes | Yes | No |
