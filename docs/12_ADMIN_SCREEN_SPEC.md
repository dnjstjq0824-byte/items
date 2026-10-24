# 12. ADMIN CONSOLE SCREEN SPECIFICATION

**Document ID:** BN-DOC-012  
**Ref:** Master PO Execution Order BN-GAMEEX-MASTER-001 (Article 27 & 28)  

---

## 1. Operational Views Breakdown

1. **Operational Dashboard (`/`)**:
   - Strict metric segregation: GMV vs Captured PSP Payments vs Commission Fee Revenue vs Pending Seller Payouts.
   - Compliance gate summary widget.
   - Live dispute alert queue.
2. **Global Trade Policies (`/policies`)**:
   - Filterable data table of Country x Game x Product Type policy entries.
   - Verification status: Legal review, publisher policy status, PSP status.
   - Direct policy toggle with audit logging.
3. **Dispute Center (`/disputes`)**:
   - Case details & evidence inspection panel.
   - Dual-Approval (4-Eyes) refund authorization workflow: Secondary Finance Approver authentication required for fund return execution.
4. **Financial Reconciliation (`/reconciliation`)**:
   - Ingested PSP settlement batch overview.
   - Line-by-line comparison between Provider Transaction ID and internal order ledger entries.
   - Auto-highlighting of discrepancy variances.
