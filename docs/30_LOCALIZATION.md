# 30. GLOBAL LOCALIZATION ARCHITECTURE

**Document ID:** BN-DOC-030  
**Ref:** Master PO Execution Order BN-GAMEEX-MASTER-001 (Article 21)  

---

## 1. Supported Locales & Currencies
- **Languages:** Korean (`ko`), English (`en`), Japanese (`ja`), Simplified Chinese (`zh-CN`), Traditional Chinese (`zh-TW`), Spanish (`es`), French (`fr`).
- **Currencies:** KRW (0 decimals, minor unit = 1), USD (2 decimals, minor unit = 100), EUR (2 decimals), JPY (0 decimals), GBP (2 decimals).

## 2. Dynamic Minor Unit Calculations
All pricing calculations in the Go backend utilize integer minor units to eliminate floating-point precision errors:
$$\text{DisplayAmount} = \frac{\text{AmountMinor}}{10^{\text{DecimalDigits}}}$$
All internal balance validations strictly enforce minor-unit integer equality.
