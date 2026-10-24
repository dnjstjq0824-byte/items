# 06. USER PERSONAS & ACCESS TIERS

**Document ID:** BN-DOC-006  
**Ref:** Master PO Execution Order BN-GAMEEX-MASTER-001 (Article 4)  

---

## 1. User Types & Permissions Matrix

| User Type | Responsibilities & Capabilities | Verification Level | Scope Boundaries |
| :--- | :--- | :--- | :--- |
| **GUEST** | Browse approved games, explore public listings, review safety guides | None (Public) | Read-only; no checkout or chat |
| **BUYER** | Create quotes, initiate checkout, chat with sellers, confirm delivery, file disputes | Email + Phone SMS | Purchasing, reviewing, personal dispute center |
| **SELLER** | List pre-cleared items, manage stock, submit delivery evidence, view pending payouts | ID / KYC Verified | Selling pre-cleared categories, order fulfillment |
| **PRO_SELLER** | High-volume batch listings, priority placement, advanced analytics | KYB / Business Registration | Expanded quantity limits, dedicated support |
| **SUPPORT_AGENT**| First-tier customer tickets, basic order timeline inspection | Enterprise SSO + MFA | Cannot approve refunds or edit financial ledger |
| **DISPUTE_MANAGER**| Adjudicate buyer/seller evidence, propose case resolutions | Enterprise SSO + MFA | Primary decision only; refund requires 4-eyes approval |
| **FINANCE_APPROVER**| Secondary dual-authorization on refunds & payout batches | Enterprise SSO + Hardware Key | Must not be the original decision maker |
| **SUPER_ADMIN** | Overall system policy configuration, game enablement, role assignment | Enterprise SSO + Hardware Key | Full administrative oversight |

