# 26. FRAUD PREVENTION & RISK ENGINE SPECIFICATION

**Document ID:** BN-DOC-026  
**Ref:** Master PO Execution Order BN-GAMEEX-MASTER-001 (Article 20)  

---

## 1. Automated Detection Heuristics
The Go Risk Engine (`services/api/internal/risk/engine.go`) enforces real-time inspection across three channels:

1. **Content & Chat Leakage:**
   - Detects off-platform communication (Discord, Telegram, WhatsApp, KakaoTalk links).
   - Blocks known phishing links and fake Steam login domains.
2. **Velocity & High-Value Anomalies:**
   - Flags orders $> \$1,000$ initiated against new or unverified sellers (`HIGH_VALUE_UNVERIFIED_SELLER`).
   - Flags repetitive rapid checkout attempts with card decline errors.
3. **Evidence Reuse Detection:**
   - Rejects duplicate SHA256 checksums across different orders to prevent recycled fake delivery screenshots.

