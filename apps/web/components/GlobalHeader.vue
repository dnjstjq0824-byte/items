<template>
  <header class="border-b border-[#283247] bg-[#151C2F]/90 backdrop-blur sticky top-0 z-50">
    <div class="max-w-7xl mx-auto px-4 h-16 flex items-center justify-between gap-4">
      <!-- Brand Logo -->
      <NuxtLink to="/" class="flex items-center gap-2">
        <div class="w-8 h-8 rounded bg-gradient-to-tr from-[#6366F1] to-[#22D3EE] flex items-center justify-center font-black text-black">
          G
        </div>
        <span class="font-extrabold text-lg tracking-wider text-white">BN GAMEEX</span>
      </NuxtLink>

      <!-- Navigation Links -->
      <nav class="hidden md:flex items-center gap-6 text-sm font-medium text-gray-300">
        <NuxtLink to="/games" class="hover:text-white transition">Games</NuxtLink>
        <NuxtLink to="/items" class="hover:text-white transition">Items</NuxtLink>
        <NuxtLink to="/offers" class="hover:text-white transition">Offers</NuxtLink>
        <NuxtLink to="/sellers" class="hover:text-white transition">Sellers</NuxtLink>
        <NuxtLink to="/help" class="hover:text-white transition">Help</NuxtLink>
      </nav>

      <!-- Search Bar -->
      <div class="flex-1 max-w-md hidden sm:block">
        <div class="relative">
          <input
            type="text"
            placeholder="Search games, servers, approved items..."
            class="w-full bg-[#0B1020] border border-[#283247] rounded-lg px-4 py-2 text-sm text-white focus:outline-none focus:border-[#6366F1]"
          />
        </div>
      </div>

      <!-- Action items: Locale & Auth -->
      <div class="flex items-center gap-3">
        <select class="bg-[#0B1020] border border-[#283247] rounded px-2 py-1 text-xs text-gray-300">
          <option value="en">English (USD)</option>
          <option value="ko">한국어 (KRW)</option>
          <option value="ja">日本語 (JPY)</option>
        </select>

        <button class="bg-[#6366F1] hover:bg-[#4F46E5] text-white px-4 py-2 rounded-lg text-xs font-semibold transition">
          Sign In
        </button>
      </div>
    </div>
  </header>
</template>
