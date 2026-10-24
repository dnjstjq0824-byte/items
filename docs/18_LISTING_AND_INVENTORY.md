# 18. LISTING AND INVENTORY MANAGEMENT

**Document ID:** BN-DOC-018  
**Ref:** Master PO Execution Order BN-GAMEEX-MASTER-001 (Article 11 & 23)  

---

## 1. Inventory Model Invariants
Every listing maintains strict mathematical stock balances:
$$\text{AvailableQuantity} + \text{ReservedQuantity} + \text{SoldQuantity} = \text{TotalInitialQuantity}$$
$$\text{AvailableQuantity} \ge 0, \quad \text{ReservedQuantity} \ge 0$$

## 2. Reservation Lifecycle
1. **Reserve:** When a buyer initiates an order from a quote, `available_quantity` is decremented by $Q$ and `reserved_quantity` is incremented by $Q$. An `inventory_reservations` record is issued with a 30-minute TTL.
2. **Commit:** Upon receiving confirmed payment capture from the PSP, `reserved_quantity` is decremented and `sold_quantity` is incremented.
3. **Rollback / Timeout:** If payment fails, the order expires, or checkout is cancelled, the reservation is released: `reserved_quantity` is decremented and `available_quantity` is restored.

