<template>
  <div class="max-w-7xl mx-auto px-4 py-8">
    <div class="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-8">
      <div>
        <h1 class="text-2xl font-bold text-white tracking-tight">My Orders</h1>
        <p class="text-sm text-gray-400 mt-1">Manage and track your digital asset trades, proof of delivery, and disputes.</p>
      </div>

      <div class="flex items-center gap-3">
        <NuxtLink to="/games" class="px-4 py-2 rounded-lg bg-[#6366F1] hover:bg-[#4F46E5] text-white text-xs font-semibold transition">
          Browse Games & Items
        </NuxtLink>
        <NuxtLink to="/seller/dashboard" class="px-4 py-2 rounded-lg bg-[#151C2F] hover:bg-[#283247] border border-[#283247] text-gray-300 text-xs font-semibold transition">
          Seller Hub
        </NuxtLink>
      </div>
    </div>

    <!-- Filter Tabs -->
    <div class="flex items-center gap-2 border-b border-[#283247] pb-4 mb-6 overflow-x-auto text-xs font-medium">
      <button
        v-for="tab in tabs"
        :key="tab.id"
        @click="activeTab = tab.id"
        class="px-3 py-1.5 rounded-lg transition whitespace-nowrap"
        :class="activeTab === tab.id ? 'bg-[#6366F1] text-white font-semibold' : 'text-gray-400 hover:text-white hover:bg-[#151C2F]'"
      >
        {{ tab.label }}
        <span class="ml-1.5 px-1.5 py-0.2 rounded-full text-[10px]" :class="activeTab === tab.id ? 'bg-white/20 text-white' : 'bg-[#151C2F] text-gray-400'">
          {{ tab.count }}
        </span>
      </button>
    </div>

    <!-- Orders List -->
    <div v-if="filteredOrders.length > 0" class="space-y-4">
      <div
        v-for="order in filteredOrders"
        :key="order.id"
        class="bg-[#151C2F] border border-[#283247] rounded-xl p-5 hover:border-[#6366F1]/50 transition flex flex-col lg:flex-row lg:items-center justify-between gap-6"
      >
        <div class="space-y-3 flex-1">
          <div class="flex flex-wrap items-center gap-3 text-xs">
            <span class="font-mono text-gray-400 font-semibold">{{ order.id }}</span>
            <span class="text-gray-600">•</span>
            <span class="text-gray-400">{{ order.createdAt }}</span>
            <span class="text-gray-600">•</span>
            <span class="px-2 py-0.5 rounded text-[11px] font-semibold border" :class="getStatusBadgeClass(order.status)">
              {{ order.statusLabel }}
            </span>
            <span v-if="order.autoReleaseCountdown" class="text-amber-400 text-[11px] font-mono flex items-center gap-1">
              ⏳ Auto-confirms in: {{ order.autoReleaseCountdown }}
            </span>
          </div>

          <div class="flex items-start gap-4">
            <div class="w-12 h-12 rounded-lg bg-[#0B1020] border border-[#283247] flex items-center justify-center text-xl shrink-0">
              {{ order.gameIcon }}
            </div>
            <div>
              <div class="flex items-center gap-2">
                <span class="text-xs text-indigo-400 font-semibold">{{ order.game }}</span>
                <span class="text-xs text-gray-500">/ {{ order.platform }} / {{ order.server }}</span>
              </div>
              <h2 class="text-base font-bold text-white mt-0.5">{{ order.title }}</h2>
              <div class="text-xs text-gray-400 mt-1 flex items-center gap-4">
                <span>Quantity: <strong class="text-white">{{ order.quantity }} {{ order.unit }}</strong></span>
                <span>Unit Price: <strong class="text-white">${{ order.unitPrice.toFixed(2) }}</strong></span>
                <span>Seller: <strong class="text-indigo-300">{{ order.sellerName }}</strong> ({{ order.sellerRep }}% rep)</span>
              </div>
            </div>
          </div>
        </div>

        <div class="flex flex-col sm:flex-row lg:flex-col items-start lg:items-end justify-between border-t lg:border-t-0 pt-4 lg:pt-0 border-[#283247] gap-3 shrink-0">
          <div class="text-left lg:text-right">
            <div class="text-xs text-gray-400">Total Paid (Escrow Protected)</div>
            <div class="text-xl font-bold text-emerald-400 font-mono">${{ order.totalAmount.toFixed(2) }} {{ order.currency }}</div>
          </div>

          <div class="flex items-center gap-2 w-full sm:w-auto">
            <NuxtLink
              :to="`/my/orders/${order.id}`"
              class="px-4 py-2 rounded-lg bg-[#283247] hover:bg-[#374463] text-white text-xs font-semibold transition"
            >
              Order Details
            </NuxtLink>

            <button
              v-if="order.status === 'DELIVERY_CLAIMED'"
              @click="confirmReceipt(order.id)"
              class="px-4 py-2 rounded-lg bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-semibold transition shadow-lg shadow-emerald-900/30"
            >
              Confirm Receipt
            </button>

            <button
              v-else-if="order.status === 'PAYMENT_PENDING'"
              class="px-4 py-2 rounded-lg bg-indigo-600 hover:bg-indigo-500 text-white text-xs font-semibold transition"
            >
              Complete Payment
            </button>

            <NuxtLink
              v-if="order.status === 'DELIVERY_CLAIMED' || order.status === 'IN_DELIVERY'"
              :to="`/my/orders/${order.id}?action=dispute`"
              class="px-3 py-2 rounded-lg bg-rose-500/10 hover:bg-rose-500/20 text-rose-300 border border-rose-500/30 text-xs font-medium transition"
            >
              Open Dispute
            </NuxtLink>
          </div>
        </div>
      </div>
    </div>

    <!-- Empty State -->
    <div v-else class="bg-[#151C2F] border border-[#283247] rounded-xl p-12 text-center text-gray-400">
      <div class="text-3xl mb-3">📦</div>
      <h3 class="text-base font-semibold text-white">No orders found in this category</h3>
      <p class="text-xs mt-1">Explore our approved game catalog to purchase trade-verified items and game currency.</p>
      <NuxtLink to="/games" class="inline-block mt-4 px-4 py-2 rounded-lg bg-[#6366F1] text-white text-xs font-semibold hover:bg-[#4F46E5] transition">
        Browse Games
      </NuxtLink>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

const activeTab = ref('all')

const tabs = ref([
  { id: 'all', label: 'All Orders', count: 5 },
  { id: 'pending', label: 'Pending Payment', count: 1 },
  { id: 'in_delivery', label: 'In Delivery', count: 1 },
  { id: 'awaiting_confirmation', label: 'Delivery Claimed', count: 1 },
  { id: 'completed', label: 'Completed', count: 1 },
  { id: 'disputed', label: 'Disputed', count: 1 },
])

const orders = ref([
  {
    id: 'ORD-847291',
    createdAt: '2026-10-24 19:15 UTC',
    game: 'Path of Exile 2',
    gameIcon: '⚔️',
    platform: 'PC',
    server: 'Standard League',
    title: '5,000x Chaos Orb (Direct In-Game Face-to-Face Trade)',
    quantity: 5000,
    unit: 'Chaos Orbs',
    unitPrice: 0.0085,
    totalAmount: 42.50,
    currency: 'USD',
    sellerName: 'ExileTraderPRO',
    sellerRep: 99.8,
    status: 'DELIVERY_CLAIMED',
    statusLabel: 'Delivery Claimed (Proof Uploaded)',
    autoReleaseCountdown: '18h 42m',
  },
  {
    id: 'ORD-920148',
    createdAt: '2026-10-24 22:20 UTC',
    game: 'World of Warcraft',
    gameIcon: '🛡️',
    platform: 'PC',
    server: 'Frostmourne US',
    title: '500,000 WoW Gold (Guild Bank Handover)',
    quantity: 500,
    unit: 'k Gold',
    unitPrice: 0.15,
    totalAmount: 75.00,
    currency: 'USD',
    sellerName: 'AzerothVault',
    sellerRep: 99.4,
    status: 'PAYMENT_PENDING',
    statusLabel: 'Payment Pending',
    autoReleaseCountdown: '11m 30s',
  },
  {
    id: 'ORD-719302',
    createdAt: '2026-10-24 20:00 UTC',
    game: 'Final Fantasy XIV',
    gameIcon: '🔮',
    platform: 'PC',
    server: 'Chocobo (Mana)',
    title: '10,000,000 Gil Handover at Limsa Lominsa',
    quantity: 10,
    unit: 'M Gil',
    unitPrice: 3.20,
    totalAmount: 32.00,
    currency: 'USD',
    sellerName: 'MogCourier',
    sellerRep: 100.0,
    status: 'IN_DELIVERY',
    statusLabel: 'Seller Preparing Handover',
    autoReleaseCountdown: null,
  },
  {
    id: 'ORD-782103',
    createdAt: '2026-10-23 14:10 UTC',
    game: 'Elden Ring',
    gameIcon: '💍',
    platform: 'PC',
    server: 'Global Multiplayer',
    title: 'Lord Rune Stacks (99x Stack x 7) Summon Handover',
    quantity: 1,
    unit: 'Package',
    unitPrice: 19.99,
    totalAmount: 19.99,
    currency: 'USD',
    sellerName: 'TarnishedMerchant',
    sellerRep: 98.9,
    status: 'COMPLETED',
    statusLabel: 'Completed & Released',
    autoReleaseCountdown: null,
  },
  {
    id: 'ORD-659124',
    createdAt: '2026-10-22 11:05 UTC',
    game: 'Lineage W',
    gameIcon: '👑',
    platform: 'PC/Mobile',
    server: 'Eva 01',
    title: 'Blessed Armor Enchant Scroll x 10',
    quantity: 10,
    unit: 'Scrolls',
    unitPrice: 14.50,
    totalAmount: 145.00,
    currency: 'USD',
    sellerName: 'AdenBlacksmith',
    sellerRep: 94.2,
    status: 'DISPUTED',
    statusLabel: 'Under Dispute (4-Eyes Review)',
    autoReleaseCountdown: null,
  }
])

const filteredOrders = computed(() => {
  if (activeTab.value === 'all') return orders.value
  if (activeTab.value === 'pending') return orders.value.filter(o => o.status === 'PAYMENT_PENDING')
  if (activeTab.value === 'in_delivery') return orders.value.filter(o => o.status === 'IN_DELIVERY')
  if (activeTab.value === 'awaiting_confirmation') return orders.value.filter(o => o.status === 'DELIVERY_CLAIMED')
  if (activeTab.value === 'completed') return orders.value.filter(o => o.status === 'COMPLETED')
  if (activeTab.value === 'disputed') return orders.value.filter(o => o.status === 'DISPUTED')
  return orders.value
})

function getStatusBadgeClass(status: string) {
  switch (status) {
    case 'DELIVERY_CLAIMED':
      return 'bg-cyan-500/10 text-cyan-300 border-cyan-500/30'
    case 'PAYMENT_PENDING':
      return 'bg-amber-500/10 text-amber-300 border-amber-500/30'
    case 'IN_DELIVERY':
      return 'bg-blue-500/10 text-blue-300 border-blue-500/30'
    case 'COMPLETED':
      return 'bg-emerald-500/10 text-emerald-300 border-emerald-500/30'
    case 'DISPUTED':
      return 'bg-rose-500/10 text-rose-300 border-rose-500/30'
    default:
      return 'bg-gray-500/10 text-gray-300 border-gray-500/30'
  }
}

function confirmReceipt(orderId: string) {
  const target = orders.value.find(o => o.id === orderId)
  if (target) {
    target.status = 'COMPLETED'
    target.statusLabel = 'Completed & Released'
    target.autoReleaseCountdown = null
    alert(`Order ${orderId} has been confirmed. Escrow funds have been successfully released to ${target.sellerName}.`)
  }
}
</script>

