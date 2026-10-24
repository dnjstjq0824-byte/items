<template>
  <div class="space-y-6">
    <!-- Financial Transparency Metric Cards (Article 27.2) -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
      <div class="admin-card p-5">
        <span class="text-xs font-semibold text-gray-400 block mb-1">Gross Merchandise Value (GMV)</span>
        <div class="text-2xl font-black text-white">$145,000.00</div>
        <span class="text-[11px] text-gray-500 mt-1 block">Total initiated quotes & orders</span>
      </div>

      <div class="admin-card p-5 border-emerald-500/30">
        <span class="text-xs font-semibold text-emerald-400 block mb-1">Captured Payments (Settled by PSP)</span>
        <div class="text-2xl font-black text-emerald-400">$132,000.00</div>
        <span class="text-[11px] text-gray-500 mt-1 block">Verified external webhook captures</span>
      </div>

      <div class="admin-card p-5 border-[#6366F1]/30">
        <span class="text-xs font-semibold text-[#6366F1] block mb-1">Recognized Platform Fees</span>
        <div class="text-2xl font-black text-[#6366F1]">$6,600.00</div>
        <span class="text-[11px] text-gray-500 mt-1 block">5.0% commission on completed trades</span>
      </div>

      <div class="admin-card p-5 border-amber-500/30">
        <span class="text-xs font-semibold text-amber-400 block mb-1">Pending Seller Payouts</span>
        <div class="text-2xl font-black text-amber-400">$125,400.00</div>
        <span class="text-[11px] text-gray-500 mt-1 block">Held pending protection window</span>
      </div>
    </div>

    <!-- Active Compliance & Operational Queues -->
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
      <div class="admin-card p-6">
        <h3 class="text-base font-bold text-white mb-4">Compliance Policy Gates</h3>
        <div class="space-y-3">
          <div class="flex items-center justify-between p-3 rounded bg-[#0B1020] border border-[#283247]">
            <div>
              <div class="font-bold text-sm text-white">Ethereal Odyssey Online &bull; US</div>
              <div class="text-xs text-gray-400">Game Item Trade</div>
            </div>
            <span class="px-2 py-1 rounded text-xs font-semibold bg-emerald-500/20 text-emerald-400 border border-emerald-500/30">APPROVED</span>
          </div>

          <div class="flex items-center justify-between p-3 rounded bg-[#0B1020] border border-[#283247]">
            <div>
              <div class="font-bold text-sm text-white">Ethereal Odyssey Online &bull; KR</div>
              <div class="text-xs text-gray-400">Game Currency (Gated per Article 3.3)</div>
            </div>
            <span class="px-2 py-1 rounded text-xs font-semibold bg-amber-500/20 text-amber-300 border border-amber-500/30">REVIEW_REQUIRED</span>
          </div>

          <div class="flex items-center justify-between p-3 rounded bg-[#0B1020] border border-[#283247]">
            <div>
              <div class="font-bold text-sm text-white">All Games &bull; Global</div>
              <div class="text-xs text-gray-400">Game Accounts (Strictly Banned Article 3.4)</div>
            </div>
            <span class="px-2 py-1 rounded text-xs font-semibold bg-rose-500/20 text-rose-400 border border-rose-500/30">PROHIBITED</span>
          </div>
        </div>
      </div>

      <div class="admin-card p-6">
        <h3 class="text-base font-bold text-white mb-4">Operational Dispute Queue</h3>
        <div class="space-y-3">
          <div class="p-3 rounded bg-[#0B1020] border border-[#283247] flex justify-between items-center">
            <div>
              <div class="font-bold text-sm text-white">Dispute #DSP-9042</div>
              <div class="text-xs text-gray-400">Reason: NOT_AS_DESCRIBED &bull; Order ORD-1002</div>
            </div>
            <span class="px-2 py-1 rounded text-xs font-semibold bg-amber-500/20 text-amber-300 border border-amber-500/30">UNDER_REVIEW</span>
          </div>
          <div class="p-3 rounded bg-[#0B1020] border border-[#283247] flex justify-between items-center">
            <div>
              <div class="font-bold text-sm text-white">Dispute #DSP-9045</div>
              <div class="text-xs text-gray-400">Reason: NON_DELIVERY &bull; Order ORD-1019</div>
            </div>
            <span class="px-2 py-1 rounded text-xs font-semibold bg-rose-500/20 text-rose-400 border border-rose-500/30">EVIDENCE_REQUIRED</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// Dashboard reactive state
</script>

