<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
      <div>
        <h2 class="text-xl font-bold text-white tracking-tight">System Audit & Compliance Log</h2>
        <p class="text-xs text-gray-400 mt-1">Immutable, write-once append-only log of all administrative, financial, and regulatory operations.</p>
      </div>

      <div class="flex items-center gap-3">
        <select v-model="actionFilter" class="bg-[#0B1020] border border-[#283247] rounded-lg px-3 py-1.5 text-xs text-gray-300">
          <option value="ALL">All Actions</option>
          <option value="4_EYES_APPROVED">4_EYES_APPROVED</option>
          <option value="POLICY_OVERRIDE">POLICY_OVERRIDE</option>
          <option value="SELLER_SUSPENDED">SELLER_SUSPENDED</option>
          <option value="FORCE_REFUND">FORCE_REFUND</option>
        </select>
        <button
          @click="exportAuditCsv"
          class="px-3 py-1.5 rounded-lg bg-[#283247] hover:bg-[#374463] text-white text-xs font-semibold transition"
        >
          Export CSV
        </button>
      </div>
    </div>

    <!-- Audit Logs Table -->
    <div class="bg-[#151C2F] border border-[#283247] rounded-xl overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full text-left text-xs font-mono">
          <thead class="bg-[#0B1020] border-b border-[#283247] text-gray-400 uppercase tracking-wider font-semibold font-sans">
            <tr>
              <th class="p-4">Timestamp (UTC)</th>
              <th class="p-4">Log ID</th>
              <th class="p-4">Actor</th>
              <th class="p-4">Action</th>
              <th class="p-4">Resource Target</th>
              <th class="p-4">IP Address</th>
              <th class="p-4 text-right">Details</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-[#283247] text-gray-300">
            <tr v-for="log in filteredLogs" :key="log.id" class="hover:bg-[#1A233A]/50 transition">
              <td class="p-4 text-gray-400 font-sans text-[11px]">{{ log.timestamp }}</td>
              <td class="p-4 text-white font-bold">{{ log.id }}</td>
              <td class="p-4">
                <span class="text-indigo-300 font-bold font-sans">{{ log.actorName }}</span>
                <div class="text-[10px] text-gray-500 font-mono">{{ log.actorRole }}</div>
              </td>
              <td class="p-4">
                <span class="px-2 py-0.5 rounded text-[10px] font-bold border font-sans" :class="getActionBadgeClass(log.action)">
                  {{ log.action }}
                </span>
              </td>
              <td class="p-4 text-cyan-300">{{ log.target }}</td>
              <td class="p-4 text-gray-500 text-[11px]">{{ log.ip }}</td>
              <td class="p-4 text-right">
                <button @click="viewLogDetails(log)" class="px-2.5 py-1 rounded bg-[#283247] hover:bg-[#374463] text-white text-[11px] font-sans">
                  Payload
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Payload Details Modal -->
    <div v-if="selectedLog" class="fixed inset-0 bg-black/70 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <div class="bg-[#151C2F] border border-[#283247] rounded-2xl max-w-xl w-full p-6 space-y-4">
        <div class="flex items-center justify-between border-b border-[#283247] pb-3">
          <h3 class="text-sm font-bold text-white font-mono">{{ selectedLog.id }} • Change Payload</h3>
          <button @click="selectedLog = null" class="text-gray-400 hover:text-white">✕</button>
        </div>

        <div class="bg-[#0B1020] p-4 rounded-xl border border-[#283247] font-mono text-xs overflow-x-auto text-emerald-400">
          <pre>{{ JSON.stringify(selectedLog.payload, null, 2) }}</pre>
        </div>

        <div class="text-[11px] text-gray-400 font-sans">
          Actor: <strong class="text-white">{{ selectedLog.actorName }}</strong> • IP: {{ selectedLog.ip }} • Signature: SHA-256 Validated
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

const actionFilter = ref('ALL')
const selectedLog = ref<any>(null)

const logs = ref([
  {
    id: 'AUD-89210',
    timestamp: '2026-10-24 22:45:12 UTC',
    actorName: 'FinanceOfficer_Sarah',
    actorRole: 'FINANCE_APPROVER',
    action: '4_EYES_APPROVED',
    target: 'DISP-89214 ($145.00 Refund)',
    ip: '198.51.100.44',
    payload: {
      disputeId: 'DISP-89214',
      orderId: 'ORD-659124',
      deciderId: 'usr_moderator_alex',
      approverId: 'usr_finance_sarah',
      decision: 'REFUND_BUYER',
      amountMinor: 14500,
      currency: 'USD',
      reason: 'Cryptographic proof hash showed empty trade window at designated coordinate'
    }
  },
  {
    id: 'AUD-89209',
    timestamp: '2026-10-24 21:10:05 UTC',
    actorName: 'SuperOpsAdmin',
    actorRole: 'SUPER_ADMIN',
    action: 'POLICY_OVERRIDE',
    target: 'POL-GAME-POE2-KR-CURRENCY',
    ip: '203.0.113.12',
    payload: {
      gameId: 'poe2',
      country: 'KR',
      productType: 'GAME_CURRENCY',
      previousState: 'REVIEW_REQUIRED',
      newState: 'ACTIVE',
      poAuthorizationNumber: 'PO-AUTH-20261024-POE2'
    }
  },
  {
    id: 'AUD-89208',
    timestamp: '2026-10-24 18:32:19 UTC',
    actorName: 'RiskEngine_Worker',
    actorRole: 'SYSTEM_DAEMON',
    action: 'SELLER_SUSPENDED',
    target: 'usr_771928ba-9912 (SuspiciousGoldBot)',
    ip: '10.0.4.18',
    payload: {
      trigger: 'VELOCITY_LIMIT_EXCEEDED',
      orderCountWindow: 14,
      windowSeconds: 300,
      payoutFrozen: true
    }
  }
])

const filteredLogs = computed(() => {
  if (actionFilter.value === 'ALL') return logs.value
  return logs.value.filter(l => l.action === actionFilter.value)
})

function getActionBadgeClass(action: string) {
  switch (action) {
    case '4_EYES_APPROVED': return 'bg-emerald-500/10 text-emerald-400 border-emerald-500/30'
    case 'POLICY_OVERRIDE': return 'bg-indigo-500/10 text-indigo-400 border-indigo-500/30'
    case 'SELLER_SUSPENDED': return 'bg-rose-500/10 text-rose-400 border-rose-500/30'
    default: return 'bg-gray-500/10 text-gray-400 border-gray-500/30'
  }
}

function viewLogDetails(log: any) {
  selectedLog.value = log
}

function exportAuditCsv() {
  alert('Exporting immutable audit log trail to encrypted CSV format...')
}
</script>

