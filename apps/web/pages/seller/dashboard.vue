<template>
  <div class="max-w-7xl mx-auto px-4 py-8">
    <!-- Header & Seller Status -->
    <div class="flex flex-col lg:flex-row lg:items-center justify-between gap-6 mb-8">
      <div>
        <div class="flex items-center gap-3">
          <h1 class="text-2xl font-bold text-white tracking-tight">Seller Operations Center</h1>
          <span class="px-2 py-0.5 rounded bg-indigo-500/20 text-indigo-300 border border-indigo-500/30 text-xs font-semibold">
            PRO SELLER (Tier 3)
          </span>
          <span class="px-2 py-0.5 rounded bg-emerald-500/10 text-emerald-400 border border-emerald-500/30 text-xs font-medium">
            KYC VERIFIED
          </span>
        </div>
        <p class="text-xs text-gray-400 mt-1">Manage approved inventory, submit delivery evidence, and withdraw settled payouts.</p>
      </div>

      <div class="flex items-center gap-3">
        <button
          @click="showListingModal = true"
          class="px-4 py-2 rounded-lg bg-[#6366F1] hover:bg-[#4F46E5] text-white text-xs font-semibold transition flex items-center gap-1.5"
        >
          <span>+</span> Create New Listing
        </button>
        <button
          @click="showPayoutModal = true"
          class="px-4 py-2 rounded-lg bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-semibold transition flex items-center gap-1.5"
        >
          <span>💰</span> Request Payout
        </button>
      </div>
    </div>

    <!-- Financial & Performance KPI Cards -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
      <div class="bg-[#151C2F] border border-[#283247] rounded-xl p-5">
        <div class="text-xs text-gray-400 font-medium">Available for Payout</div>
        <div class="text-2xl font-bold text-emerald-400 font-mono mt-1">$1,420.50 <span class="text-xs text-gray-400 font-normal">USD</span></div>
        <div class="text-[11px] text-gray-500 mt-2">Zero custody • Routed via external PSP rails</div>
      </div>

      <div class="bg-[#151C2F] border border-[#283247] rounded-xl p-5">
        <div class="text-xs text-gray-400 font-medium">Locked in Escrow</div>
        <div class="text-2xl font-bold text-amber-300 font-mono mt-1">$340.00 <span class="text-xs text-gray-400 font-normal">USD</span></div>
        <div class="text-[11px] text-amber-400/80 mt-2">4 orders awaiting delivery/confirmation</div>
      </div>

      <div class="bg-[#151C2F] border border-[#283247] rounded-xl p-5">
        <div class="text-xs text-gray-400 font-medium">30-Day Trading Volume</div>
        <div class="text-2xl font-bold text-white font-mono mt-1">$12,850.00</div>
        <div class="text-[11px] text-emerald-400 mt-2">↑ +14.2% vs previous month</div>
      </div>

      <div class="bg-[#151C2F] border border-[#283247] rounded-xl p-5">
        <div class="text-xs text-gray-400 font-medium">Reputation & Success Rate</div>
        <div class="text-2xl font-bold text-indigo-400 font-mono mt-1">99.8%</div>
        <div class="text-[11px] text-gray-400 mt-2">0.04% dispute rate (Tier S performance)</div>
      </div>
    </div>

    <!-- Management Tabs -->
    <div class="flex items-center gap-2 border-b border-[#283247] pb-3 mb-6 text-xs font-semibold">
      <button
        v-for="t in ['pending_fulfillment', 'active_listings', 'settlement_history']"
        :key="t"
        @click="currentTab = t"
        class="px-4 py-2 rounded-lg transition"
        :class="currentTab === t ? 'bg-[#6366F1] text-white' : 'text-gray-400 hover:text-white hover:bg-[#151C2F]'"
      >
        <span v-if="t === 'pending_fulfillment'">Pending Fulfillments ({{ pendingOrders.length }})</span>
        <span v-else-if="t === 'active_listings'">Active Listings ({{ listings.length }})</span>
        <span v-else>Settled Payouts</span>
      </button>
    </div>

    <!-- Tab 1: Pending Fulfillments (Article 15 Handover SLA) -->
    <div v-if="currentTab === 'pending_fulfillment'" class="space-y-4">
      <div v-for="order in pendingOrders" :key="order.id" class="bg-[#151C2F] border border-[#283247] rounded-xl p-5 flex flex-col lg:flex-row lg:items-center justify-between gap-6">
        <div class="space-y-2">
          <div class="flex items-center gap-3 text-xs">
            <span class="font-mono text-gray-400 font-semibold">{{ order.id }}</span>
            <span class="px-2 py-0.5 rounded bg-blue-500/10 text-blue-300 border border-blue-500/30 font-semibold">
              {{ order.status }}
            </span>
            <span class="text-amber-400 font-mono text-[11px]">⏰ SLA Remaining: {{ order.slaRemaining }}</span>
          </div>

          <h3 class="text-base font-bold text-white">{{ order.game }} — {{ order.itemTitle }}</h3>

          <div class="grid grid-cols-2 sm:grid-cols-4 gap-3 text-xs text-gray-400 pt-1">
            <div>Quantity: <strong class="text-white">{{ order.quantity }}</strong></div>
            <div>Buyer Character: <strong class="text-indigo-300 font-mono">{{ order.buyerCharacter }}</strong></div>
            <div>Handover Point: <strong class="text-white">{{ order.handoverLocation }}</strong></div>
            <div>Net Payout: <strong class="text-emerald-400 font-mono">${{ order.netPayout.toFixed(2) }} USD</strong></div>
          </div>
        </div>

        <div class="flex items-center gap-3 shrink-0">
          <button
            @click="openEvidenceModal(order)"
            class="px-4 py-2.5 rounded-lg bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-semibold shadow-lg shadow-emerald-900/30 transition flex items-center gap-1.5"
          >
            <span>📷</span> Submit Delivery Proof
          </button>
        </div>
      </div>

      <div v-if="pendingOrders.length === 0" class="p-8 text-center bg-[#151C2F] border border-[#283247] rounded-xl text-gray-400 text-xs">
        No orders awaiting fulfillment right now. Great job keeping up with handover SLAs!
      </div>
    </div>

    <!-- Tab 2: Active Listings Management -->
    <div v-if="currentTab === 'active_listings'" class="space-y-4">
      <div class="bg-[#151C2F] border border-[#283247] rounded-xl overflow-hidden">
        <div class="overflow-x-auto">
          <table class="w-full text-left text-xs">
            <thead class="bg-[#0B1020] border-b border-[#283247] text-gray-400 uppercase tracking-wider font-semibold">
              <tr>
                <th class="p-4">Game & Item</th>
                <th class="p-4">Product Type</th>
                <th class="p-4">Available Stock</th>
                <th class="p-4">Unit Price</th>
                <th class="p-4">Platform Fee</th>
                <th class="p-4">Status</th>
                <th class="p-4 text-right">Actions</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-[#283247] text-gray-300">
              <tr v-for="item in listings" :key="item.id" class="hover:bg-[#1A233A]/50 transition">
                <td class="p-4">
                  <div class="font-bold text-white">{{ item.title }}</div>
                  <div class="text-[11px] text-gray-500">{{ item.game }} / {{ item.server }}</div>
                </td>
                <td class="p-4">
                  <span class="px-2 py-0.5 rounded bg-[#0B1020] border border-[#283247] font-mono text-[10px] text-indigo-300">
                    {{ item.type }}
                  </span>
                </td>
                <td class="p-4 font-mono font-bold text-white">
                  {{ item.stock.toLocaleString() }} {{ item.unit }}
                </td>
                <td class="p-4 font-mono font-bold text-emerald-400">
                  ${{ item.price.toFixed(4) }} / {{ item.unit }}
                </td>
                <td class="p-4 text-gray-400 font-mono">
                  5.0%
                </td>
                <td class="p-4">
                  <span class="px-2 py-0.5 rounded bg-emerald-500/10 text-emerald-400 border border-emerald-500/30 text-[10px] font-semibold">
                    ACTIVE
                  </span>
                </td>
                <td class="p-4 text-right space-x-2">
                  <button class="px-2.5 py-1 rounded bg-[#283247] hover:bg-[#374463] text-white text-[11px]">Edit</button>
                  <button class="px-2.5 py-1 rounded bg-rose-500/10 hover:bg-rose-500/20 text-rose-300 border border-rose-500/30 text-[11px]">Pause</button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>

    <!-- Tab 3: Settled Payouts -->
    <div v-if="currentTab === 'settlement_history'" class="bg-[#151C2F] border border-[#283247] rounded-xl p-6">
      <h3 class="text-sm font-semibold text-white mb-4">External Rail Payout History</h3>
      <div class="space-y-3 font-mono text-xs">
        <div class="p-4 bg-[#0B1020] rounded-lg border border-[#283247] flex flex-col sm:flex-row justify-between items-start sm:items-center gap-2">
          <div>
            <div class="font-bold text-white">PAYOUT-10948 • Stripe Direct Transfer (US Checking •••• 4821)</div>
            <div class="text-[11px] text-gray-500">2026-10-21 14:00 UTC • Batch Reference: ST-TR-994821</div>
          </div>
          <div class="text-right">
            <div class="text-base font-bold text-emerald-400">+$2,450.00 USD</div>
            <div class="text-[10px] text-emerald-500 font-sans">COMPLETED & RECONCILED</div>
          </div>
        </div>

        <div class="p-4 bg-[#0B1020] rounded-lg border border-[#283247] flex flex-col sm:flex-row justify-between items-start sm:items-center gap-2">
          <div>
            <div class="font-bold text-white">PAYOUT-10912 • Stripe Direct Transfer (US Checking •••• 4821)</div>
            <div class="text-[11px] text-gray-500">2026-10-14 11:30 UTC • Batch Reference: ST-TR-881294</div>
          </div>
          <div class="text-right">
            <div class="text-base font-bold text-emerald-400">+$1,890.00 USD</div>
            <div class="text-[10px] text-emerald-500 font-sans">COMPLETED & RECONCILED</div>
          </div>
        </div>
      </div>
    </div>

    <!-- Payout Request Modal -->
    <div v-if="showPayoutModal" class="fixed inset-0 bg-black/70 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <div class="bg-[#151C2F] border border-[#283247] rounded-2xl max-w-md w-full p-6 space-y-4">
        <h3 class="text-lg font-bold text-white">Request External Rail Payout</h3>
        <p class="text-xs text-gray-300">
          Available Settled Escrow: <strong class="text-emerald-400 font-mono">$1,420.50 USD</strong>
        </p>

        <div>
          <label class="block text-xs text-gray-400 mb-1">Withdrawal Amount ($ USD)</label>
          <input
            v-model.number="payoutAmount"
            type="number"
            min="50"
            max="1420.50"
            class="w-full bg-[#0B1020] border border-[#283247] rounded-lg px-3 py-2 text-sm text-white font-mono"
          />
        </div>

        <div>
          <label class="block text-xs text-gray-400 mb-1">Payout Destination Rail</label>
          <select class="w-full bg-[#0B1020] border border-[#283247] rounded-lg px-3 py-2 text-xs text-white">
            <option>Stripe Connect Express (US Checking •••• 4821)</option>
            <option>Wise Multi-Currency Borderless Payout (USD/EUR/GBP)</option>
          </select>
        </div>

        <div class="bg-[#0B1020] p-3 rounded-lg border border-[#283247] text-[11px] space-y-1 text-gray-400">
          <div class="flex justify-between">
            <span>Pass-through Rail Fee:</span>
            <span class="text-white font-mono">$0.25 + 0.25%</span>
          </div>
          <div class="flex justify-between">
            <span>Estimated Arrival:</span>
            <span class="text-white">Instant / Same-Day ACH</span>
          </div>
        </div>

        <div class="flex items-center justify-end gap-3 pt-3">
          <button @click="showPayoutModal = false" class="px-4 py-2 rounded-lg bg-[#283247] text-white text-xs font-semibold">
            Cancel
          </button>
          <button @click="executePayout" class="px-4 py-2 rounded-lg bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-semibold">
            Confirm Payout Request
          </button>
        </div>
      </div>
    </div>

    <!-- Evidence Submission Modal (Article 15 SHA-256) -->
    <div v-if="showEvidenceModal" class="fixed inset-0 bg-black/70 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <div class="bg-[#151C2F] border border-[#283247] rounded-2xl max-w-lg w-full p-6 space-y-4">
        <h3 class="text-lg font-bold text-white">Submit In-Game Delivery Proof</h3>
        <p class="text-xs text-gray-300">
          Order: <strong class="text-white font-mono">{{ activeEvidenceOrder?.id }}</strong> • Buyer: <strong class="text-indigo-300 font-mono">{{ activeEvidenceOrder?.buyerCharacter }}</strong>
        </p>

        <div class="border-2 border-dashed border-[#283247] hover:border-[#6366F1] rounded-xl p-6 text-center bg-[#0B1020] cursor-pointer">
          <div class="text-3xl mb-2">📸</div>
          <div class="text-xs font-semibold text-white">Drop in-game trade screenshot or browse</div>
          <div class="text-[10px] text-gray-500 mt-1">Accepts PNG, JPG, WEBP (Max 25MB). Auto-hashed with SHA-256 upon upload.</div>
        </div>

        <div>
          <label class="block text-xs text-gray-400 mb-1">Handover Notes / Verification Code</label>
          <input
            v-model="evidenceNotes"
            type="text"
            placeholder="e.g. In-game trade completed at 14:22 in Dalaran bank"
            class="w-full bg-[#0B1020] border border-[#283247] rounded-lg px-3 py-2 text-xs text-white"
          />
        </div>

        <div class="p-3 rounded-lg bg-indigo-500/10 border border-indigo-500/30 text-[11px] text-indigo-300">
          ℹ️ Once submitted, the buyer is notified and the inspection timer starts. If the buyer doesn't dispute or confirm within 24 hours, the system will automatically release funds.
        </div>

        <div class="flex items-center justify-end gap-3 pt-3">
          <button @click="showEvidenceModal = false" class="px-4 py-2 rounded-lg bg-[#283247] text-white text-xs font-semibold">
            Cancel
          </button>
          <button @click="submitDeliveryEvidence" class="px-4 py-2 rounded-lg bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-semibold">
            Sign & Submit Proof
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const currentTab = ref('pending_fulfillment')
const showPayoutModal = ref(false)
const showEvidenceModal = ref(false)
const showListingModal = ref(false)
const payoutAmount = ref(500)
const evidenceNotes = ref('')
const activeEvidenceOrder = ref<any>(null)

const pendingOrders = ref([
  {
    id: 'ORD-719302',
    game: 'Final Fantasy XIV',
    itemTitle: '10,000,000 Gil Handover at Limsa Lominsa',
    quantity: '10,000,000 Gil',
    buyerCharacter: 'Noctis_Lucii',
    handoverLocation: 'Limsa Lominsa Lower Decks (Hawkers\' Alley)',
    netPayout: 30.40,
    status: 'IN_DELIVERY',
    slaRemaining: '1h 45m',
  }
])

const listings = ref([
  {
    id: 'LST-001',
    title: '5,000x Chaos Orb (Direct Handover)',
    game: 'Path of Exile 2',
    server: 'Standard League',
    type: 'GAME_CURRENCY',
    stock: 45000,
    unit: 'Orbs',
    price: 0.0085,
  },
  {
    id: 'LST-002',
    title: 'Divine Orb Stack (20x)',
    game: 'Path of Exile 2',
    server: 'Standard League',
    type: 'GAME_ITEM',
    stock: 120,
    unit: 'Divine',
    price: 1.15,
  },
  {
    id: 'LST-003',
    title: '1,000,000 WoW Gold Handover',
    game: 'World of Warcraft',
    server: 'Frostmourne US',
    type: 'GAME_CURRENCY',
    stock: 5000000,
    unit: 'Gold',
    price: 0.15,
  }
])

function openEvidenceModal(order: any) {
  activeEvidenceOrder.value = order
  showEvidenceModal.value = true
}

function submitDeliveryEvidence() {
  if (activeEvidenceOrder.value) {
    const idx = pendingOrders.value.findIndex(o => o.id === activeEvidenceOrder.value.id)
    if (idx !== -1) {
      pendingOrders.value.splice(idx, 1)
    }
    showEvidenceModal.value = false
    alert('Cryptographic delivery proof signed and submitted! Order moved to Awaiting Buyer Confirmation.')
  }
}

function executePayout() {
  showPayoutModal.value = false
  alert(`Payout of $${payoutAmount.value} USD requested. Sent to Stripe Connect external payout rail.`)
}
</script>

