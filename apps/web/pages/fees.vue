<template>
  <div class="max-w-5xl mx-auto px-4 py-12">
    <!-- Header -->
    <div class="text-center max-w-2xl mx-auto mb-12">
      <span class="px-3 py-1 rounded-full bg-emerald-500/10 text-emerald-400 border border-emerald-500/30 text-xs font-semibold tracking-wide uppercase">
        Zero Hidden Markups
      </span>
      <h1 class="text-3xl sm:text-4xl font-extrabold text-white tracking-tight mt-4">
        Transparent Fee Architecture
      </h1>
      <p class="text-sm text-gray-400 mt-3 leading-relaxed">
        BN GAMEEX operates on a pure zero-custody, clear-ledger model. Buyers pay 0% platform trading fees, and sellers pay the lowest commission in the global industry.
      </p>
    </div>

    <!-- Core Fee Comparison Grid -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-12">
      <div class="bg-[#151C2F] border border-[#283247] rounded-2xl p-6 flex flex-col justify-between">
        <div>
          <div class="text-xs font-semibold text-gray-400 uppercase tracking-wider">Buyer Trading Fee</div>
          <div class="text-4xl font-extrabold text-emerald-400 font-mono mt-3">0.0%</div>
          <p class="text-xs text-gray-400 mt-2 leading-relaxed">
            Buyers never pay any surcharge, registration fee, or platform commission. What you see on the listing is exactly what you pay.
          </p>
        </div>
        <div class="mt-6 pt-4 border-t border-[#283247] text-[11px] text-emerald-400/90 font-medium">
          ✓ Full Escrow Protection Included Free
        </div>
      </div>

      <div class="bg-[#151C2F] border-2 border-[#6366F1] rounded-2xl p-6 flex flex-col justify-between relative shadow-xl shadow-indigo-950/40">
        <div class="absolute -top-3 right-4 px-2.5 py-0.5 rounded-full bg-[#6366F1] text-white text-[10px] font-bold tracking-wider uppercase">
          Industry Best
        </div>
        <div>
          <div class="text-xs font-semibold text-indigo-300 uppercase tracking-wider">Seller Commission</div>
          <div class="text-4xl font-extrabold text-white font-mono mt-3">5.0%</div>
          <p class="text-xs text-gray-400 mt-2 leading-relaxed">
            Deducted strictly upon successful buyer confirmation or expired auto-release. If an order is cancelled or refunded, commission is $0.00.
          </p>
        </div>
        <div class="mt-6 pt-4 border-t border-[#283247] text-[11px] text-indigo-300 font-medium">
          ✓ Volume Discounts down to 2.5% for Pro Tier
        </div>
      </div>

      <div class="bg-[#151C2F] border border-[#283247] rounded-2xl p-6 flex flex-col justify-between">
        <div>
          <div class="text-xs font-semibold text-gray-400 uppercase tracking-wider">External Rail Costs</div>
          <div class="text-4xl font-extrabold text-white font-mono mt-3">Pass-through</div>
          <p class="text-xs text-gray-400 mt-2 leading-relaxed">
            Direct card interchange and local payout rails (ACH, SEPA, PromptPay, KakaoPay) are passed through at net cost with no platform margin.
          </p>
        </div>
        <div class="mt-6 pt-4 border-t border-[#283247] text-[11px] text-gray-400 font-medium">
          ✓ Verified Zero-Custody Architecture
        </div>
      </div>
    </div>

    <!-- Interactive Fee Calculator -->
    <div class="bg-[#151C2F] border border-[#283247] rounded-2xl p-8 mb-12">
      <h2 class="text-lg font-bold text-white mb-2">Interactive Fee Calculator</h2>
      <p class="text-xs text-gray-400 mb-6">Simulate trading proceeds, platform deductions, and net seller payout in real time.</p>

      <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 items-center">
        <!-- Input controls -->
        <div class="space-y-4">
          <div>
            <label class="block text-xs font-semibold text-gray-300 mb-1">Transaction Price</label>
            <div class="relative">
              <span class="absolute left-3 top-2.5 text-gray-400 font-mono text-sm">$</span>
              <input
                v-model.number="calcAmount"
                type="number"
                min="1"
                step="1"
                class="w-full bg-[#0B1020] border border-[#283247] rounded-lg pl-8 pr-4 py-2.5 text-base font-mono text-white focus:outline-none focus:border-[#6366F1]"
              />
            </div>
          </div>

          <div>
            <label class="block text-xs font-semibold text-gray-300 mb-1">Seller KYC Tier</label>
            <select v-model="sellerTier" class="w-full bg-[#0B1020] border border-[#283247] rounded-lg px-3 py-2.5 text-xs text-white">
              <option value="standard">Standard Individual Seller (5.0%)</option>
              <option value="business">Verified Merchant Tier 2 (4.0%)</option>
              <option value="pro">Enterprise Pro Seller Tier 3 (3.0%)</option>
            </select>
          </div>
        </div>

        <!-- Ledger Result breakdown -->
        <div class="bg-[#0B1020] border border-[#283247] rounded-xl p-5 font-mono text-xs space-y-3">
          <div class="flex justify-between text-gray-300">
            <span class="font-sans">Buyer Pays:</span>
            <span class="font-bold text-white">${{ calcAmount.toFixed(2) }} USD</span>
          </div>

          <div class="flex justify-between text-gray-400">
            <span class="font-sans">Buyer Trading Fee (0%):</span>
            <span class="text-emerald-400">$0.00</span>
          </div>

          <div class="flex justify-between text-gray-400">
            <span class="font-sans">BN Platform Fee ({{ feePercent }}%):</span>
            <span class="text-rose-400">-${{ platformFee.toFixed(2) }}</span>
          </div>

          <div class="flex justify-between text-gray-400">
            <span class="font-sans">PSP Pass-through Rail Cost (~1.5%):</span>
            <span class="text-gray-400">-${{ pspFee.toFixed(2) }}</span>
          </div>

          <div class="pt-3 border-t border-[#283247] flex justify-between text-sm">
            <span class="font-sans font-bold text-white">Net Seller Payout:</span>
            <span class="font-bold text-emerald-400 text-base">${{ netPayout.toFixed(2) }} USD</span>
          </div>
        </div>
      </div>
    </div>

    <!-- Benchmark vs Competitors (Article 2) -->
    <div class="bg-[#151C2F] border border-[#283247] rounded-2xl p-8">
      <h2 class="text-lg font-bold text-white mb-2">Marketplace Comparison (Article 2 Benchmarks)</h2>
      <p class="text-xs text-gray-400 mb-6">Compare BN GAMEEX commission rates against global and domestic peer platforms.</p>

      <div class="overflow-x-auto">
        <table class="w-full text-left text-xs">
          <thead class="bg-[#0B1020] text-gray-400 uppercase tracking-wider font-semibold">
            <tr>
              <th class="p-3">Platform</th>
              <th class="p-3">Buyer Fee</th>
              <th class="p-3">Seller Fee</th>
              <th class="p-3">Account Trading Policy</th>
              <th class="p-3">Double-Entry Ledger</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-[#283247] text-gray-300">
            <tr class="bg-[#6366F1]/10 font-semibold text-white">
              <td class="p-3 flex items-center gap-2">
                <span class="w-2 h-2 rounded-full bg-emerald-400"></span>
                BN GAMEEX
              </td>
              <td class="p-3 text-emerald-400">0%</td>
              <td class="p-3 text-emerald-400">3.0% ~ 5.0%</td>
              <td class="p-3 text-amber-300">Strictly Prohibited (Article 3.4)</td>
              <td class="p-3 text-emerald-400">Strict Double-Entry</td>
            </tr>
            <tr>
              <td class="p-3 text-gray-400">PlayerAuctions</td>
              <td class="p-3">0% ~ 3.99%</td>
              <td class="p-3">10.0% ~ 14.99%</td>
              <td class="p-3 text-rose-400">Permitted (High chargeback risk)</td>
              <td class="p-3 text-gray-500">Proprietary Wallet</td>
            </tr>
            <tr>
              <td class="p-3 text-gray-400">G2G Marketplace</td>
              <td class="p-3">0%</td>
              <td class="p-3">8.99% ~ 12.99%</td>
              <td class="p-3 text-rose-400">Permitted (High reclamation risk)</td>
              <td class="p-3 text-gray-500">Closed Loop Balances</td>
            </tr>
            <tr>
              <td class="p-3 text-gray-400">Eldorado.gg</td>
              <td class="p-3">0%</td>
              <td class="p-3">5.0% ~ 10.0%</td>
              <td class="p-3 text-rose-400">Permitted</td>
              <td class="p-3 text-gray-500">Proprietary Wallet</td>
            </tr>
            <tr>
              <td class="p-3 text-gray-400">ItemMania / ItemBay</td>
              <td class="p-3">0%</td>
              <td class="p-3">5.0% (Max 47,000 KRW)</td>
              <td class="p-3 text-rose-400">Account trades allowed under pledge</td>
              <td class="p-3 text-gray-500">Mileage System</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

const calcAmount = ref(100)
const sellerTier = ref('standard')

const feePercent = computed(() => {
  if (sellerTier.value === 'pro') return 3.0
  if (sellerTier.value === 'business') return 4.0
  return 5.0
})

const platformFee = computed(() => {
  return (calcAmount.value * feePercent.value) / 100
})

const pspFee = computed(() => {
  return (calcAmount.value * 0.015)
})

const netPayout = computed(() => {
  const net = calcAmount.value - platformFee.value - pspFee.value
  return Math.max(0, net)
})
</script>

