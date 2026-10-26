<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
      <div>
        <h2 class="text-xl font-bold text-white tracking-tight">Master Order Ledger & Audit</h2>
        <p class="text-xs text-gray-400 mt-1">Supervise deterministic 14-state transitions, payment intents, and cryptographic delivery proofs.</p>
      </div>

      <div class="flex items-center gap-3">
        <input
          v-model="searchQuery"
          type="text"
          placeholder="Filter by Order ID or User..."
          class="bg-[#0B1020] border border-[#283247] rounded-lg px-3 py-1.5 text-xs text-white focus:outline-none focus:border-[#6366F1]"
        />
        <select v-model="statusFilter" class="bg-[#0B1020] border border-[#283247] rounded-lg px-3 py-1.5 text-xs text-gray-300">
          <option value="ALL">All States</option>
          <option value="DELIVERY_CLAIMED">DELIVERY_CLAIMED</option>
          <option value="IN_DELIVERY">IN_DELIVERY</option>
          <option value="PAYMENT_AUTHORIZED">PAYMENT_AUTHORIZED</option>
          <option value="COMPLETED">COMPLETED</option>
          <option value="DISPUTED">DISPUTED</option>
        </select>
      </div>
    </div>

    <!-- Orders Table -->
    <div class="bg-[#151C2F] border border-[#283247] rounded-xl overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full text-left text-xs">
          <thead class="bg-[#0B1020] border-b border-[#283247] text-gray-400 uppercase tracking-wider font-semibold">
            <tr>
              <th class="p-4">Order ID & Date</th>
              <th class="p-4">Game & Asset</th>
              <th class="p-4">Buyer / Seller</th>
              <th class="p-4">Amount (Escrow)</th>
              <th class="p-4">Current State</th>
              <th class="p-4">Delivery Proof Digest</th>
              <th class="p-4 text-right">Actions</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-[#283247] text-gray-300">
            <tr v-for="order in filteredOrders" :key="order.id" class="hover:bg-[#1A233A]/50 transition">
              <td class="p-4">
                <div class="font-mono font-bold text-white">{{ order.id }}</div>
                <div class="text-[10px] text-gray-500">{{ order.createdAt }}</div>
              </td>
              <td class="p-4">
                <div class="font-bold text-white">{{ order.title }}</div>
                <div class="text-[10px] text-indigo-300">{{ order.game }} ({{ order.server }})</div>
              </td>
              <td class="p-4 space-y-0.5">
                <div><span class="text-gray-500">B:</span> <strong class="text-white">{{ order.buyer }}</strong></div>
                <div><span class="text-gray-500">S:</span> <strong class="text-indigo-300">{{ order.seller }}</strong></div>
              </td>
              <td class="p-4 font-mono font-bold text-emerald-400">
                ${{ order.amount.toFixed(2) }} {{ order.currency }}
              </td>
              <td class="p-4">
                <span class="px-2 py-0.5 rounded text-[10px] font-bold border" :class="getStatusBadgeClass(order.status)">
                  {{ order.status }}
                </span>
              </td>
              <td class="p-4 font-mono text-[10px]">
                <span v-if="order.proofHash" class="text-cyan-400 truncate block max-w-[140px]" :title="order.proofHash">
                  {{ order.proofHash.slice(0, 16) }}...
                </span>
                <span v-else class="text-gray-600">PENDING_UPLOAD</span>
              </td>
              <td class="p-4 text-right space-x-2">
                <button @click="inspectOrder(order)" class="px-2.5 py-1 rounded bg-[#283247] hover:bg-[#374463] text-white text-[11px] transition">
                  Audit
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Order Inspection Drawer -->
    <div v-if="selectedOrder" class="fixed inset-0 bg-black/70 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <div class="bg-[#151C2F] border border-[#283247] rounded-2xl max-w-2xl w-full p-6 space-y-5">
        <div class="flex items-center justify-between border-b border-[#283247] pb-4">
          <div>
            <h3 class="text-base font-bold text-white font-mono">{{ selectedOrder.id }}</h3>
            <div class="text-xs text-gray-400">Deterministic State: <strong class="text-indigo-300">{{ selectedOrder.status }}</strong></div>
          </div>
          <button @click="selectedOrder = null" class="text-gray-400 hover:text-white">✕</button>
        </div>

        <div class="grid grid-cols-2 gap-4 text-xs font-mono">
          <div class="bg-[#0B1020] p-3 rounded-lg border border-[#283247] space-y-1">
            <div class="text-gray-500 uppercase text-[10px]">Payment Rail Transaction</div>
            <div class="text-white">pi_3M0912481092481092</div>
            <div class="text-emerald-400 text-[10px]">ESCROW_FUNDS_CAPTURED</div>
          </div>
          <div class="bg-[#0B1020] p-3 rounded-lg border border-[#283247] space-y-1">
            <div class="text-gray-500 uppercase text-[10px]">Inspection SLA Expiry</div>
            <div class="text-amber-300">2026-10-25 14:15 UTC</div>
            <div class="text-gray-500 text-[10px]">Auto-release if uncontested</div>
          </div>
        </div>

        <!-- Evidence SHA-256 Check -->
        <div class="bg-[#0B1020] p-3 rounded-lg border border-[#283247] text-xs space-y-1 font-mono">
          <div class="text-gray-400 uppercase text-[10px] font-sans font-semibold">Immutable Delivery SHA-256 Digest</div>
          <div class="text-cyan-300 break-all text-[11px]">{{ selectedOrder.proofHash || 'None' }}</div>
          <div class="text-gray-500 text-[10px] font-sans">Stored in S3-compatible cold storage (bucket: bn-gameex-evidence-vault)</div>
        </div>

        <!-- Admin Override Actions -->
        <div class="border-t border-[#283247] pt-4 flex items-center justify-between">
          <button class="px-3 py-1.5 rounded bg-[#283247] hover:bg-[#374463] text-white text-xs font-semibold">
            💬 Open In-Game Chat Log
          </button>
          <div class="space-x-2">
            <button
              v-if="selectedOrder.status !== 'COMPLETED'"
              @click="forceComplete(selectedOrder)"
              class="px-3 py-1.5 rounded bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-semibold"
            >
              Force Settle (Override)
            </button>
            <button
              v-if="selectedOrder.status !== 'CANCELLED'"
              @click="forceRefund(selectedOrder)"
              class="px-3 py-1.5 rounded bg-rose-600 hover:bg-rose-500 text-white text-xs font-semibold"
            >
              Force Refund to Buyer
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

const searchQuery = ref('')
const statusFilter = ref('ALL')
const selectedOrder = ref<any>(null)

const orders = ref([
  {
    id: 'ORD-847291',
    createdAt: '2026-10-24 19:15 UTC',
    game: 'Path of Exile 2',
    server: 'Standard League',
    title: '5,000x Chaos Orb',
    buyer: 'WraeclastSlayer_99',
    seller: 'ExileTraderPRO',
    amount: 42.50,
    currency: 'USD',
    status: 'DELIVERY_CLAIMED',
    proofHash: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'
  },
  {
    id: 'ORD-920148',
    createdAt: '2026-10-24 22:20 UTC',
    game: 'World of Warcraft',
    server: 'Frostmourne US',
    title: '500,000 WoW Gold',
    buyer: 'FrostMage99',
    seller: 'AzerothVault',
    amount: 75.00,
    currency: 'USD',
    status: 'PAYMENT_AUTHORIZED',
    proofHash: null
  },
  {
    id: 'ORD-719302',
    createdAt: '2026-10-24 20:00 UTC',
    game: 'Final Fantasy XIV',
    server: 'Chocobo (Mana)',
    title: '10,000,000 Gil',
    buyer: 'Noctis_Lucii',
    seller: 'MogCourier',
    amount: 32.00,
    currency: 'USD',
    status: 'IN_DELIVERY',
    proofHash: null
  },
  {
    id: 'ORD-782103',
    createdAt: '2026-10-23 14:10 UTC',
    game: 'Elden Ring',
    server: 'Global Multiplayer',
    title: 'Lord Rune Stacks (99x Stack x 7)',
    buyer: 'RuneSeeker',
    seller: 'TarnishedMerchant',
    amount: 19.99,
    currency: 'USD',
    status: 'COMPLETED',
    proofHash: '9a84218eb019284fa10928410294810294810294810294810294810294810294'
  },
  {
    id: 'ORD-659124',
    createdAt: '2026-10-22 11:05 UTC',
    game: 'Lineage W',
    server: 'Eva 01',
    title: 'Blessed Armor Enchant Scroll x 10',
    buyer: 'BloodKnight_KR',
    seller: 'AdenBlacksmith',
    amount: 145.00,
    currency: 'USD',
    status: 'DISPUTED',
    proofHash: '4f92182048102948102948102948102948102948102948102948102948102948'
  }
])

const filteredOrders = computed(() => {
  return orders.value.filter(o => {
    const matchesSearch = o.id.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
                          o.buyer.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
                          o.seller.toLowerCase().includes(searchQuery.value.toLowerCase())
    const matchesStatus = statusFilter.value === 'ALL' || o.status === statusFilter.value
    return matchesSearch && matchesStatus
  })
})

function getStatusBadgeClass(status: string) {
  switch (status) {
    case 'DELIVERY_CLAIMED': return 'bg-cyan-500/10 text-cyan-300 border-cyan-500/30'
    case 'PAYMENT_AUTHORIZED': return 'bg-amber-500/10 text-amber-300 border-amber-500/30'
    case 'IN_DELIVERY': return 'bg-blue-500/10 text-blue-300 border-blue-500/30'
    case 'COMPLETED': return 'bg-emerald-500/10 text-emerald-400 border-emerald-500/30'
    case 'DISPUTED': return 'bg-rose-500/10 text-rose-300 border-rose-500/30'
    default: return 'bg-gray-500/10 text-gray-400 border-gray-500/30'
  }
}

function inspectOrder(order: any) {
  selectedOrder.value = order
}

function forceComplete(order: any) {
  order.status = 'COMPLETED'
  selectedOrder.value = null
  alert(`Order ${order.id} forcibly marked as COMPLETED by Super Admin. Escrow disbursed.`)
}

function forceRefund(order: any) {
  order.status = 'REFUNDED'
  selectedOrder.value = null
  alert(`Order ${order.id} refunded back to buyer via payment provider.`)
}
</script>

