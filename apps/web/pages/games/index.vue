<template>
  <div class="max-w-7xl mx-auto px-4 py-8">
    <!-- Header -->
    <div class="mb-8">
      <h1 class="text-3xl font-extrabold text-white mb-2">Supported Game Ecosystems</h1>
      <p class="text-gray-400 text-sm">
        Explore compliant, policy-cleared games with verified digital goods and active server trading windows.
      </p>
    </div>

    <!-- Filter & Search Bar -->
    <div class="surface-card p-4 mb-8 flex flex-col md:flex-row gap-4 justify-between items-center">
      <div class="flex-1 w-full md:w-auto relative">
        <input
          v-model="searchQuery"
          type="text"
          placeholder="Filter by game name or publisher..."
          class="w-full bg-[#0B1020] border border-[#283247] rounded-lg px-4 py-2 text-sm text-white focus:outline-none focus:border-[#6366F1]"
        />
      </div>

      <div class="flex gap-2 w-full md:w-auto flex-wrap">
        <button
          v-for="platform in platforms"
          :key="platform"
          @click="selectedPlatform = platform"
          :class="selectedPlatform === platform ? 'bg-[#6366F1] text-white' : 'bg-[#0B1020] text-gray-400 border border-[#283247] hover:text-white'"
          class="px-3 py-1.5 rounded-lg text-xs font-semibold transition"
        >
          {{ platform }}
        </button>
      </div>
    </div>

    <!-- Games Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
      <NuxtLink
        v-for="game in filteredGames"
        :key="game.slug"
        :to="`/games/${game.slug}`"
        class="surface-card p-6 hover:border-[#6366F1] transition group flex flex-col justify-between"
      >
        <div>
          <div class="flex items-center gap-4 mb-4">
            <div class="w-16 h-16 rounded-xl bg-gradient-to-br from-[#6366F1]/20 to-[#22D3EE]/20 border border-[#283247] flex items-center justify-center font-black text-2xl text-white group-hover:scale-105 transition">
              {{ game.name.charAt(0) }}
            </div>
            <div>
              <h2 class="text-lg font-bold text-white group-hover:text-[#22D3EE] transition">{{ game.name }}</h2>
              <p class="text-xs text-gray-400">{{ game.publisher }}</p>
              <span class="inline-block mt-1 text-[11px] font-mono text-gray-500">{{ game.serversCount }} Active Servers</span>
            </div>
          </div>

          <p class="text-xs text-gray-400 line-clamp-2 mb-4 leading-relaxed">
            {{ game.description }}
          </p>
        </div>

        <div class="border-t border-[#283247] pt-4 mt-2 flex items-center justify-between">
          <div class="flex gap-1.5">
            <span
              v-for="pt in game.allowedProductTypes"
              :key="pt"
              class="text-[10px] font-mono px-2 py-0.5 rounded bg-[#0B1020] border border-[#283247] text-gray-300"
            >
              {{ pt }}
            </span>
          </div>
          <span class="text-xs font-bold text-[#6366F1] group-hover:translate-x-1 transition flex items-center gap-1">
            Browse &rarr;
          </span>
        </div>
      </NuxtLink>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

const searchQuery = ref('')
const selectedPlatform = ref('ALL')
const platforms = ['ALL', 'PC', 'CONSOLE', 'CROSS_PLATFORM']

const games = [
  {
    slug: 'ethereal-odyssey',
    name: 'Ethereal Odyssey Online',
    publisher: 'Aether Interactive Inc.',
    description: 'Fantasy MMORPG featuring high-tier craftable weapons, celestial gear, and official monthly adventurer passes.',
    platforms: ['PC', 'CONSOLE'],
    serversCount: 8,
    allowedProductTypes: ['GAME_ITEM', 'OFFICIAL_GIFT_CODE'],
  },
  {
    slug: 'galactic-warzone',
    name: 'Galactic Warzone Arena',
    publisher: 'Nova Prime Games',
    description: 'Sci-fi tactical shooter with player station trading kiosks, orbital armor sets, and verified weapon skins.',
    platforms: ['PC'],
    serversCount: 12,
    allowedProductTypes: ['GAME_ITEM'],
  },
  {
    slug: 'mythic-realms',
    name: 'Mythic Realms Chronicles',
    publisher: 'Mythic Works Ltd.',
    description: 'Cross-platform action RPG with guild entitlements, artifact blueprints, and authorized expansion keys.',
    platforms: ['CROSS_PLATFORM'],
    serversCount: 16,
    allowedProductTypes: ['TRANSFERABLE_ENTITLEMENT', 'OFFICIAL_GIFT_CODE'],
  },
]

const filteredGames = computed(() => {
  return games.filter(g => {
    const matchesSearch = g.name.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
                          g.publisher.toLowerCase().includes(searchQuery.value.toLowerCase())
    const matchesPlatform = selectedPlatform.value === 'ALL' || g.platforms.includes(selectedPlatform.value)
    return matchesSearch && matchesPlatform
  })
})
</script>

