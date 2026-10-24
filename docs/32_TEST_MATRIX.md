# 32. MASTER E2E TEST MATRIX (63 SCENARIOS)

**Document ID:** BN-DOC-032  
**Ref:** Master PO Execution Order BN-GAMEEX-MASTER-001 (Article 32)  

---

## 1. Traceable Test Scenarios Table

| Scenario ID | Category | Description | Verification Method | Status |
| :---: | :--- | :--- | :--- | :---: |
| 1 | Account | User Registration | Go Test / API | **PASS** |
| 2 | Account | User Login & JWT Session | Go Test / API | **PASS** |
| 3 | Account | Email Verification | DB State / API | **PASS** |
| 4 | Account | Session Logout & Invalidation | Token Revocation Check | **PASS** |
| 5 | Account | Password Recovery Flow | Test Harness | **PASS** |
| 6 | Account | Unauthorized Route Blocking | Middleware HTTP 401 | **PASS** |
| 7 | Catalog | Canonical Game Creation | Seed Fixture / API | **PASS** |
| 8 | Catalog | Platform & Server Registration | DB Relational Check | **PASS** |
| 9 | Catalog | Query Approved Product Types | REST API Response | **PASS** |
| 10 | Catalog | Prohibited Territory Gate | PolicyEngine Test | **PASS** |
| 11 | Seller | Seller Onboarding | REST API Handler | **PASS** |
| 12 | Seller | KYC Verification Gating | Test Verification Record | **PASS** |
| 13 | Seller | Compliant Listing Creation | PolicyEngine Validation | **PASS** |
| 14 | Seller | Stock Quantity Amendment | Invariant Check | **PASS** |
| 15 | Seller | Listing Pause & Archive | Status History Audit | **PASS** |
| 16 | Search | Game Filter Search | API Filter Logic | **PASS** |
| 17 | Search | Server Filter Query | API Filter Logic | **PASS** |
| 18 | Search | Product Type Filter | API Filter Logic | **PASS** |
| 19 | Search | Unit Price Ascending Sort | Price Comparator | **PASS** |
| 20 | Search | Out of Stock Exclusion | Stock Filter | **PASS** |
| 21 | Order | Order Quote Calculation | Unit Fee Engine Test | **PASS** |
| 22 | Order | Order Placement | State Machine Test | **PASS** |
| 23 | Order | Atomic Stock Reservation | Concurrency Invariant Test | **PASS** |
| 24 | Order | Duplicate Order Request | Idempotency Key Gate | **PASS** |
| 25 | Order | Concurrent Oversell Collision | Inventory Mutex Lock | **PASS** |
| 26 | Order | Payment Decline Reversal | Stock Rollback Test | **PASS** |
| 27 | Order | Payment Succeeded Capture | Stock Consumption Commit | **PASS** |
| 28 | Order | Webhook Replay Protection | Event Deduplication Test | **PASS** |
| 29 | Order | Out-of-Order Webhook Delivery | State Machine Guard | **PASS** |
| 30 | Order | Fulfillment Release Notice | State Machine Transition | **PASS** |
| 31 | Order | Buyer Receipt Confirmation | Buyer Confirm Endpoint | **PASS** |
| 32 | Order | Buyer Order Cancellation | Order Cancellation Test | **PASS** |
| 33 | Order | Refund Transition | Order State Machine | **PASS** |
| 34 | Delivery | Delivery Evidence Submission | Delivery Service Test | **PASS** |
| 35 | Delivery | Invalid Evidence Rejection | Checksum Length Check | **PASS** |
| 36 | Delivery | Buyer Non-Delivery Escalation | Dispute Escalation Test | **PASS** |
| 37 | Delivery | Partial Delivery Claim | Dispute Handling | **PASS** |
| 38 | Delivery | Delivery Item Mismatch | Dispute Handling | **PASS** |
| 39 | Dispute | Open Dispute on Order | Dispute Service Test | **PASS** |
| 40 | Dispute | Dispute Evidence Ingestion | Media Binding Check | **PASS** |
| 41 | Dispute | Admin Adjudication Review | Dispute Queue Query | **PASS** |
| 42 | Dispute | Propose Refund Decision | Dual-Approval Gate | **PASS** |
| 43 | Dispute | Secondary Finance Approval | 4-Eyes Enforced Test | **PASS** |
| 44 | Dispute | Dispute Appeal Logging | Appeal Table Record | **PASS** |
| 45 | Settlement | Seller Payable Calculation | Ledger Posting Test | **PASS** |
| 46 | Settlement | Platform Fee Deduction | Double-Entry Balancing | **PASS** |
| 47 | Settlement | Protection Window Hold | Payout Status Eligible | **PASS** |
| 48 | Settlement | Seller Payout Request | Payout Service Test | **PASS** |
| 49 | Settlement | Payout Failure Graceful Retry | Provider Adapter Error | **PASS** |
| 50 | Settlement | Confirmed Payout Disbursement | Sandbox Provider Mock | **PASS** |
| 51 | Settlement | Reconciliation Discrepancy Flag | Admin Grid Audit | **PASS** |
| 52 | Settlement | Prevent Duplicate Payout | Double-Spend Guard | **PASS** |
| 53 | Realtime | WebSocket Handshake | Connection Upgrade | **PASS** |
| 54 | Realtime | Reconnection & Sync | Monotonic Sequence | **PASS** |
| 55 | Realtime | Message Client Ack | Server Ack Dispatch | **PASS** |
| 56 | Realtime | Phishing URL Warning / Block | Risk Engine Filter | **PASS** |
| 57 | Realtime | Off-Platform Leakage Alert | Regex Heuristics Test | **PASS** |
| 58 | Admin | Listing Policy Review | Admin Console UI | **PASS** |
| 59 | Admin | Multi-Gate Policy Toggle | Admin Console UI | **PASS** |
| 60 | Admin | Seller Suspension | Admin REST Handler | **PASS** |
| 61 | Admin | Dual-Approval for High Refund | Segregation of Duties | **PASS** |
| 62 | Admin | Audit Log Recording | Append-Only Table Check | **PASS** |
| 63 | Admin | RBAC Unauthorized Interception | 403 Forbidden Response | **PASS** |

