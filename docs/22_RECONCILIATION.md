# 22. FINANCIAL RECONCILIATION & AUDIT

**Document ID:** BN-DOC-022  
**Ref:** Master PO Execution Order BN-GAMEEX-MASTER-001 (Article 27.10)  

---

## 1. Reconciliation Process
Financial operations regularly ingest batch payout and settlement reports from PSP partners:

```mermaid
flowchart LR
    A["External PSP Settlement CSV / API"] --> B["Reconciliation Import Worker"]
    B --> C["Match Provider Transaction ID with Internal Order ID"]
    C --> D{"Amount & Currency Match?"}
    D -- "Yes" --> E["Status: BALANCED & RECONCILED"]
    D -- "No" --> F["Flag DISCREPANCY & Open Audit Item"]
    F --> G["Manual Finance Review Required"]
```

---

## 2. Anti-Tampering Rules
- Internal ledger transactions are append-only.
- Discrepancies cannot be automatically closed without a formal review note and secondary management signoff.
