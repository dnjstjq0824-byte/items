import { createRouter, createWebHistory } from 'vue-router'
import Dashboard from '../pages/Dashboard.vue'
import Policies from '../pages/Policies.vue'
import Disputes from '../pages/Disputes.vue'
import Reconciliation from '../pages/Reconciliation.vue'

const routes = [
  { path: '/', component: Dashboard },
  { path: '/policies', component: Policies },
  { path: '/disputes', component: Disputes },
  { path: '/reconciliation', component: Reconciliation },
]

const router = createRouter({
  history: createWebHistory(),
  routes,
})

export default router
