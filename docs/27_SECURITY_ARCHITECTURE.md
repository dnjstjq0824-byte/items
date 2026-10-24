# 27. SECURITY ARCHITECTURE & PCI COMPLIANCE

**Document ID:** BN-DOC-027  
**Ref:** Master PO Execution Order BN-GAMEEX-MASTER-001 (Article 31)  

---

## 1. Zero-PCI Footprint Architecture
- **No Cardholder Data:** Primary Account Numbers (PAN), CVVs, and magnetic stripe data never enter BN GAMEEX servers or log streams.
- All checkout sessions leverage licensed PSP Hosted Checkout or PSP Elements with tokenized provider references.
- Webhook endpoints require cryptographic HMAC-SHA256 signature validation.

---

## 2. Platform Hardening
- **Strict HTTPS / TLS 1.3:** HSTS enabled with preloading.
- **Content Security Policy (CSP):** Disallows inline eval scripts and restricts connect-src to known API and WebSocket origins.
- **SQL Injection Defense:** All queries parameterized through Go database/sql drivers and PostgreSQL prepared statements.
- **Rate Limiting:** IP and user-based token bucket rate limiting on authentication and search endpoints.

