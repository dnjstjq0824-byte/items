# 04. GLOBAL COMPLIANCE & LEGAL MATRIX

**Document ID:** BN-DOC-004  
**Ref:** Master PO Execution Order BN-GAMEEX-MASTER-001 (Article 3 & 21)  

---

## 1. Jurisdictional Regulatory Overview

| Jurisdiction | Authority & Statutes | In-Game Currency Policy | Digital Voucher / Code Policy | Platform Custody Constraint |
| :--- | :--- | :--- | :--- | :--- |
| **South Korea (KR)** | Game Industry Promotion Act (Art 32), Act on Consumer Protection in E-Commerce | **Strictly Regulated:** Currency acquired via non-official methods or gambling is illegal. Gated by default. | **Permitted:** Legitimate publisher prepaid cards and vouchers allowed with proof of origin. | Escrow or licensed payment agent mandatory. No direct unlicensed holding of funds. |
| **United States (US)** | FinCEN MSB regulations, state money transmitter laws (MTL), UCC Article 9 | **Restricted / Review:** Secondary sales permitted if game TOS allows and not classified as virtual currency transmission. | **Permitted:** Retail digital codes with clear merchant terms. | Marketplace facilitator model via licensed PSP (e.g. Stripe, Adyen). |
| **European Union (EU)** | PSD2 / PSD3, MiCA, GDPR, DSA (Digital Services Act) | **Review Required:** Avoid classification as electronic money or unregulated crypto asset. | **Permitted:** Standard digital entitlement sales with consumer cancellation disclosures. | Strictly licensed payment institution required for split payouts and escrow. |
| **Japan (JP)** | Payment Services Act (Prepaid Payment Instruments), PSA Article 63 | **Prohibited/Restricted:** Points & virtual currencies issued by publishers must comply with refund/escrow rules. | **Permitted:** Authorized merchant gift codes. | Funds settlement regulations require licensed remittance agent. |

---

## 2. Multi-Gate Compliance Formula
Trade enablement is evaluated using Boolean logic:

$$\text{TradeEnabled} = (\text{LegalStatus} == \text{APPROVED}) \land (\text{PublisherStatus} == \text{PERMITTED}) \land (\text{PSPStatus} == \text{APPROVED}) \land (\text{ProductType} \neq \text{GAME\_ACCOUNT})$$

If any term evaluates to false, the listing and checkout pipelines immediately halt with status `BLOCKED` or `REVIEW_REQUIRED`.
