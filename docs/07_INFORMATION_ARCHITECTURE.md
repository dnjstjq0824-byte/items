# 07. INFORMATION ARCHITECTURE

**Document ID:** BN-DOC-007  
**Ref:** Master PO Execution Order BN-GAMEEX-MASTER-001 (Article 7 & 8)  

---

## 1. Global Sitemap & Route Hierarchy

```text
/ (Public Web Root)
├── /{locale}/
│   ├── games/
│   │   └── {game-slug}/
│   │       ├── items/
│   │       ├── currency/ (Gated)
│   │       └── offers/
│   ├── listings/
│   │   └── {listing-id}/
│   ├── search/
│   ├── sellers/
│   │   └── {seller-id}/
│   ├── my/
│   │   ├── orders/
│   │   ├── conversations/
│   │   └── disputes/
│   ├── seller/
│   │   ├── dashboard/
│   │   ├── listings/
│   │   ├── orders/
│   │   └── payouts/
│   └── help/
│       ├── trade-protection/
│       ├── fees/
│       └── policies/
└── /admin/
    ├── dashboard/
    ├── policies/
    ├── disputes/
    └── reconciliation/
```
