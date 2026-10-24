# 24. DISPUTE OPERATIONS & DUAL-APPROVAL MANUAL

**Document ID:** BN-DOC-024  
**Ref:** Master PO Execution Order BN-GAMEEX-MASTER-001 (Article 18 & 29)  

---

## 1. Dispute Reasons & Evidence Burden
- `NON_DELIVERY`: Seller must present timestamped in-game delivery logs or transfer receipts.
- `NOT_AS_DESCRIBED`: Buyer must submit screenshot or video showing discrepancies in item stats, quantity, or game server.
- `UNAUTHORIZED_PAYMENT`: Routed immediately to payment provider risk investigations.

---

## 2. Segregation of Duties (The 4-Eyes Principle)
Under Article 29, no single operator has the authority to unilaterally refund orders or disburse funds:

```text
Step 1: Dispute Case Assigned to Adjudicator (DISPUTE_MANAGER)
Step 2: Adjudicator Reviews Evidence -> Registers Decision (e.g. BUYER_FAVOR_FULL_REFUND)
Step 3: Decision enters state PENDING_APPROVAL
Step 4: Independent Finance Officer (FINANCE_APPROVER) reviews case
        (Constraint: Approver UserID != Decider UserID)
Step 5: Approver signs decision -> System dispatches refund API call to PSP
Step 6: Order transitions to REFUNDED upon PSP confirmation
```
