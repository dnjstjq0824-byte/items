# 09. MASTER DESIGN SYSTEM SPECIFICATION

**Document ID:** BN-DOC-009  
**Ref:** Master PO Execution Order BN-GAMEEX-MASTER-001 (Article 8)  

---

## 1. Color Palette Tokens

```css
/* Core Brand Tokens */
--color-primary: #6366F1;         /* Indigo Core */
--color-primary-hover: #4F46E5;   /* Deep Indigo */
--color-accent: #22D3EE;          /* Cyan Electric */

/* Surface & Background (Dark Theme Default) */
--color-bg-dark: #0B1020;         /* Obsidian Midnight */
--color-surface-dark: #151C2F;    /* Deep Slate Surface */
--color-border-dark: #283247;     /* High-contrast Slate Border */
--color-text-dark: #F8FAFC;       /* Off-white Text */

/* Semantic Status Tokens */
--color-success: #22C55E;         /* Emerald 500 */
--color-warning: #F59E0B;         /* Amber 500 */
--color-danger: #EF4444;          /* Crimson 500 */
```

---

## 2. Typography & Responsive Grid
- Font Family: System native sans-serif (-apple-system, BlinkMacSystemFont, Segoe UI, Roboto)
- Viewport Breakpoints: 320px (Mobile S), 390px (Mobile Standard), 768px (Tablet), 1024px (Laptop), 1440px (Desktop), 2560px (Ultra-wide).
- Grid layout: 12-column adaptive layout on desktop, single-column stacked on mobile.

