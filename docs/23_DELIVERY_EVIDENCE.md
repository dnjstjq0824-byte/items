# 23. DELIVERY EVIDENCE SPECIFICATION

**Document ID:** BN-DOC-023  
**Ref:** Master PO Execution Order BN-GAMEEX-MASTER-001 (Article 17)  

---

## 1. Evidence Types & Verification
1. **In-Game Screenshot / Video Clip:**
   - Must show buyer character name, order quantity, and in-game trade window confirmation.
   - Client calculates client-side SHA256 checksum before uploading to object storage.
   - System validates checksum upon storage upload and binds to the `delivery_evidence` record.
2. **Digital Code Receipts:**
   - Hashed voucher code record with timestamp and cryptographic signature.
3. **Privacy Masking:**
   - The UI automatically prompts sellers to blur private user details (email addresses, phone numbers, balance info) before finalizing submission.

