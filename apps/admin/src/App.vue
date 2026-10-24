<template>
  <div class="min-h-screen flex bg-[#0B1020] text-[#F8FAFC]">
    <!-- Admin Sidebar (Article 27.1) -->
    <aside class="w-64 bg-[#151C2F] border-r border-[#283247] flex flex-col justify-between">
      <div>
        <div class="h-16 px-6 border-b border-[#283247] flex items-center justify-between">
          <div class="flex items-center gap-2">
            <span class="w-7 h-7 rounded bg-[#6366F1] flex items-center justify-center font-black text-xs text-white">BN</span>
            <span class="font-extrabold text-sm tracking-wider">GAMEEX ADMIN</span>
          </div>
          <span class="text-[10px] px-1.5 py-0.5 rounded bg-amber-500/20 text-amber-300 border border-amber-500/30 font-mono">SANDBOX</span>
        </div>

        <nav class="p-4 space-y-1 text-sm font-medium">
          <router-link to="/" class="flex items-center gap-3 px-3 py-2 rounded-lg text-gray-300 hover:text-white hover:bg-[#283247]/50" active-class="bg-[#6366F1] text-white">
            <span>Dashboard</span>
          </router-link>
          <router-link to="/policies" class="flex items-center gap-3 px-3 py-2 rounded-lg text-gray-300 hover:text-white hover:bg-[#283247]/50" active-class="bg-[#6366F1] text-white">
            <span>Global Trade Policies</span>
          </router-link>
          <router-link to="/disputes" class="flex items-center gap-3 px-3 py-2 rounded-lg text-gray-300 hover:text-white hover:bg-[#283247]/50" active-class="bg-[#6366F1] text-white">
            <span>Dispute Center (4-Eyes)</span>
          </router-link>
          <router-link to="/reconciliation" class="flex items-center gap-3 px-3 py-2 rounded-lg text-gray-300 hover:text-white hover:bg-[#283247]/50" active-class="bg-[#6366F1] text-white">
            <span>Financial Reconciliation</span>
          </router-link>
        </nav>
      </div>

      <div class="p-4 border-t border-[#283247] text-xs text-gray-400">
        <div class="font-semibold text-white">SuperOpsAdmin</div>
        <div>Role: SUPER_ADMIN</div>
        <div class="mt-2 text-[10px] text-gray-500">PO Compliance Gate: ACTIVE</div>
      </div>
    </aside>

    <!-- Main Content Area -->
    <div class="flex-1 flex flex-col min-w-0">
      <header class="h-16 bg-[#151C2F]/50 backdrop-blur border-b border-[#283247] px-8 flex items-center justify-between">
        <h1 class="text-lg font-bold text-white tracking-wide">{{ currentRouteName }}</h1>
        <div class="flex items-center gap-4 text-xs">
          <span class="px-2 py-1 rounded bg-emerald-500/10 text-emerald-400 border border-emerald-500/30">System Normal</span>
          <span class="text-gray-400 font-mono">2026-10-24 22:45 UTC</span>
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
    case '/policies': return 'Global Trade Policy Gating'
    case '/disputes': return 'Dispute Resolution & Dual Approval'
    case '/reconciliation': return 'Financial Reconciliation Ledger'
    default: return 'Admin Console'
  }
})
</script>

