# 25. SELLER VERIFICATION & TRUST FRAMEWORK

**Document ID:** BN-DOC-025  
**Ref:** Master PO Execution Order BN-GAMEEX-MASTER-001 (Article 19)  

---

## 1. Verification Tiers
1. **Tier 0 (Unverified / Guest):** Browsing only. No selling privileges.
2. **Tier 1 (Individual Seller):** Email verified, SMS phone 2FA, agreed to game TOS. Maximum active inventory cap: $500.
3. **Tier 2 (Verified Seller):** External KYC verification (passport/driver's license tokenized via third-party provider; no raw ID images stored locally). Maximum active inventory cap: $5,000.
4. **Tier 3 (PRO Seller / Business):** Full KYB business registration, verified business bank account, proven 98%+ order fulfillment rate over 50+ trades. Uncapped inventory limit.

---

## 2. Dynamic Trust Metrics
Seller reputation scores are derived algorithmically:
$$\text{TrustScore} = \left(\frac{\text{RatingScoreSum}}{\text{RatingCount}}\right) \times \left(1 - \frac{\text{DisputeCount}}{\text{CompletedOrdersCount} + 1}\right)$$
Sellers with elevated dispute rates (>3%) are automatically subjected to algorithmic sales velocity limits.

