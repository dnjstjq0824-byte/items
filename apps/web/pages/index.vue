<template>
  <div>
    <!-- Hero Section -->
    <section class="py-16 px-4 bg-gradient-to-b from-[#151C2F] to-[#0B1020] border-b border-[#283247]">
      <div class="max-w-5xl mx-auto text-center">
        <span class="inline-block py-1 px-3 mb-4 rounded-full text-xs font-semibold bg-[#6366F1]/10 text-[#6366F1] border border-[#6366F1]/30">
          GLOBAL GAME ASSET TRADING PLATFORM
        </span>
        <h1 class="text-4xl md:text-5xl font-extrabold tracking-tight mb-4 text-white">
          Find gaming goods from <span class="text-transparent bg-clip-text bg-gradient-to-r from-[#6366F1] to-[#22D3EE]">verified sellers</span>.
        </h1>
        <p class="text-gray-400 text-lg mb-8 max-w-2xl mx-auto">
          Trade Smarter. Game Further. Transparent fees, evidence-backed deliveries, and policy-governed marketplace safety.
        </p>

        <!-- Game-First Search Selector (Article 1.3 & 9) -->
        <div class="bg-[#151C2F] p-4 rounded-xl border border-[#283247] shadow-2xl flex flex-col md:flex-row gap-3 max-w-3xl mx-auto">
          <select v-model="selectedGame" class="flex-1 bg-[#0B1020] border border-[#283247] rounded-lg px-3 py-2.5 text-sm text-white">
            <option value="ethereal-odyssey">Ethereal Odyssey Online</option>
            <option value="galactic-warzone">Galactic Warzone Arena</option>
            <option value="mythic-realms">Mythic Realms Chronicles</option>
          </select>
          <select v-model="selectedPlatform" class="flex-1 bg-[#0B1020] border border-[#283247] rounded-lg px-3 py-2.5 text-sm text-white">
            <option value="PC">PC Client</option>
            <option value="CONSOLE">Console</option>
            <option value="CROSS_PLATFORM">Cross-Platform</option>
          </select>
          <input
            v-model="searchKeyword"
            type="text"
            placeholder="Item name, voucher, or server..."
            class="flex-2 bg-[#0B1020] border border-[#283247] rounded-lg px-3 py-2.5 text-sm text-white focus:outline-none focus:border-[#6366F1]"
          />
          <button class="bg-[#6366F1] hover:bg-[#4F46E5] text-white px-6 py-2.5 rounded-lg text-sm font-semibold transition">
            Explore
          </button>
        </div>
      </div>
    </section>

    <!-- Popular Verified Games (Article 10) -->
    <section class="py-12 px-4 max-w-7xl mx-auto">
      <div class="flex justify-between items-end mb-6">
        <div>
          <h2 class="text-2xl font-bold text-white">Supported Games & Ecosystems</h2>
          <p class="text-gray-400 text-sm">Policy-audited game environments with verified transferable digital assets</p>
        </div>
        <NuxtLink to="/games" class="text-sm font-medium text-[#6366F1] hover:underline">View All &rarr;</NuxtLink>
      </div>

      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
        <div v-for="game in games" :key="game.slug" class="surface-card p-5 hover:border-[#6366F1] transition group cursor-pointer">
          <div class="flex items-center gap-4 mb-4">
            <div class="w-14 h-14 rounded-lg bg-gradient-to-br from-[#6366F1]/20 to-[#22D3EE]/20 border border-[#283247] flex items-center justify-center font-bold text-xl text-white">
              {{ game.name.charAt(0) }}
            </div>
            <div>
              <h3 class="font-bold text-white text-base group-hover:text-[#22D3EE] transition">{{ game.name }}</h3>
              <p class="text-xs text-gray-400">{{ game.publisher }}</p>
            </div>
          </div>
          <div class="flex gap-2 text-xs">
            <span class="px-2 py-0.5 rounded bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">Compliance Approved</span>
            <span class="px-2 py-0.5 rounded bg-[#0B1020] text-gray-400 border border-[#283247]">{{ game.platforms.join(', ') }}</span>
          </div>
        </div>
      </div>
    </section>

    <!-- Approved Offers & Listings (Article 11 & 12) -->
    <section class="py-12 px-4 max-w-7xl mx-auto">
      <div class="flex justify-between items-end mb-6">
        <div>
          <h2 class="text-2xl font-bold text-white">Verified Listings</h2>
          <p class="text-gray-400 text-sm">Pre-cleared items and codes from authenticated sellers</p>
        </div>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <div v-for="item in listings" :key="item.id" class="surface-card p-5 flex flex-col justify-between hover:border-[#22D3EE] transition">
          <div>
            <div class="flex justify-between items-start mb-2">
              <span class="text-xs font-semibold px-2 py-0.5 rounded bg-[#6366F1]/10 text-[#6366F1] border border-[#6366F1]/30">
                {{ item.productType }}
              </span>
              <span class="text-xs text-gray-400">ETA: {{ item.eta }}m</span>
            </div>
            <h4 class="font-bold text-white text-base mb-1">{{ item.title }}</h4>
            <p class="text-xs text-gray-400 mb-3">{{ item.game }} &bull; {{ item.server }}</p>
          </div>

          <div class="border-t border-[#283247] pt-4 mt-2 flex items-center justify-between">
            <div>
              <span class="text-xs text-gray-400 block">Unit Price</span>
              <span class="text-xl font-extrabold text-white">${{ (item.unitPriceMinor / 100).toFixed(2) }}</span>
            </div>
            <button class="bg-[#6366F1] hover:bg-[#4F46E5] text-white px-4 py-2 rounded-lg text-xs font-bold transition">
              Order Now
            </button>
          </div>
        </div>
      </div>
    </section>

    <!-- Trust & Buyer Protection Guarantees (Article 1.2, 16.1, 17) -->
    <section class="py-16 px-4 bg-[#151C2F] border-t border-[#283247]">
      <div class="max-w-7xl mx-auto">
        <div class="text-center max-w-2xl mx-auto mb-12">
          <h2 class="text-3xl font-bold text-white mb-2">Evidence-Based Trade Protection</h2>
          <p class="text-gray-400 text-sm">Engineered for security without compromising game publishers or regional laws</p>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div class="bg-[#0B1020] p-6 rounded-xl border border-[#283247]">
            <div class="w-10 h-10 rounded-lg bg-[#6366F1]/20 flex items-center justify-center text-[#6366F1] font-bold text-lg mb-4">
              1
            </div>
            <h3 class="text-lg font-bold text-white mb-2">Policy-Gated Catalogs</h3>
            <p class="text-gray-400 text-sm">
              We never list prohibited items or accounts. Every game and country policy is independently validated.
            </p>
          </div>

          <div class="bg-[#0B1020] p-6 rounded-xl border border-[#283247]">
            <div class="w-10 h-10 rounded-lg bg-[#22D3EE]/20 flex items-center justify-center text-[#22D3EE] font-bold text-lg mb-4">
              2
            </div>
            <h3 class="text-lg font-bold text-white mb-2">Verified Delivery Proof</h3>
            <p class="text-gray-400 text-sm">
              Sellers must submit cryptographic SHA256-hashed fulfillment evidence before funds become payout-eligible.
            </p>
          </div>

          <div class="bg-[#0B1020] p-6 rounded-xl border border-[#283247]">
            <div class="w-10 h-10 rounded-lg bg-emerald-500/20 flex items-center justify-center text-emerald-400 font-bold text-lg mb-4">
              3
            </div>
            <h3 class="text-lg font-bold text-white mb-2">Licensed PSP Custody</h3>
            <p class="text-gray-400 text-sm">
              All transactions flow through authorized payment gateways. We never hold unregulated customer funds.
            </p>
          </div>
        </div>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const selectedGame = ref('ethereal-odyssey')
const selectedPlatform = ref('PC')
const searchKeyword = ref('')

const games = ref([
  {
    slug: 'ethereal-odyssey',
    name: 'Ethereal Odyssey Online',
    publisher: 'Aether Interactive Inc.',
    platforms: ['PC', 'Console']
  },
  {
    slug: 'galactic-warzone',
    name: 'Galactic Warzone Arena',
    publisher: 'Nova Prime Games',
    platforms: ['PC']
  },
  {
    slug: 'mythic-realms',
    name: 'Mythic Realms Chronicles',
    publisher: 'Mythic Works Ltd.',
    platforms: ['Cross-Platform']
  }
])

const listings = ref([
  {
    id: '1',
    productType: 'GAME_ITEM',
    title: '+12 Celestial Greatsword (Trade-Permitted)',
    game: 'Ethereal Odyssey',
    server: 'Altair Prime (NA)',
    unitPriceMinor: 4500,
    eta: 15
  },
  {
    id: '2',
    productType: 'OFFICIAL_GIFT_CODE',
    title: '30-Day Adventurer Pass Code (Global/NA)',
    game: 'Ethereal Odyssey',
    server: 'Global Retail Activation',
    unitPriceMinor: 1499,
    eta: 5
  },
  {
    id: '3',
    productType: 'GAME_ITEM',
    title: 'Vanguard Titan Aegis Armor',
    game: 'Galactic Warzone',
    server: 'Sector 7 Alpha',
    unitPriceMinor: 3200,
    eta: 20
  }
])
</script>

