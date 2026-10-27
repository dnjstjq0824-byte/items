import { createRouter, createWebHistory } from 'vue-router'
import Dashboard from '../pages/Dashboard.vue'
import Policies from '../pages/Policies.vue'
import Disputes from '../pages/Disputes.vue'
import Reconciliation from '../pages/Reconciliation.vue'
import Sellers from '../pages/Sellers.vue'
import Orders from '../pages/Orders.vue'
import Payments from '../pages/Payments.vue'
import RiskCenter from '../pages/RiskCenter.vue'
import AuditLogs from '../pages/AuditLogs.vue'
import TradeMonitor from '../pages/TradeMonitor.vue'
import Withdrawals from '../pages/Withdrawals.vue'
import SafetyGuarantees from '../pages/SafetyGuarantees.vue'

const routes = [
  { path: '/', component: Dashboard },
  { path: '/trade-monitor', component: TradeMonitor },
  { path: '/withdrawals', component: Withdrawals },
  { path: '/safety-guarantees', component: SafetyGuarantees },
  { path: '/orders', component: Orders },
  { path: '/policies', component: Policies },
  { path: '/sellers', component: Sellers },
  { path: '/disputes', component: Disputes },
  { path: '/reconciliation', component: Reconciliation },
  { path: '/payments', component: Payments },
  { path: '/risk', component: RiskCenter },
  { path: '/audit-logs', component: AuditLogs },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router
