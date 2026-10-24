# 05. GAME POLICY REGISTRY

**Document ID:** BN-DOC-005  
**Ref:** Master PO Execution Order BN-GAMEEX-MASTER-001 (Article 3 & 10)  

---

## 1. Registry Architecture
The Game Policy Registry maps official publisher agreements, Terms of Service (TOS), and in-game trading mechanisms to platform capabilities.

| Game Slug | Publisher | In-Game Trade Feature | Approved Product Types | Prohibited Types | Registry Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `ethereal-odyssey` | Aether Interactive Inc. | User-to-User Transfer Window | `GAME_ITEM`, `OFFICIAL_GIFT_CODE` | `GAME_ACCOUNT`, `GAME_CURRENCY` (pending) | **ACTIVE (Pre-cleared)** |
| `galactic-warzone` | Nova Prime Games | In-Game Station Trade Kiosk | `GAME_ITEM` | `GAME_ACCOUNT`, `GAME_SERVICE` | **ACTIVE (Pre-cleared)** |
| `mythic-realms` | Mythic Works Ltd. | Guild Entitlement Exchange | `TRANSFERABLE_ENTITLEMENT` | `GAME_ACCOUNT` | **ACTIVE (Pre-cleared)** |

---

## 2. Policy Enforcement in Code
The Go API backend enforces this registry dynamically via `services/api/internal/policies/engine.go`:
- Validates every incoming Quote request.
- Validates every new Listing creation.
- Re-evaluates policy when order transitions to Checkout.
- Automatically rejects any product categorized as `GAME_ACCOUNT` with `ErrAccountTradeProhibited`.
