# 21. INTERNAL DOUBLE-ENTRY SETTLEMENT LEDGER

**Document ID:** BN-DOC-021  
**Ref:** Master PO Execution Order BN-GAMEEX-MASTER-001 (Article 16.6 & 22.8)  

---

## 1. Accounting Model & Balance Invariants
All financial events create balanced journal entries across chart of accounts:

$$\sum \text{DebitMinor} = \sum \text{CreditMinor} \quad (\text{per transaction, per currency})$$

### Journal Entries for Standard Order Capture:
- **Debit:** `1010-USD-PSP-CLEARING` (Total Buyer Payment: Subtotal + BuyerFee)
- **Credit:** `2010-USD-SELLER-PAYABLE` (Net Seller Receivable: Subtotal - SellerFee)
- **Credit:** `4010-USD-FEE-REVENUE` (Marketplace Platform Revenue: BuyerFee + SellerFee)

---

## 2. Payout Execution Gate
Sellers cannot withdraw directly from internal database balances. A payout request is only dispatched to the external payout partner if:
1. The associated order has reached `COMPLETED` status.
2. The protection holding window has expired without an active dispute.
3. The seller's KYB/KYC verification is active.
4. Total disbursed payouts do not exceed reconciled net seller payables.

