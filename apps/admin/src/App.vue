<template>
  <div class="min-h-screen flex bg-[#0B1020] text-[#F8FAFC]">
    <!-- Admin Sidebar (Article 27.1) -->
    <aside class="w-64 bg-[#151C2F] border-r border-[#283247] flex flex-col justify-between shrink-0">
      <div>
        <div class="h-16 px-6 border-b border-[#283247] flex items-center justify-between">
          <div class="flex items-center gap-2">
            <span class="w-7 h-7 rounded bg-[#6366F1] flex items-center justify-center font-black text-xs text-white">BN</span>
            <span class="font-extrabold text-sm tracking-wider">GAMEEX ADMIN</span>
          </div>
          <span class="text-[10px] px-1.5 py-0.5 rounded bg-amber-500/20 text-amber-300 border border-amber-500/30 font-mono">SANDBOX</span>
        </div>

        <nav class="p-4 space-y-1 text-xs font-medium">
          <router-link to="/" class="flex items-center gap-3 px-3 py-2 rounded-lg text-gray-300 hover:text-white hover:bg-[#283247]/50" active-class="bg-[#6366F1] text-white">
            <span>📊 Overview Dashboard</span>
          </router-link>
          <router-link to="/policies" class="flex items-center gap-3 px-3 py-2 rounded-lg text-gray-300 hover:text-white hover:bg-[#283247]/50" active-class="bg-[#6366F1] text-white">
            <span>🌐 Global Trade Policies</span>
          </router-link>
          <router-link to="/orders" class="flex items-center gap-3 px-3 py-2 rounded-lg text-gray-300 hover:text-white hover:bg-[#283247]/50" active-class="bg-[#6366F1] text-white">
            <span>📦 Master Order Ledger</span>
          </router-link>
          <router-link to="/sellers" class="flex items-center gap-3 px-3 py-2 rounded-lg text-gray-300 hover:text-white hover:bg-[#283247]/50" active-class="bg-[#6366F1] text-white">
            <span>👤 Seller Verification & KYC</span>
          </router-link>
          <router-link to="/disputes" class="flex items-center gap-3 px-3 py-2 rounded-lg text-gray-300 hover:text-white hover:bg-[#283247]/50" active-class="bg-[#6366F1] text-white">
            <span>⚖️ Dispute Center (4-Eyes)</span>
          </router-link>
          <router-link to="/reconciliation" class="flex items-center gap-3 px-3 py-2 rounded-lg text-gray-300 hover:text-white hover:bg-[#283247]/50" active-class="bg-[#6366F1] text-white">
            <span>📑 Financial Reconciliation</span>
          </router-link>
          <router-link to="/payments" class="flex items-center gap-3 px-3 py-2 rounded-lg text-gray-300 hover:text-white hover:bg-[#283247]/50" active-class="bg-[#6366F1] text-white">
            <span>💳 Payment Rails & Webhooks</span>
          </router-link>
          <router-link to="/risk" class="flex items-center gap-3 px-3 py-2 rounded-lg text-gray-300 hover:text-white hover:bg-[#283247]/50" active-class="bg-[#6366F1] text-white">
            <span>🚨 Risk & Anti-Fraud Center</span>
          </router-link>
          <router-link to="/audit-logs" class="flex items-center gap-3 px-3 py-2 rounded-lg text-gray-300 hover:text-white hover:bg-[#283247]/50" active-class="bg-[#6366F1] text-white">
            <span>📝 Immutable Audit Logs</span>
          </router-link>
        </nav>
      </div>

      <div class="p-4 border-t border-[#283247] text-xs text-gray-400">
        <div class="font-semibold text-white">SuperOpsAdmin</div>
        <div>Role: SUPER_ADMIN</div>
        <div class="mt-2 text-[10px] text-emerald-400">PO Compliance Gate: ACTIVE</div>
      </div>
    </aside>

    <!-- Main Content Area -->
    <div class="flex-1 flex flex-col min-w-0">
      <header class="h-16 bg-[#151C2F]/50 backdrop-blur border-b border-[#283247] px-8 flex items-center justify-between shrink-0">
        <h1 class="text-base font-bold text-white tracking-wide">{{ currentRouteName }}</h1>
        <div class="flex items-center gap-4 text-xs">
          <span class="px-2 py-1 rounded bg-emerald-500/10 text-emerald-400 border border-emerald-500/30">System Normal</span>
          <span class="text-gray-400 font-mono">2026-10-24 23:00 UTC</span>
        </div>
      </header>

      <main class="flex-1 p-8 overflow-y-auto">
        <router-view />
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const currentRouteName = computed(() => {
  switch (route.path) {
    case '/': return 'Operational Dashboard'
    case '/policies': return 'Global Trade Policy Gating (Article 3)'
    case '/orders': return 'Master Order Audit & Lifecycle Ledger'
    case '/sellers': return 'Seller Management & KYC Verification'
    case '/disputes': return 'Dispute Resolution & 4-Eyes Dual Approval'
    case '/reconciliation': return 'Financial Reconciliation Ledger (Article 16)'
    case '/payments': return 'Payment Rails & Webhook Gateway'
    case '/risk': return 'Anti-Fraud & Risk Heuristics Engine'
    case '/audit-logs': return 'System Audit & Regulatory Log (Article 24)'
    default: return 'Admin Console'
  }
})
</script>
