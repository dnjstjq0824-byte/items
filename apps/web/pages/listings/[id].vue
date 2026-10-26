<template>
  <div class="max-w-7xl mx-auto px-4 py-8">
    <!-- Breadcrumb -->
    <nav class="flex items-center gap-2 text-xs text-gray-400 mb-6">
      <NuxtLink to="/" class="hover:text-white transition">Home</NuxtLink>
      <span>/</span>
      <NuxtLink to="/games" class="hover:text-white transition">Games</NuxtLink>
      <span>/</span>
      <NuxtLink :to="`/games/${listing.gameSlug}`" class="hover:text-white transition">{{ listing.game }}</NuxtLink>
      <span>/</span>
      <span class="text-white font-semibold line-clamp-1 max-w-xs">{{ listing.title }}</span>
    </nav>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
      <!-- Left Column: Item Description & Delivery Instructions (2 cols) -->
      <div class="lg:col-span-2 space-y-6">
        <div class="surface-card p-6 md:p-8">
          <div class="flex items-center gap-3 mb-3">
            <span class="px-2.5 py-0.5 rounded text-xs font-semibold bg-[#6366F1]/15 text-[#6366F1] border border-[#6366F1]/30">
              {{ listing.productType }}
            </span>
            <span class="text-xs text-gray-400 font-mono">{{ listing.server }}</span>
          </div>

          <h1 class="text-2xl md:text-3xl font-extrabold text-white mb-4">{{ listing.title }}</h1>

          <div class="border-t border-b border-[#283247] py-4 my-6 grid grid-cols-3 gap-4 text-center">
            <div>
              <span class="text-xs text-gray-400 block mb-0.5">Delivery Method</span>
              <strong class="text-white text-xs md:text-sm font-semibold">{{ listing.deliveryMethod }}</strong>
            </div>
            <div class="border-l border-r border-[#283247]">
              <span class="text-xs text-gray-400 block mb-0.5">Estimated ETA</span>
              <strong class="text-white text-xs md:text-sm font-semibold">{{ listing.etaMinutes }} Minutes</strong>
            </div>
            <div>
              <span class="text-xs text-gray-400 block mb-0.5">Stock Available</span>
              <strong class="text-emerald-400 text-xs md:text-sm font-semibold">{{ listing.availableQuantity }} Units</strong>
            </div>
          </div>

          <div>
            <h3 class="text-sm font-bold text-white uppercase tracking-wider mb-2">Item Description</h3>
            <p class="text-sm text-gray-300 leading-relaxed whitespace-pre-line">
              {{ listing.description }}
            </p>
          </div>
        </div>

        <!-- In-game Fulfillment Guide -->
        <div class="surface-card p-6 border-l-4 border-l-[#22D3EE]">
          <h3 class="text-sm font-bold text-white mb-2 flex items-center gap-2">
            <span>Verified In-Game Delivery Protocol</span>
          </h3>
          <ol class="text-xs text-gray-400 space-y-2 list-decimal list-inside leading-relaxed">
            <li>After authorized payment confirmation, enter your exact character name in the order chat.</li>
            <li>Meet the verified seller in-game at the designated server coordinates.</li>
            <li>Confirm the item trade window and take a verification screenshot.</li>
            <li>The seller will upload timestamped SHA256-verified delivery evidence to the order record.</li>
            <li>Inspect the item in-game, then click "Confirm Receipt" to release the funds.</li>
          </ol>
        </div>

        <!-- Seller Profile Card -->
        <div class="surface-card p-6 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
          <div class="flex items-center gap-4">
            <div class="w-12 h-12 rounded-full bg-[#6366F1]/20 flex items-center justify-center font-bold text-lg text-[#6366F1]">
              {{ listing.sellerName.substring(0, 2) }}
            </div>
            <div>
              <div class="flex items-center gap-1.5">
                <span class="font-bold text-white text-sm">{{ listing.sellerName }}</span>
                <span class="text-xs text-[#22D3EE]" title="Verified Seller">&#10003;</span>
                <span class="text-[10px] px-1.5 py-0.2 rounded bg-[#22D3EE]/10 text-[#22D3EE] font-mono">PRO</span>
              </div>
              <div class="text-xs text-gray-400 mt-0.5">
                Rating {{ listing.sellerRating }} / 5.0 &bull; {{ listing.completedOrders }} Completed Orders &bull; 0% Dispute Rate
              </div>
            </div>
          </div>
          <button class="bg-[#0B1020] hover:bg-[#1f293d] text-gray-200 border border-[#283247] px-4 py-2 rounded-lg text-xs font-semibold transition">
            Contact Seller
          </button>
        </div>
      </div>

      <!-- Right Column: Interactive Quote & Checkout Summary (1 col) -->
      <div class="space-y-6">
        <div class="surface-card p-6 sticky top-24">
          <h3 class="text-base font-bold text-white mb-4">Order Summary</h3>

          <!-- Quantity Selector -->
          <div class="mb-4">
            <label class="text-xs text-gray-400 block mb-2">Quantity</label>
            <div class="flex items-center gap-3">
              <button
                @click="decrementQuantity"
                :disabled="quantity <= 1"
                class="w-9 h-9 rounded-lg bg-[#0B1020] border border-[#283247] text-white font-bold flex items-center justify-center hover:bg-[#283247] disabled:opacity-40 transition"
              >
                -
              </button>
              <input
                v-model.number="quantity"
                type="number"
                min="1"
                :max="listing.availableQuantity"
                class="w-16 text-center bg-[#0B1020] border border-[#283247] rounded-lg py-1.5 text-sm font-bold text-white"
              />
              <button
                @click="incrementQuantity"
                :disabled="quantity >= listing.availableQuantity"
                class="w-9 h-9 rounded-lg bg-[#0B1020] border border-[#283247] text-white font-bold flex items-center justify-center hover:bg-[#283247] disabled:opacity-40 transition"
              >
                +
              </button>
              <span class="text-xs text-gray-500 font-mono">Max: {{ listing.availableQuantity }}</span>
            </div>
          </div>

          <!-- Character Name Input -->
          <div class="mb-4">
            <label class="text-xs text-gray-400 block mb-1">In-Game Character Name</label>
            <input
              v-model="characterName"
              type="text"
              placeholder="e.g. DragonSlayerNA"
              class="w-full bg-[#0B1020] border border-[#283247] rounded-lg px-3 py-2 text-xs text-white focus:outline-none focus:border-[#6366F1]"
            />
          </div>

          <!-- Fee Breakdown Table -->
          <div class="border-t border-[#283247] pt-4 space-y-2 text-xs text-gray-300">
            <div class="flex justify-between">
              <span>Unit Price</span>
              <span>${{ (listing.unitPriceMinor / 100).toFixed(2) }}</span>
            </div>
            <div class="flex justify-between">
              <span>Subtotal ({{ quantity }}x)</span>
              <span>${{ subtotalFormatted }}</span>
            </div>
            <div class="flex justify-between text-emerald-400">
              <span>Buyer Platform Fee</span>
              <span>$0.00 (Promotional)</span>
            </div>
            <div class="flex justify-between text-gray-400">
              <span>Payment Processing</span>
              <span>Included</span>
            </div>
            <div class="border-t border-[#283247] pt-3 flex justify-between items-baseline font-bold text-white text-base">
              <span>Total Payable</span>
              <span class="text-xl text-[#22D3EE]">${{ subtotalFormatted }}</span>
            </div>
          </div>

          <!-- Buy Action -->
          <button
            @click="handleProceedCheckout"
            :disabled="isSubmitting"
            class="w-full mt-6 bg-[#6366F1] hover:bg-[#4F46E5] text-white py-3 rounded-lg text-sm font-bold shadow-lg transition flex items-center justify-center gap-2 disabled:opacity-50"
          >
            <span v-if="!isSubmitting">Proceed to Checkout</span>
            <span v-else>Creating Secure Session...</span>
          </button>

          <p class="text-[10px] text-gray-500 text-center mt-3 leading-tight">
            Transactions secured by external licensed PSP escrow rails. Zero direct custody of user funds.
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

const listing = {
  id: '80000000-0000-0000-0000-000000000001',
  game: 'Ethereal Odyssey Online',
  gameSlug: 'ethereal-odyssey',
  server: 'Altair Prime (NA)',
  productType: 'GAME_ITEM',
  title: '+12 Celestial Greatsword (Trade-Permitted)',
  description: `This weapon features maximum socket capacity with +12 celestial enhancement.
It is an authentic in-game transferable weapon on Altair Prime.
Fulfillment is performed through in-game player trading window at coordinates [240, 110] Altair Grand Square.
Fulfillment evidence (screenshot with SHA-256 hash) will be recorded automatically upon trade completion.`,
  deliveryMethod: 'IN_GAME_MANUAL',
  etaMinutes: 15,
  availableQuantity: 3,
  unitPriceMinor: 4500,
  sellerName: 'AetherTraderPro',
  sellerRating: '4.92',
  completedOrders: 142,
}

const quantity = ref(1)
const characterName = ref('')
const isSubmitting = ref(false)

const incrementQuantity = () => {
  if (quantity.value < listing.availableQuantity) {
    quantity.value++
  }
}

const decrementQuantity = () => {
  if (quantity.value > 1) {
    quantity.value--
  }
}

const subtotalFormatted = computed(() => {
  return ((listing.unitPriceMinor * quantity.value) / 100).toFixed(2)
})

const handleProceedCheckout = () => {
  if (!characterName.value.trim()) {
    alert('Please enter your character name for in-game delivery verification.')
    return
  }
  isSubmitting.value = true
  setTimeout(() => {
    isSubmitting.value = false
    alert(`Order quote created for ${quantity.value}x ${listing.title}. Redirecting to PSP checkout session...`)
  }, 800)
}
</script>

