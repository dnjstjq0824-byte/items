<template>
  <div class="space-y-6">
    <div class="flex justify-between items-center">
      <div>
        <h2 class="text-xl font-bold text-white">Global Trade Policy Registry</h2>
        <p class="text-xs text-gray-400">Strict multi-gate compliance: Country &times; Game &times; Product Type &times; PSP Status</p>
      </div>
      <button class="bg-[#6366F1] hover:bg-[#4F46E5] text-white px-4 py-2 rounded-lg text-xs font-semibold">
        + Add Policy Matrix Entry
      </button>
    </div>

    <div class="admin-card overflow-hidden">
      <table class="w-full text-left text-sm">
        <thead class="bg-[#0B1020] border-b border-[#283247] text-xs text-gray-400 uppercase">
          <tr>
            <th class="px-6 py-3">Game</th>
            <th class="px-6 py-3">Country</th>
            <th class="px-6 py-3">Product Type</th>
            <th class="px-6 py-3">Legal Review</th>
            <th class="px-6 py-3">Publisher Stance</th>
            <th class="px-6 py-3">Trade Enabled</th>
            <th class="px-6 py-3 text-right">Actions</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-[#283247] text-gray-300">
          <tr v-for="p in policies" :key="p.id" class="hover:bg-[#1a233a] transition">
            <td class="px-6 py-4 font-medium text-white">{{ p.game }}</td>
            <td class="px-6 py-4 font-mono font-semibold">{{ p.country }}</td>
            <td class="px-6 py-4">
              <span class="px-2 py-0.5 rounded text-xs bg-[#0B1020] border border-[#283247]">{{ p.productType }}</span>
            </td>
            <td class="px-6 py-4">
              <span :class="p.legalStatus === 'APPROVED' ? 'text-emerald-400' : 'text-amber-400'">{{ p.legalStatus }}</span>
            </td>
            <td class="px-6 py-4">{{ p.publisherStance }}</td>
            <td class="px-6 py-4">
              <span :class="p.enabled ? 'px-2 py-0.5 rounded text-xs bg-emerald-500/10 text-emerald-400 border border-emerald-500/20' : 'px-2 py-0.5 rounded text-xs bg-rose-500/10 text-rose-400 border border-rose-500/20'">
                {{ p.enabled ? 'ACTIVE' : 'BLOCKED' }}
              </span>
            </td>
            <td class="px-6 py-4 text-right">
              <button class="text-xs text-[#6366F1] hover:underline font-semibold">Review</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const policies = ref([
  {
    id: '1',
    game: 'Ethereal Odyssey Online',
    country: 'US',
    productType: 'GAME_ITEM',
    legalStatus: 'APPROVED',
    publisherStance: 'PERMITTED',
    enabled: true
  },
  {
    id: '2',
    game: 'Ethereal Odyssey Online',
    country: 'KR',
    productType: 'GAME_ITEM',
    legalStatus: 'APPROVED',
    publisherStance: 'PERMITTED',
    enabled: true
  },
  {
    id: '3',
    game: 'Ethereal Odyssey Online',
    country: 'KR',
    productType: 'GAME_CURRENCY',
    legalStatus: 'REVIEW_REQUIRED',
    publisherStance: 'REVIEW_REQUIRED',
    enabled: false
  },
  {
    id: '4',
    game: 'All Games',
    country: 'ALL',
    productType: 'GAME_ACCOUNT',
    legalStatus: 'PROHIBITED',
    publisherStance: 'PROHIBITED',
    enabled: false
  }
])
</script>

