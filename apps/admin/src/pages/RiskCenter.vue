<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
      <div>
        <h2 class="text-xl font-bold text-white tracking-tight">Risk Engine & Anti-Fraud Center</h2>
        <p class="text-xs text-gray-400 mt-1">Autonomous surveillance for off-platform communication leaks, prohibited account trading, and transaction velocity anomalies.</p>
      </div>

      <div class="flex items-center gap-3">
        <span class="px-2.5 py-1 rounded bg-rose-500/10 text-rose-400 border border-rose-500/30 text-xs font-semibold">
          Surveillance Engine: ACTIVE
        </span>
      </div>
    </div>

    <!-- Risk KPI Grid -->
    <div class="grid grid-cols-1 sm:grid-cols-4 gap-4">
      <div class="bg-[#151C2F] border border-[#283247] p-4 rounded-xl">
        <div class="text-xs text-gray-400">Off-Platform Leaks Caught (24h)</div>
        <div class="text-xl font-bold text-white font-mono mt-1">18 Messages</div>
        <div class="text-[10px] text-indigo-400 mt-1">Discord / Telegram regex intercepted</div>
      </div>

      <div class="bg-[#151C2F] border border-[#283247] p-4 rounded-xl">
        <div class="text-xs text-gray-400">Account Trade Attempts Blocked</div>
        <div class="text-xl font-bold text-rose-400 font-mono mt-1">42 Listings</div>
        <div class="text-[10px] text-rose-300 mt-1">Article 3.4 Gating strictly enforced</div>
      </div>

      <div class="bg-[#151C2F] border border-[#283247] p-4 rounded-xl">
        <div class="text-xs text-gray-400">Suspicious Velocity Alerts</div>
        <div class="text-xl font-bold text-amber-300 font-mono mt-1">3 Accounts</div>
        <div class="text-[10px] text-amber-400 mt-1">>5 orders in 60s without KYC</div>
      </div>

      <div class="bg-[#151C2F] border border-[#283247] p-4 rounded-xl">
        <div class="text-xs text-gray-400">Escrow Holds</div>
        <div class="text-xl font-bold text-emerald-400 font-mono mt-1">$4,850 USD</div>
        <div class="text-[10px] text-gray-400 mt-1">Pending compliance review</div>
      </div>
    </div>

    <!-- Active Risk Detections Table -->
    <div class="bg-[#151C2F] border border-[#283247] rounded-xl overflow-hidden">
      <div class="p-4 border-b border-[#283247] flex items-center justify-between">
        <h3 class="text-sm font-semibold text-white">Live Threat Detections & Heuristic Triggers</h3>
      </div>

      <div class="overflow-x-auto">
        <table class="w-full text-left text-xs">
          <thead class="bg-[#0B1020] border-b border-[#283247] text-gray-400 uppercase tracking-wider font-semibold">
            <tr>
              <th class="p-4">Incident ID</th>
              <th class="p-4">Violation Rule</th>
              <th class="p-4">Actor</th>
              <th class="p-4">Trigger Pattern / Snippet</th>
              <th class="p-4">Severity</th>
              <th class="p-4">System Action</th>
              <th class="p-4 text-right">Actions</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-[#283247] text-gray-300">
            <tr v-for="risk in risks" :key="risk.id" class="hover:bg-[#1A233A]/50 transition">
              <td class="p-4 font-mono font-bold text-white">{{ risk.id }}</td>
              <td class="p-4 font-semibold text-indigo-300">{{ risk.rule }}</td>
              <td class="p-4">
                <div class="font-bold text-white">{{ risk.actor }}</div>
                <div class="text-[10px] text-gray-500 font-mono">{{ risk.actorId }}</div>
              </td>
              <td class="p-4 font-mono text-[11px] text-rose-300">
                "{{ risk.snippet }}"
              </td>
              <td class="p-4">
                <span class="px-2 py-0.5 rounded text-[10px] font-bold border" :class="getSeverityClass(risk.severity)">
                  {{ risk.severity }}
                </span>
              </td>
              <td class="p-4">
                <span class="px-2 py-0.5 rounded bg-[#0B1020] border border-[#283247] text-[10px] text-gray-300 font-mono">
                  {{ risk.actionTaken }}
                </span>
              </td>
              <td class="p-4 text-right space-x-2">
                <button @click="dismissAlert(risk.id)" class="px-2 py-1 rounded bg-[#283247] hover:bg-[#374463] text-gray-300 text-[11px]">Dismiss</button>
                <button @click="sanctionUser(risk)" class="px-2 py-1 rounded bg-rose-600 hover:bg-rose-500 text-white text-[11px] font-semibold">Sanction</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const risks = ref([
  {
    id: 'RSK-99120',
    rule: 'OFF_PLATFORM_LEAK',
    actor: 'DarkTrader_99',
    actorId: 'usr_8192-4102',
    snippet: 'Add my discord fast: dark#8812 and paypal me direct',
    severity: 'HIGH',
    actionTaken: 'CHAT_MESSAGE_MASKED',
  },
  {
    id: 'RSK-99119',
    rule: 'ARTICLE_3_4_ACCOUNT_TRADE',
    actor: 'AccountWhale',
    actorId: 'usr_1092-8821',
    snippet: 'Selling level 100 PoE 2 character with original email & login credentials',
    severity: 'CRITICAL',
    actionTaken: 'LISTING_AUTO_REJECTED',
  },
  {
    id: 'RSK-99118',
    rule: 'VELOCITY_ANOMALY',
    actor: 'SpeedBuyerKR',
    actorId: 'usr_7712-4412',
    snippet: 'Initiated 7 consecutive high-value orders across different realms within 180 seconds',
    severity: 'MEDIUM',
    actionTaken: 'PAYMENT_TEMPORARY_HOLD',
  }
])

function getSeverityClass(sev: string) {
  switch (sev) {
    case 'CRITICAL': return 'bg-rose-500/20 text-rose-300 border-rose-500/40'
    case 'HIGH': return 'bg-rose-500/10 text-rose-400 border-rose-500/30'
    case 'MEDIUM': return 'bg-amber-500/10 text-amber-300 border-amber-500/30'
    default: return 'bg-blue-500/10 text-blue-300 border-blue-500/30'
  }
}

function dismissAlert(id: string) {
  risks.value = risks.value.filter(r => r.id !== id)
}

function sanctionUser(risk: any) {
  alert(`User ${risk.actor} suspended and placed under KYC Level 3 investigation.`)
  dismissAlert(risk.id)
}
</script>

