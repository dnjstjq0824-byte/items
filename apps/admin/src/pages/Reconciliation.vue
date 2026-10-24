<template>
  <div class="space-y-6">
    <div class="flex justify-between items-center">
      <div>
        <h2 class="text-xl font-bold text-white">Financial Settlement & Reconciliation Ledger</h2>
        <p class="text-xs text-gray-400">Auditing external PSP settlements against internal double-entry ledger accounts (Article 16.6 & 27.10)</p>
      </div>
      <button class="bg-[#6366F1] hover:bg-[#4F46E5] text-white px-4 py-2 rounded-lg text-xs font-semibold">
        Import PSP Settlement Batch
      </button>
    </div>

    <!-- Settlement Batch Summary -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
      <div class="admin-card p-5">
        <span class="text-xs font-semibold text-gray-400 block mb-1">Batch #BATCH-2026-W42</span>
        <div class="text-xl font-black text-white">$45,200.00</div>
        <span class="text-xs text-emerald-400 mt-1 block">Status: BALANCED & RECONCILED</span>
      </div>

      <div class="admin-card p-5 border-amber-500/30">
        <span class="text-xs font-semibold text-gray-400 block mb-1">Batch #BATCH-2026-W43</span>
        <div class="text-xl font-black text-white">$52,140.00</div>
        <span class="text-xs text-amber-400 mt-1 block">Status: 1 DISCREPANCY FLAGGED</span>
      </div>

      <div class="admin-card p-5">
        <span class="text-xs font-semibold text-gray-400 block mb-1">Ledger Balance Invariant</span>
        <div class="text-xl font-black text-emerald-400">&Delta; = $0.00</div>
        <span class="text-xs text-gray-400 mt-1 block">&Sigma; Debits == &Sigma; Credits (USD & KRW)</span>
      </div>
    </div>

    <!-- Discrepancy Inspection Grid -->
    <div class="admin-card overflow-hidden">
      <div class="p-4 border-b border-[#283247] flex justify-between items-center bg-[#0B1020]">
        <h3 class="font-bold text-sm text-white">Batch #BATCH-2026-W43 Item Line Breakdown</h3>
        <span class="text-xs text-gray-400">Total lines: 48 items</span>
      </div>
      <table class="w-full text-left text-sm">
        <thead class="bg-[#151C2F] border-b border-[#283247] text-xs text-gray-400 uppercase">
          <tr>
            <th class="px-6 py-3">Provider Tx Reference</th>
            <th class="px-6 py-3">Internal Order ID</th>
            <th class="px-6 py-3">Currency</th>
            <th class="px-6 py-3">Reported Amount</th>
            <th class="px-6 py-3">Ledger Amount</th>
            <th class="px-6 py-3">Difference</th>
            <th class="px-6 py-3">Audit Status</th>
          </tr>
        </thead>
        <tbody class="divide-y divide-[#283247] text-gray-300">
          <tr class="hover:bg-[#1a233a] transition">
            <td class="px-6 py-4 font-mono text-xs">ch_3NvK8d2eZvKYlo2C1g</td>
            <td class="px-6 py-4 font-mono text-xs">ORD-1001-a1b2</td>
            <td class="px-6 py-4">USD</td>
            <td class="px-6 py-4 font-medium text-white">$45.00</td>
            <td class="px-6 py-4 font-medium text-white">$45.00</td>
            <td class="px-6 py-4 font-mono text-emerald-400">$0.00</td>
            <td class="px-6 py-4"><span class="px-2 py-0.5 rounded text-xs bg-emerald-500/10 text-emerald-400">MATCHED</span></td>
          </tr>
          <tr class="hover:bg-[#1a233a] transition bg-rose-500/5">
            <td class="px-6 py-4 font-mono text-xs">ch_3NvK8d2eZvKYlo2C2x</td>
            <td class="px-6 py-4 font-mono text-xs">ORD-1002-c3d4</td>
            <td class="px-6 py-4">USD</td>
            <td class="px-6 py-4 font-medium text-white">$50.00</td>
            <td class="px-6 py-4 font-medium text-white">$45.00</td>
            <td class="px-6 py-4 font-mono text-rose-400 font-bold">+$5.00</td>
            <td class="px-6 py-4"><span class="px-2 py-0.5 rounded text-xs bg-rose-500/20 text-rose-400 font-bold">DISCREPANCY</span></td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup lang="ts">
// Reconciliation reactive state
</script>

