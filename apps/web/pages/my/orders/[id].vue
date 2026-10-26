<template>
  <div class="max-w-6xl mx-auto px-4 py-8">
    <!-- Back to Orders -->
    <div class="mb-6">
      <NuxtLink to="/my/orders" class="text-xs text-indigo-400 hover:text-indigo-300 flex items-center gap-1 font-medium">
        ← Back to My Orders
      </NuxtLink>
    </div>

    <!-- Order Header -->
    <div class="bg-[#151C2F] border border-[#283247] rounded-xl p-6 mb-6">
      <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <div>
          <div class="flex items-center gap-3">
            <h1 class="text-2xl font-bold text-white font-mono">{{ order.id }}</h1>
            <span class="px-2.5 py-1 rounded text-xs font-semibold border" :class="getStatusBadgeClass(order.status)">
              {{ order.statusLabel }}
            </span>
          </div>
          <p class="text-xs text-gray-400 mt-1">Placed on {{ order.createdAt }} • Payment Rail: {{ order.paymentProvider }} (Escrow Vault)</p>
        </div>

        <div class="flex items-center gap-3">
          <button
            v-if="order.status === 'DELIVERY_CLAIMED'"
            @click="showConfirmModal = true"
            class="px-5 py-2.5 rounded-lg bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-semibold shadow-lg shadow-emerald-900/30 transition"
          >
            Confirm Receipt & Release Funds
          </button>

          <button
            v-if="order.status === 'DELIVERY_CLAIMED' || order.status === 'IN_DELIVERY'"
            @click="showDisputeModal = true"
            class="px-4 py-2.5 rounded-lg bg-rose-500/10 hover:bg-rose-500/20 text-rose-300 border border-rose-500/30 text-xs font-semibold transition"
          >
            Open Dispute
          </button>
        </div>
      </div>

      <!-- Auto Release Banner -->
      <div v-if="order.status === 'DELIVERY_CLAIMED'" class="mt-6 p-4 rounded-lg bg-amber-500/10 border border-amber-500/30 flex items-start gap-3 text-xs text-amber-200">
        <span class="text-base">⏳</span>
        <div>
          <div class="font-semibold">Buyer Inspection Period Active</div>
          <div class="mt-0.5 text-amber-300/80">
            The seller has provided cryptographic proof of delivery. Please verify the asset in-game. If no action is taken within <strong>{{ order.autoReleaseCountdown }}</strong>, the escrow funds will be automatically released to the seller.
          </div>
        </div>
      </div>

      <!-- Lifecycle Stepper -->
      <div class="mt-8 pt-6 border-t border-[#283247]">
        <div class="grid grid-cols-2 md:grid-cols-5 gap-3 text-center text-xs">
          <div v-for="(step, idx) in steps" :key="step.key" class="relative">
            <div
              class="w-7 h-7 mx-auto rounded-full flex items-center justify-center font-bold text-xs mb-2 transition"
              :class="getStepCircleClass(idx)"
            >
              {{ idx + 1 }}
            </div>
            <div class="font-medium" :class="idx <= currentStepIndex ? 'text-white' : 'text-gray-500'">
              {{ step.title }}
            </div>
            <div class="text-[10px] text-gray-500 mt-0.5">{{ step.desc }}</div>
          </div>
        </div>
      </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- Left Column: Trade Details & Cryptographic Delivery Evidence -->
      <div class="lg:col-span-2 space-y-6">
        <!-- Purchased Goods Summary -->
        <div class="bg-[#151C2F] border border-[#283247] rounded-xl p-6">
          <h2 class="text-sm font-semibold text-gray-300 uppercase tracking-wider mb-4">Purchased Digital Asset</h2>
          <div class="flex items-start gap-4">
            <div class="w-14 h-14 rounded-lg bg-[#0B1020] border border-[#283247] flex items-center justify-center text-2xl shrink-0">
              {{ order.gameIcon }}
            </div>
            <div class="flex-1">
              <div class="text-xs text-indigo-400 font-semibold">{{ order.game }} • {{ order.platform }} • {{ order.server }}</div>
              <h3 class="text-lg font-bold text-white mt-1">{{ order.title }}</h3>
              <div class="grid grid-cols-2 sm:grid-cols-3 gap-3 mt-4 text-xs">
                <div class="bg-[#0B1020] p-2.5 rounded-lg border border-[#283247]">
                  <div class="text-gray-400">Delivered Quantity</div>
                  <div class="text-white font-bold font-mono mt-0.5">{{ order.quantity }} {{ order.unit }}</div>
                </div>
                <div class="bg-[#0B1020] p-2.5 rounded-lg border border-[#283247]">
                  <div class="text-gray-400">Unit Price</div>
                  <div class="text-white font-bold font-mono mt-0.5">${{ order.unitPrice }}</div>
                </div>
                <div class="bg-[#0B1020] p-2.5 rounded-lg border border-[#283247]">
                  <div class="text-gray-400">Product Class</div>
                  <div class="text-emerald-400 font-semibold font-mono mt-0.5">{{ order.productType }}</div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- In-Game Handover Instructions -->
        <div class="bg-[#151C2F] border border-[#283247] rounded-xl p-6">
          <h2 class="text-sm font-semibold text-gray-300 uppercase tracking-wider mb-4">In-Game Handover Protocol</h2>
          <div class="space-y-3 text-xs">
            <div class="flex justify-between py-2 border-b border-[#283247]">
              <span class="text-gray-400">Buyer In-Game Character Name</span>
              <span class="font-mono text-white font-semibold">{{ order.inGameBuyerName }}</span>
            </div>
            <div class="flex justify-between py-2 border-b border-[#283247]">
              <span class="text-gray-400">Seller In-Game Character Name</span>
              <span class="font-mono text-white font-semibold">{{ order.inGameSellerName }}</span>
            </div>
            <div class="flex justify-between py-2 border-b border-[#283247]">
              <span class="text-gray-400">Designated Meeting Location</span>
              <span class="text-white">{{ order.meetingLocation }}</span>
            </div>
            <div class="flex justify-between py-2">
              <span class="text-gray-400">Fulfillment Method</span>
              <span class="text-emerald-400 font-medium">{{ order.handoverMethod }}</span>
            </div>
          </div>
        </div>

        <!-- Cryptographic Proof of Delivery (Article 15) -->
        <div class="bg-[#151C2F] border border-[#283247] rounded-xl p-6">
          <div class="flex items-center justify-between mb-4">
            <div>
              <h2 class="text-sm font-semibold text-white uppercase tracking-wider">Cryptographic Proof of Delivery</h2>
              <p class="text-xs text-gray-400 mt-0.5">Immutable proof submitted by seller upon in-game transfer completion.</p>
            </div>
            <span class="px-2 py-0.5 rounded bg-emerald-500/10 text-emerald-400 border border-emerald-500/30 text-[10px] font-mono">
              SHA-256 VERIFIED
            </span>
          </div>

          <div v-if="order.deliveryProof" class="space-y-4">
            <!-- Proof Metadata Card -->
            <div class="bg-[#0B1020] border border-[#283247] rounded-lg p-4 font-mono text-xs space-y-2">
              <div class="flex justify-between">
                <span class="text-gray-400">Evidence File:</span>
                <span class="text-indigo-300 font-semibold">{{ order.deliveryProof.filename }}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-gray-400">Submitted At:</span>
                <span class="text-white">{{ order.deliveryProof.submittedAt }}</span>
              </div>
              <div class="flex flex-col sm:flex-row sm:justify-between gap-1 pt-2 border-t border-[#283247]/60">
                <span class="text-gray-400 shrink-0">SHA-256 Digest:</span>
                <span class="text-emerald-400 break-all text-[11px]">{{ order.deliveryProof.sha256Hash }}</span>
              </div>
            </div>

            <!-- Proof Image Preview Frame -->
            <div class="border border-[#283247] rounded-lg overflow-hidden bg-[#0B1020] relative">
              <div class="p-3 bg-[#151C2F] border-b border-[#283247] flex items-center justify-between text-xs text-gray-300">
                <span class="font-medium">In-Game Trade Window Screenshot</span>
                <span class="text-[11px] text-gray-400">{{ order.deliveryProof.fileSize }}</span>
              </div>
              <div class="h-64 flex flex-col items-center justify-center p-6 text-center bg-gradient-to-b from-[#0B1020] to-[#151C2F]/50">
                <div class="text-4xl mb-2">📸</div>
                <div class="text-sm font-semibold text-white">Encrypted Image Evidence Recorded</div>
                <div class="text-xs text-gray-400 max-w-sm mt-1">
                  Both counterparties, timestamp, and item quantity are sealed in this cryptographically signed delivery payload.
                </div>
                <button class="mt-4 px-3 py-1.5 rounded bg-[#283247] hover:bg-[#374463] text-white text-xs font-semibold transition">
                  View Full Resolution Evidence
                </button>
              </div>
            </div>

            <!-- Handover Note -->
            <div class="bg-[#0B1020] p-3 rounded-lg border border-[#283247] text-xs">
              <span class="text-gray-400 font-medium">Seller Handover Note: </span>
              <span class="text-white">"Trade accepted in Act 1 Lioneye's Watch at 20:12 UTC. Thanks for trading!"</span>
            </div>
          </div>

          <div v-else class="text-center py-8 text-gray-400 text-xs">
            No delivery proof uploaded yet. Waiting for seller to complete in-game transfer.
          </div>
        </div>
      </div>

      <!-- Right Column: Counterparty, Financial Breakdown, Dispute Action -->
      <div class="space-y-6">
        <!-- Counterparty Seller Card -->
        <div class="bg-[#151C2F] border border-[#283247] rounded-xl p-6">
          <h2 class="text-sm font-semibold text-gray-300 uppercase tracking-wider mb-4">Counterparty Seller</h2>
          <div class="flex items-center gap-3">
            <div class="w-12 h-12 rounded-full bg-gradient-to-tr from-[#6366F1] to-[#EC4899] flex items-center justify-center text-white font-bold text-lg">
              {{ order.sellerName[0] }}
            </div>
            <div>
              <div class="flex items-center gap-2">
                <span class="font-bold text-white text-sm">{{ order.sellerName }}</span>
                <span class="px-1.5 py-0.5 rounded bg-indigo-500/20 text-indigo-300 text-[10px] font-semibold border border-indigo-500/30">PRO</span>
              </div>
              <div class="text-xs text-gray-400 mt-0.5">{{ order.sellerRep }}% Positive • 2,491 Trades</div>
            </div>
          </div>

          <div class="mt-4 pt-4 border-t border-[#283247] space-y-2 text-xs">
            <div class="flex justify-between text-gray-400">
              <span>Avg Handover Speed</span>
              <span class="text-emerald-400 font-medium">7 Minutes</span>
            </div>
            <div class="flex justify-between text-gray-400">
              <span>KYC Level</span>
              <span class="text-white font-medium">Tier 3 (Verified Business)</span>
            </div>
          </div>

          <NuxtLink to="/chat" class="mt-5 w-full block text-center py-2.5 rounded-lg bg-[#283247] hover:bg-[#374463] text-white text-xs font-semibold transition">
            💬 Open In-App Chat
          </NuxtLink>
        </div>

        <!-- Financial Breakdown & Escrow Ledger -->
        <div class="bg-[#151C2F] border border-[#283247] rounded-xl p-6">
          <h2 class="text-sm font-semibold text-gray-300 uppercase tracking-wider mb-4">Escrow Ledger Breakdown</h2>
          <div class="space-y-3 text-xs">
            <div class="flex justify-between text-gray-400">
              <span>Asset Subtotal</span>
              <span class="text-white font-mono">${{ order.totalAmount.toFixed(2) }}</span>
            </div>
            <div class="flex justify-between text-gray-400">
              <span>Buyer Platform Fee</span>
              <span class="text-emerald-400 font-semibold font-mono">$0.00 (0%)</span>
            </div>
            <div class="flex justify-between text-gray-400">
              <span>Escrow Protection Fee</span>
              <span class="text-emerald-400 font-semibold font-mono">Included</span>
            </div>
            <div class="pt-3 border-t border-[#283247] flex justify-between text-sm font-bold">
              <span class="text-white">Total Amount Paid</span>
              <span class="text-emerald-400 font-mono">${{ order.totalAmount.toFixed(2) }} USD</span>
            </div>
          </div>

          <div class="mt-4 p-3 rounded-lg bg-[#0B1020] border border-[#283247] text-[11px] text-gray-400">
            🔒 Protected by BN Escrow Vault. Funds will not be disbursed until you confirm receipt or the inspection timer expires without dispute.
          </div>
        </div>

        <!-- Safety Notice -->
        <div class="bg-[#151C2F]/60 border border-[#283247] rounded-xl p-5 text-xs text-gray-400 space-y-2">
          <div class="font-semibold text-white flex items-center gap-1.5">
            <span>🛡️</span> Zero Off-Platform Policy
          </div>
          <p class="leading-relaxed text-[11px]">
            Never agree to trade on Discord, Telegram, or private in-game whispers outside of this order ID. Only trades conducted under platform escrow and recorded evidence are protected.
          </p>
        </div>
      </div>
    </div>

    <!-- Confirm Receipt Modal -->
    <div v-if="showConfirmModal" class="fixed inset-0 bg-black/70 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <div class="bg-[#151C2F] border border-[#283247] rounded-2xl max-w-md w-full p-6 space-y-4">
        <h3 class="text-lg font-bold text-white">Confirm Asset Delivery</h3>
        <p class="text-xs text-gray-300 leading-relaxed">
          By clicking <strong>Confirm & Release</strong>, you certify that you have logged into {{ order.game }} and safely received the exact agreed quantity of <strong>{{ order.quantity }} {{ order.unit }}</strong>.
        </p>
        <div class="p-3 rounded-lg bg-amber-500/10 border border-amber-500/30 text-xs text-amber-300">
          ⚠️ This action is irreversible. The escrow ledger will immediately disburse funds to the seller.
        </div>
        <div class="flex items-center justify-end gap-3 pt-3">
          <button @click="showConfirmModal = false" class="px-4 py-2 rounded-lg bg-[#283247] text-white text-xs font-semibold">
            Cancel
          </button>
          <button @click="executeConfirmReceipt" class="px-4 py-2 rounded-lg bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-semibold">
            Confirm & Release Funds
          </button>
        </div>
      </div>
    </div>

    <!-- Open Dispute Modal -->
    <div v-if="showDisputeModal" class="fixed inset-0 bg-black/70 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <div class="bg-[#151C2F] border border-[#283247] rounded-2xl max-w-lg w-full p-6 space-y-4">
        <h3 class="text-lg font-bold text-white">Open Trade Dispute</h3>
        <p class="text-xs text-gray-300">
          Opening a dispute locks escrow funds immediately. Our 4-Eyes Compliance & Dispute Operations team will review all chat logs and evidence.
        </p>
        <div>
          <label class="block text-xs font-medium text-gray-300 mb-1">Dispute Reason</label>
          <select v-model="disputeReason" class="w-full bg-[#0B1020] border border-[#283247] rounded-lg px-3 py-2 text-xs text-white">
            <option value="NOT_RECEIVED">Item / Currency was never handed over in-game</option>
            <option value="INCORRECT_QUANTITY">Delivered quantity is lower than ordered</option>
            <option value="WRONG_SERVER">Delivered on the wrong realm or server</option>
            <option value="SELLER_UNRESPONSIVE">Seller is unresponsive in designated trade window</option>
            <option value="SUSPECTED_FRAUD">Suspected illicit duplication or fraudulent activity</option>
          </select>
        </div>
        <div>
          <label class="block text-xs font-medium text-gray-300 mb-1">Detailed Explanation & In-Game Context</label>
          <textarea
            v-model="disputeNote"
            rows="3"
            placeholder="Explain what happened during the in-game meet up..."
            class="w-full bg-[#0B1020] border border-[#283247] rounded-lg p-3 text-xs text-white focus:outline-none focus:border-[#6366F1]"
          ></textarea>
        </div>
        <div class="flex items-center justify-end gap-3 pt-3">
          <button @click="showDisputeModal = false" class="px-4 py-2 rounded-lg bg-[#283247] text-white text-xs font-semibold">
            Cancel
          </button>
          <button @click="executeOpenDispute" class="px-4 py-2 rounded-lg bg-rose-600 hover:bg-rose-500 text-white text-xs font-semibold">
            Submit Dispute Claim
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const showConfirmModal = ref(false)
const showDisputeModal = ref(route.query.action === 'dispute')
const disputeReason = ref('NOT_RECEIVED')
const disputeNote = ref('')

const steps = [
  { key: 'CREATED', title: 'Order Created', desc: 'Listing locked' },
  { key: 'PAID', title: 'Escrow Locked', desc: 'Payment approved' },
  { key: 'DELIVERING', title: 'In Handover', desc: 'Seller fulfilling' },
  { key: 'PROOF', title: 'Proof Provided', desc: 'SHA-256 evidence' },
  { key: 'COMPLETED', title: 'Settled', desc: 'Escrow released' },
]

const order = ref({
  id: 'ORD-847291',
  createdAt: '2026-10-24 19:15 UTC',
  paymentProvider: 'Stripe Sandbox (Cards & Local Wallets)',
  game: 'Path of Exile 2',
  gameIcon: '⚔️',
  platform: 'PC',
  server: 'Standard League',
  title: '5,000x Chaos Orb (Direct In-Game Face-to-Face Trade)',
  quantity: 5000,
  unit: 'Chaos Orbs',
  unitPrice: 0.0085,
  productType: 'GAME_CURRENCY',
  totalAmount: 42.50,
  sellerName: 'ExileTraderPRO',
  sellerRep: 99.8,
  inGameBuyerName: 'WraeclastSlayer_99',
  inGameSellerName: 'VaultKeeper_PoE2',
  meetingLocation: 'Act 1 Lioneye\'s Watch, Instance #2 (by the Waypoint)',
  handoverMethod: 'Face-to-Face Trade Window with Screenshot Verification',
  status: 'DELIVERY_CLAIMED',
  statusLabel: 'Delivery Claimed (Awaiting Buyer Confirmation)',
  autoReleaseCountdown: '18h 42m',
  deliveryProof: {
    filename: 'poe2_trade_proof_847291.jpg',
    fileSize: '1.84 MB',
    submittedAt: '2026-10-24 20:12:44 UTC',
    sha256Hash: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
  }
})

const currentStepIndex = computed(() => {
  switch (order.value.status) {
    case 'ORDER_CREATED': return 0
    case 'PAYMENT_PENDING': return 0
    case 'PAYMENT_CONFIRMED': return 1
    case 'IN_DELIVERY': return 2
    case 'DELIVERY_CLAIMED': return 3
    case 'COMPLETED': return 4
    default: return 3
  }
})

function getStepCircleClass(idx: number) {
  if (idx < currentStepIndex.value) {
    return 'bg-emerald-500 text-black'
  } else if (idx === currentStepIndex.value) {
    return 'bg-[#6366F1] text-white ring-4 ring-[#6366F1]/20'
  }
  return 'bg-[#283247] text-gray-500'
}

function getStatusBadgeClass(status: string) {
  switch (status) {
    case 'DELIVERY_CLAIMED':
      return 'bg-cyan-500/10 text-cyan-300 border-cyan-500/30'
    case 'COMPLETED':
      return 'bg-emerald-500/10 text-emerald-300 border-emerald-500/30'
    case 'DISPUTED':
      return 'bg-rose-500/10 text-rose-300 border-rose-500/30'
    default:
      return 'bg-indigo-500/10 text-indigo-300 border-indigo-500/30'
  }
}

function executeConfirmReceipt() {
  order.value.status = 'COMPLETED'
  order.value.statusLabel = 'Completed & Settled'
  order.value.autoReleaseCountdown = ''
  showConfirmModal.value = false
  alert('Delivery confirmed! Payment has been released to the seller.')
}

function executeOpenDispute() {
  order.value.status = 'DISPUTED'
  order.value.statusLabel = 'Under Dispute (4-Eyes Investigation)'
  showDisputeModal.value = false
  alert('Dispute opened. Escrow funds have been frozen and an operational agent has been assigned.')
}
</script>

