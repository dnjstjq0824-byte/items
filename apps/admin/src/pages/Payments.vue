<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
      <div>
        <h2 class="text-xl font-bold text-white tracking-tight">Payment Rails & PSP Webhook Gateway</h2>
        <p class="text-xs text-gray-400 mt-1">Audit external payment provider integrations, HMAC-SHA256 signatures, and idempotency protection.</p>
      </div>

      <div class="flex items-center gap-3">
        <button
          @click="simulateWebhook"
          class="px-3 py-1.5 rounded-lg bg-[#283247] hover:bg-[#374463] text-white text-xs font-semibold transition flex items-center gap-1.5"
        >
          <span>⚡</span> Simulate PSP Webhook
        </button>
      </div>
    </div>

    <!-- Provider Health Status Cards -->
    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
      <div class="bg-[#151C2F] border border-[#283247] p-4 rounded-xl flex items-center justify-between">
        <div>
          <div class="text-xs text-gray-400">Stripe Payments (Credit/Debit/ApplePay)</div>
          <div class="text-base font-bold text-white mt-1">CONNECTED</div>
          <div class="text-[10px] text-emerald-400 mt-0.5">Latency: 142ms • Signature: HMAC-SHA256</div>
        </div>
        <span class="w-3 h-3 rounded-full bg-emerald-400"></span>
      </div>

      <div class="bg-[#151C2F] border border-[#283247] p-4 rounded-xl flex items-center justify-between">
        <div>
          <div class="text-xs text-gray-400">Stripe Connect (Seller Payout Rails)</div>
          <div class="text-base font-bold text-white mt-1">CONNECTED</div>
          <div class="text-[10px] text-emerald-400 mt-0.5">Automated Daily Sweeps Active</div>
        </div>
        <span class="w-3 h-3 rounded-full bg-emerald-400"></span>
      </div>

      <div class="bg-[#151C2F] border border-[#283247] p-4 rounded-xl flex items-center justify-between">
        <div>
          <div class="text-xs text-gray-400">Wise Multi-Currency Wire</div>
          <div class="text-base font-bold text-white mt-1">STANDBY</div>
          <div class="text-[10px] text-gray-400 mt-0.5">Cross-border payout failover rail</div>
        </div>
        <span class="w-3 h-3 rounded-full bg-amber-400"></span>
      </div>
    </div>

    <!-- Inbound Webhook Event Log -->
    <div class="bg-[#151C2F] border border-[#283247] rounded-xl overflow-hidden">
      <div class="p-4 border-b border-[#283247] flex items-center justify-between">
        <h3 class="text-sm font-semibold text-white">Inbound Webhook Event Audit Trail</h3>
        <span class="text-xs text-gray-400 font-mono">100% Replay Protection Enforced</span>
      </div>

      <div class="overflow-x-auto">
        <table class="w-full text-left text-xs font-mono">
          <thead class="bg-[#0B1020] border-b border-[#283247] text-gray-400 uppercase tracking-wider font-semibold font-sans">
            <tr>
              <th class="p-4">Event ID</th>
              <th class="p-4">Provider</th>
              <th class="p-4">Event Type</th>
              <th class="p-4">Order ID</th>
              <th class="p-4">Amount</th>
              <th class="p-4">Signature</th>
              <th class="p-4">Status</th>
              <th class="p-4 text-right">Timestamp</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-[#283247] text-gray-300">
            <tr v-for="evt in webhooks" :key="evt.id" class="hover:bg-[#1A233A]/50 transition">
              <td class="p-4 text-white font-bold">{{ evt.id }}</td>
              <td class="p-4 font-sans font-medium">{{ evt.provider }}</td>
              <td class="p-4 text-indigo-300">{{ evt.type }}</td>
              <td class="p-4 text-gray-400">{{ evt.orderId }}</td>
              <td class="p-4 font-bold text-emerald-400">${{ evt.amount.toFixed(2) }} {{ evt.currency }}</td>
              <td class="p-4">
                <span class="px-1.5 py-0.5 rounded bg-emerald-500/10 text-emerald-400 border border-emerald-500/30 text-[10px]">
                  HMAC_OK
                </span>
              </td>
              <td class="p-4 font-sans">
                <span class="px-2 py-0.5 rounded text-[10px] font-semibold" :class="evt.status === 'PROCESSED' ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/30' : 'bg-amber-500/10 text-amber-300 border border-amber-500/30'">
                  {{ evt.status }}
                </span>
              </td>
              <td class="p-4 text-right text-gray-500 text-[11px]">{{ evt.timestamp }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const webhooks = ref([
  {
    id: 'evt_3M82109482104812',
    provider: 'Stripe Sandbox',
    type: 'payment_intent.succeeded',
    orderId: 'ORD-847291',
    amount: 42.50,
    currency: 'USD',
    status: 'PROCESSED',
    timestamp: '2026-10-24 19:15:32 UTC'
  },
  {
    id: 'evt_3M71920481029481',
    provider: 'Stripe Sandbox',
    type: 'payment_intent.succeeded',
    orderId: 'ORD-719302',
    amount: 32.00,
    currency: 'USD',
    status: 'PROCESSED',
    timestamp: '2026-10-24 20:00:18 UTC'
  },
  {
    id: 'evt_3M65912401928410',
    provider: 'Stripe Sandbox',
    type: 'payment_intent.succeeded',
    orderId: 'ORD-659124',
    amount: 145.00,
    currency: 'USD',
    status: 'PROCESSED',
    timestamp: '2026-10-22 11:05:40 UTC'
  },
  {
    id: 'evt_3M51029481029481',
    provider: 'Stripe Connect',
    type: 'payout.paid',
    orderId: 'PAYOUT-10948',
    amount: 2450.00,
    currency: 'USD',
    status: 'PROCESSED',
    timestamp: '2026-10-21 14:00:05 UTC'
  }
])

function simulateWebhook() {
  const newEvt = {
    id: `evt_sim_${Date.now().toString().slice(-8)}`,
    provider: 'Stripe Sandbox',
    type: 'payment_intent.succeeded',
    orderId: `ORD-${Math.floor(100000 + Math.random() * 900000)}`,
    amount: parseFloat((10 + Math.random() * 100).toFixed(2)),
    currency: 'USD',
    status: 'PROCESSED',
    timestamp: new Date().toISOString().replace('T', ' ').slice(0, 19) + ' UTC'
  }
  webhooks.value.unshift(newEvt)
  alert(`Simulated webhook ${newEvt.id} successfully processed and added to ledger audit trail.`)
}
</script>

