<template>
  <div class="min-h-screen flex flex-col bg-[#0B1020] text-[#F8FAFC]">
    <GlobalHeader />
    <main class="flex-1">
      <NuxtPage />
    </main>
    <footer class="border-t border-[#283247] py-8 bg-[#151C2F] text-center text-sm text-gray-400">
      <div class="max-w-7xl mx-auto px-4 flex flex-col md:flex-row justify-between items-center gap-4">
        <div>
          <span class="font-bold text-white tracking-wider">BN GAMEEX</span> &copy; 2026 Booking Network Co., Ltd. All rights reserved.
        </div>
        <div class="flex gap-6 text-xs">
          <a href="#" class="hover:text-white transition">Trade Protection Policy</a>
          <a href="#" class="hover:text-white transition">Legal & Compliance</a>
          <a href="#" class="hover:text-white transition">Fee Structure</a>
          <a href="#" class="hover:text-white transition">Terms & Privacy</a>
        </div>
      </div>
    </footer>
  </div>
</template>

<script setup lang="ts">
import GlobalHeader from '~/components/GlobalHeader.vue'
</script>
