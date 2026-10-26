<template>
  <div class="space-y-6">
    <!-- Header with Stats -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
      <div>
        <h2 class="text-xl font-bold text-white tracking-tight">Seller Management & KYC Verification</h2>
        <p class="text-xs text-gray-400 mt-1">Review merchant eligibility, identity verification tiers, and seller risk reputation scores.</p>
      </div>
      <div class="flex items-center gap-3">
        <input
          v-model="searchQuery"
          type="text"
          placeholder="Search seller by name or UUID..."
          class="bg-[#0B1020] border border-[#283247] rounded-lg px-3 py-1.5 text-xs text-white focus:outline-none focus:border-[#6366F1]"
        />
        <select v-model="tierFilter" class="bg-[#0B1020] border border-[#283247] rounded-lg px-3 py-1.5 text-xs text-gray-300">
          <option value="ALL">All Tiers</option>
          <option value="PRO">Enterprise Pro</option>
          <option value="BUSINESS">Verified Merchant</option>
          <option value="STANDARD">Standard</option>
        </select>
      </div>
    </div>

    <!-- Quick Metrics -->
    <div class="grid grid-cols-1 sm:grid-cols-4 gap-4">
      <div class="bg-[#151C2F] border border-[#283247] p-4 rounded-xl">
        <div class="text-xs text-gray-400 font-medium">Active Sellers</div>
        <div class="text-xl font-bold text-white font-mono mt-1">1,482</div>
        <div class="text-[10px] text-emerald-400 mt-1">98.2% in good standing</div>
      </div>
      <div class="bg-[#151C2F] border border-[#283247] p-4 rounded-xl">
        <div class="text-xs text-gray-400 font-medium">Pending KYC Verifications</div>
        <div class="text-xl font-bold text-amber-300 font-mono mt-1">14</div>
        <div class="text-[10px] text-amber-400 mt-1">Requires manual document review</div>
      </div>
      <div class="bg-[#151C2F] border border-[#283247] p-4 rounded-xl">
        <div class="text-xs text-gray-400 font-medium">Suspended / High Risk</div>
        <div class="text-xl font-bold text-rose-400 font-mono mt-1">3</div>
        <div class="text-[10px] text-rose-400 mt-1">Velocity/Dispute triggered</div>
      </div>
      <div class="bg-[#151C2F] border border-[#283247] p-4 rounded-xl">
        <div class="text-xs text-gray-400 font-medium">Monthly Merchant GMV</div>
        <div class="text-xl font-bold text-emerald-400 font-mono mt-1">$489,200</div>
        <div class="text-[10px] text-gray-400 mt-1">USD settled via Stripe</div>
      </div>
    </div>

    <!-- Sellers Data Table -->
    <div class="bg-[#151C2F] border border-[#283247] rounded-xl overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full text-left text-xs">
          <thead class="bg-[#0B1020] border-b border-[#283247] text-gray-400 uppercase tracking-wider font-semibold">
            <tr>
              <th class="p-4">Seller</th>
              <th class="p-4">Tier</th>
              <th class="p-4">KYC Status</th>
              <th class="p-4">Reputation</th>
              <th class="p-4">Trades</th>
              <th class="p-4">Lifetime GMV</th>
              <th class="p-4">Risk Score</th>
              <th class="p-4">Account State</th>
              <th class="p-4 text-right">Actions</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-[#283247] text-gray-300">
            <tr v-for="seller in filteredSellers" :key="seller.id" class="hover:bg-[#1A233A]/50 transition">
              <td class="p-4">
                <div class="font-bold text-white">{{ seller.displayName }}</div>
                <div class="text-[10px] text-gray-500 font-mono">{{ seller.id }}</div>
              </td>
              <td class="p-4">
                <span class="px-2 py-0.5 rounded text-[10px] font-bold border" :class="getTierBadgeClass(seller.tier)">
                  {{ seller.tier }}
                </span>
              </td>
              <td class="p-4">
                <span class="px-2 py-0.5 rounded text-[10px] font-semibold border" :class="getKycBadgeClass(seller.kycStatus)">
                  {{ seller.kycStatus }}
                </span>
              </td>
              <td class="p-4 font-mono font-bold text-emerald-400">
                {{ seller.reputationScore }}%
              </td>
              <td class="p-4 font-mono">
                {{ seller.totalOrders.toLocaleString() }}
              </td>
              <td class="p-4 font-mono font-bold text-white">
                ${{ seller.lifetimeVolume.toLocaleString() }}
              </td>
              <td class="p-4">
                <span class="font-mono font-bold" :class="seller.riskScore > 50 ? 'text-rose-400' : 'text-emerald-400'">
                  {{ seller.riskScore }}/100
                </span>
              </td>
              <td class="p-4">
                <span class="px-2 py-0.5 rounded text-[10px] font-semibold" :class="seller.status === 'ACTIVE' ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/30' : 'bg-rose-500/10 text-rose-400 border border-rose-500/30'">
                  {{ seller.status }}
                </span>
              </td>
              <td class="p-4 text-right space-x-2">
                <button @click="openSellerDetails(seller)" class="px-2.5 py-1 rounded bg-[#283247] hover:bg-[#374463] text-white text-[11px] font-medium transition">
                  Audit
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Seller Audit Modal -->
    <div v-if="selectedSeller" class="fixed inset-0 bg-black/70 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <div class="bg-[#151C2F] border border-[#283247] rounded-2xl max-w-xl w-full p-6 space-y-5">
        <div class="flex items-center justify-between border-b border-[#283247] pb-4">
          <div>
            <h3 class="text-base font-bold text-white">{{ selectedSeller.displayName }}</h3>
            <div class="text-[11px] font-mono text-gray-400">UUID: {{ selectedSeller.id }}</div>
          </div>
          <button @click="selectedSeller = null" class="text-gray-400 hover:text-white">✕</button>
        </div>

        <div class="grid grid-cols-2 gap-4 text-xs">
          <div class="bg-[#0B1020] p-3 rounded-lg border border-[#283247]">
            <div class="text-gray-400">Merchant Business Entity</div>
            <div class="text-white font-semibold mt-0.5">{{ selectedSeller.businessName || 'Individual Person' }}</div>
          </div>
          <div class="bg-[#0B1020] p-3 rounded-lg border border-[#283247]">
            <div class="text-gray-400">External Payout Destination</div>
            <div class="text-emerald-400 font-mono mt-0.5">{{ selectedSeller.payoutRail }}</div>
          </div>
        </div>

        <div class="bg-[#0B1020] p-3 rounded-lg border border-[#283247] text-xs space-y-2">
          <div class="font-semibold text-white">KYC Document Hash Verification:</div>
          <div class="text-[11px] font-mono text-indigo-300 break-all">{{ selectedSeller.kycDocHash }}</div>
          <div class="text-[10px] text-gray-500">Verified by Jumio/Sumsub identity provider on 2026-08-14 10:22 UTC</div>
        </div>

        <!-- Administrative Actions -->
        <div class="border-t border-[#283247] pt-4 flex items-center justify-between">
          <div class="flex items-center gap-2">
            <button
              v-if="selectedSeller.tier !== 'PRO'"
              @click="upgradeTier(selectedSeller)"
              class="px-3 py-1.5 rounded bg-indigo-600 hover:bg-indigo-500 text-white text-xs font-semibold transition"
            >
              Promote to PRO
            </button>
            <button
              @click="toggleSuspension(selectedSeller)"
              class="px-3 py-1.5 rounded bg-amber-500/20 text-amber-300 border border-amber-500/30 text-xs font-semibold transition"
            >
              {{ selectedSeller.status === 'ACTIVE' ? 'Suspend Payouts' : 'Unsuspend' }}
            </button>
          </div>

          <button
            @click="banSeller(selectedSeller)"
            class="px-3 py-1.5 rounded bg-rose-600 hover:bg-rose-500 text-white text-xs font-semibold transition"
          >
            Permanent Ban
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

const searchQuery = ref('')
const tierFilter = ref('ALL')
const selectedSeller = ref<any>(null)

const sellers = ref([
  {
    id: 'usr_8921a8f2-1092-4f33-8a1e-891024810291',
    displayName: 'ExileTraderPRO',
    businessName: 'Wraeclast Commerce LLC (US-DE)',
    tier: 'PRO',
    kycStatus: 'APPROVED',
    reputationScore: 99.8,
    totalOrders: 3412,
    lifetimeVolume: 124800,
    riskScore: 4,
    status: 'ACTIVE',
    payoutRail: 'Stripe Connect (acct_1H09248218)',
    kycDocHash: 'sha256:d82e18fa4b9a128e4091a1ef4892c90e812489a2918e901b0f19248a019284fa'
  },
  {
    id: 'usr_3914b102-4412-4211-9a10-481928410294',
    displayName: 'AzerothVault',
    businessName: 'Ironforge Logistics Ltd',
    tier: 'BUSINESS',
    kycStatus: 'APPROVED',
    reputationScore: 99.4,
    totalOrders: 1840,
    lifetimeVolume: 64200,
    riskScore: 8,
    status: 'ACTIVE',
    payoutRail: 'Stripe Connect (acct_1H88219401)',
    kycDocHash: 'sha256:4b9102fa918401bca0194821a8f902481092481b0a48910284e91028491028fa'
  },
  {
    id: 'usr_109284a1-8912-4f11-ba11-192840192841',
    displayName: 'MogCourier',
    businessName: 'Individual (Japan Verified)',
    tier: 'STANDARD',
    kycStatus: 'APPROVED',
    reputationScore: 100.0,
    totalOrders: 412,
    lifetimeVolume: 9800,
    riskScore: 2,
    status: 'ACTIVE',
    payoutRail: 'Wise Borderless (JPY Account)',
    kycDocHash: 'sha256:190248fa10928401ba0194821e90248102948102a90184029481029481029481'
  },
  {
    id: 'usr_771928ba-9912-4a00-1122-849102948102',
    displayName: 'SuspiciousGoldBot',
    businessName: 'Unverified Individual',
    tier: 'STANDARD',
    kycStatus: 'PENDING',
    reputationScore: 82.1,
    totalOrders: 14,
    lifetimeVolume: 1250,
    riskScore: 78,
    status: 'SUSPENDED',
    payoutRail: 'Pending KYC Approval',
    kycDocHash: 'sha256:8891024fa019284bca0192841029481029481029a01948201948201948201948'
  }
])

const filteredSellers = computed(() => {
  return sellers.value.filter(s => {
    const matchesSearch = s.displayName.toLowerCase().includes(searchQuery.value.toLowerCase()) ||
                          s.id.toLowerCase().includes(searchQuery.value.toLowerCase())
    const matchesTier = tierFilter.value === 'ALL' || s.tier === tierFilter.value
    return matchesSearch && matchesTier
  })
})

function getTierBadgeClass(tier: string) {
  switch (tier) {
    case 'PRO': return 'bg-indigo-500/20 text-indigo-300 border-indigo-500/30'
    case 'BUSINESS': return 'bg-cyan-500/20 text-cyan-300 border-cyan-500/30'
    default: return 'bg-gray-500/20 text-gray-300 border-gray-500/30'
  }
}

function getKycBadgeClass(status: string) {
  switch (status) {
    case 'APPROVED': return 'bg-emerald-500/10 text-emerald-400 border-emerald-500/30'
    case 'PENDING': return 'bg-amber-500/10 text-amber-300 border-amber-500/30'
    default: return 'bg-rose-500/10 text-rose-400 border-rose-500/30'
  }
}

function openSellerDetails(seller: any) {
  selectedSeller.value = seller
}

function upgradeTier(seller: any) {
  seller.tier = 'PRO'
  alert(`Seller ${seller.displayName} promoted to Enterprise PRO tier.`)
}

function toggleSuspension(seller: any) {
  seller.status = seller.status === 'ACTIVE' ? 'SUSPENDED' : 'ACTIVE'
}

function banSeller(seller: any) {
  seller.status = 'BANNED'
  selectedSeller.value = null
  alert(`Seller ${seller.displayName} has been permanently banned. All active listings removed.`)
}
</script>

