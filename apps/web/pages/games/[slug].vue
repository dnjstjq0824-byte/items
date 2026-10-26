<template>
  <div class="max-w-7xl mx-auto px-4 py-8">
    <!-- Breadcrumb -->
    <nav class="flex items-center gap-2 text-xs text-gray-400 mb-6">
      <NuxtLink to="/" class="hover:text-white transition">Home</NuxtLink>
      <span>/</span>
      <NuxtLink to="/games" class="hover:text-white transition">Games</NuxtLink>
      <span>/</span>
      <span class="text-white font-semibold">{{ game.name }}</span>
    </nav>

    <!-- Game Banner Card -->
    <div class="surface-card p-6 md:p-8 mb-8 relative overflow-hidden">
      <div class="flex flex-col md:flex-row md:items-center justify-between gap-6 relative z-10">
        <div class="flex items-center gap-5">
          <div class="w-20 h-20 rounded-2xl bg-gradient-to-tr from-[#6366F1] to-[#22D3EE] flex items-center justify-center font-black text-3xl text-white shadow-xl">
            {{ game.name.charAt(0) }}
          </div>
          <div>
            <div class="flex items-center gap-3 flex-wrap">
              <h1 class="text-2xl md:text-3xl font-extrabold text-white">{{ game.name }}</h1>
              <span class="px-2.5 py-0.5 rounded-full text-xs font-semibold bg-emerald-500/10 text-emerald-400 border border-emerald-500/30">
                Policy Pre-Cleared
              </span>
            </div>
            <p class="text-sm text-gray-400 mt-1">{{ game.publisher }} &bull; In-Game Transfer Window Supported</p>
          </div>
        </div>

        <!-- Quick Compliance Info -->
        <div class="flex gap-4 text-xs bg-[#0B1020]/60 p-3 rounded-xl border border-[#283247]">
          <div>
            <span class="text-gray-500 block">Account Trading</span>
            <strong class="text-rose-400">Strictly Prohibited</strong>
          </div>
          <div class="border-l border-[#283247] pl-4">
            <span class="text-gray-500 block">Currency Review</span>
            <strong class="text-amber-400">Gated (TOS Check)</strong>
          </div>
          <div class="border-l border-[#283247] pl-4">
            <span class="text-gray-500 block">Item Trading</span>
            <strong class="text-emerald-400">Permitted</strong>
          </div>
        </div>
      </div>
    </div>

    <!-- Filter Bar: Servers & Product Types -->
    <div class="surface-card p-4 mb-6 flex flex-col md:flex-row gap-4 items-center justify-between">
      <!-- Product Type Tabs -->
      <div class="flex gap-2 w-full md:w-auto">
        <button
          v-for="pt in productTypes"
          :key="pt"
          @click="selectedProductType = pt"
          :class="selectedProductType === pt ? 'bg-[#6366F1] text-white' : 'bg-[#0B1020] text-gray-400 border border-[#283247] hover:text-white'"
          class="px-3.5 py-2 rounded-lg text-xs font-semibold transition"
        >
          {{ pt }}
        </button>
      </div>

      <!-- Server Selector -->
      <div class="flex gap-3 w-full md:w-auto items-center">
        <span class="text-xs text-gray-400 whitespace-nowrap">Server:</span>
        <select v-model="selectedServer" class="bg-[#0B1020] border border-[#283247] rounded-lg px-3 py-2 text-xs text-white">
          <option value="ALL">All Servers</option>
          <option v-for="s in servers" :key="s" :value="s">{{ s }}</option>
        </select>

        <select v-model="sortBy" class="bg-[#0B1020] border border-[#283247] rounded-lg px-3 py-2 text-xs text-white">
          <option value="price_asc">Price: Low to High</option>
          <option value="price_desc">Price: High to Low</option>
          <option value="eta">Fastest Delivery</option>
          <option value="rating">Top Rated Sellers</option>
        </select>
      </div>
    </div>

    <!-- Listings Table -->
    <div class="surface-card overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full text-left text-sm">
          <thead class="bg-[#0B1020] border-b border-[#283247] text-xs text-gray-400 uppercase tracking-wider">
            <tr>
              <th class="px-6 py-3.5">Listing Details</th>
              <th class="px-6 py-3.5">Server</th>
              <th class="px-6 py-3.5">Seller Trust</th>
              <th class="px-6 py-3.5">Stock</th>
              <th class="px-6 py-3.5">ETA</th>
              <th class="px-6 py-3.5">Unit Price</th>
              <th class="px-6 py-3.5 text-right">Action</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-[#283247] text-gray-300">
            <tr v-for="item in filteredListings" :key="item.id" class="hover:bg-[#1a233a]/60 transition">
              <td class="px-6 py-4">
                <NuxtLink :to="`/listings/${item.id}`" class="font-bold text-white hover:text-[#22D3EE] transition block">
                  {{ item.title }}
                </NuxtLink>
                <span class="text-[11px] text-gray-400 line-clamp-1 mt-0.5">{{ item.description }}</span>
              </td>
              <td class="px-6 py-4 text-xs font-mono">{{ item.server }}</td>
              <td class="px-6 py-4">
                <div class="flex items-center gap-1.5">
                  <span class="font-semibold text-white text-xs">{{ item.sellerName }}</span>
                  <span v-if="item.isVerified" class="text-xs text-[#22D3EE]" title="Verified Seller">&#10003;</span>
                </div>
                <div class="text-[10px] text-gray-400 mt-0.5">Rating {{ item.sellerRating }} ({{ item.completedOrders }} orders)</div>
              </td>
              <td class="px-6 py-4 text-xs">
                <span :class="item.stock > 0 ? 'text-white' : 'text-rose-400 font-bold'">
                  {{ item.stock > 0 ? `${item.stock} available` : 'Sold Out' }}
                </span>
              </td>
              <td class="px-6 py-4 text-xs font-mono text-gray-400">{{ item.eta }} mins</td>
              <td class="px-6 py-4">
                <span class="text-base font-extrabold text-white">${{ (item.unitPriceMinor / 100).toFixed(2) }}</span>
                <span class="text-[10px] text-gray-400 block">USD</span>
              </td>
              <td class="px-6 py-4 text-right">
                <NuxtLink
                  :to="`/listings/${item.id}`"
                  class="bg-[#6366F1] hover:bg-[#4F46E5] text-white px-3.5 py-1.5 rounded-lg text-xs font-semibold transition inline-block"
                >
                  Buy
                </NuxtLink>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

const game = {
  slug: 'ethereal-odyssey',
  name: 'Ethereal Odyssey Online',
  publisher: 'Aether Interactive Inc.',
}

const productTypes = ['ALL', 'GAME_ITEM', 'OFFICIAL_GIFT_CODE']
const selectedProductType = ref('ALL')
const selectedServer = ref('ALL')
const sortBy = ref('price_asc')

const servers = ['Altair Prime (NA)', 'Vega Vanguard (EU)', 'Sirius Horizon (ASIA)', 'Global Retail Key']

const listings = [
  {
    id: '80000000-0000-0000-0000-000000000001',
    title: '+12 Celestial Greatsword (Trade-Permitted)',
    description: 'Verified transferable in-game weapon on Altair Prime. Full evidence recorded upon in-game trade window.',
    productType: 'GAME_ITEM',
    server: 'Altair Prime (NA)',
    sellerName: 'AetherTraderPro',
    sellerRating: '4.92',
    completedOrders: 142,
    isVerified: true,
    stock: 3,
    eta: 15,
    unitPriceMinor: 4500,
  },
  {
    id: '80000000-0000-0000-0000-000000000002',
    title: 'Official 30-Day Adventurer Pass Code (Global/NA)',
    description: 'Authorized retail digital activation key. Delivered instantly with digital receipt verification.',
    productType: 'OFFICIAL_GIFT_CODE',
    server: 'Global Retail Key',
    sellerName: 'AetherTraderPro',
    sellerRating: '4.92',
    completedOrders: 142,
    isVerified: true,
    stock: 15,
    eta: 5,
    unitPriceMinor: 1499,
  },
  {
    id: '80000000-0000-0000-0000-000000000003',
    title: 'Astral Wings of the Phoenix (Transmute)',
    description: 'Cosmetic back piece transmute token. Eligible for direct player transfer on Vega Vanguard.',
    productType: 'GAME_ITEM',
    server: 'Vega Vanguard (EU)',
    sellerName: 'StarForgeTrades',
    sellerRating: '4.88',
    completedOrders: 89,
    isVerified: true,
    stock: 1,
    eta: 20,
    unitPriceMinor: 2800,
  },
]

const filteredListings = computed(() => {
  return listings.filter(l => {
    const matchType = selectedProductType.value === 'ALL' || l.productType === selectedProductType.value
    const matchServer = selectedServer.value === 'ALL' || l.server === selectedServer.value
    return matchType && matchServer
  }).sort((a, b) => {
    if (sortBy.value === 'price_asc') return a.unitPriceMinor - b.unitPriceMinor
    if (sortBy.value === 'price_desc') return b.unitPriceMinor - a.unitPriceMinor
    if (sortBy.value === 'eta') return a.eta - b.eta
    return Number(b.sellerRating) - Number(a.sellerRating)
  })
})
</script>

