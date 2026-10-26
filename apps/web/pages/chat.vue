<template>
  <div class="max-w-7xl mx-auto px-4 py-8 h-[calc(100vh-5rem)] flex flex-col">
    <!-- Chat Container -->
    <div class="bg-[#151C2F] border border-[#283247] rounded-2xl flex-1 flex overflow-hidden shadow-2xl">
      <!-- Left: Conversations Sidebar -->
      <aside class="w-80 border-r border-[#283247] flex flex-col bg-[#111726] shrink-0">
        <div class="p-4 border-b border-[#283247]">
          <h2 class="text-base font-bold text-white tracking-tight">Active Trade Chats</h2>
          <div class="relative mt-2">
            <input
              v-model="searchQuery"
              type="text"
              placeholder="Search chat or order ID..."
              class="w-full bg-[#0B1020] border border-[#283247] rounded-lg px-3 py-1.5 text-xs text-white placeholder-gray-500 focus:outline-none focus:border-[#6366F1]"
            />
          </div>
        </div>

        <div class="flex-1 overflow-y-auto divide-y divide-[#283247]/60">
          <button
            v-for="room in filteredRooms"
            :key="room.id"
            @click="selectRoom(room)"
            class="w-full text-left p-4 hover:bg-[#1A233A]/60 transition flex items-start gap-3"
            :class="selectedRoom?.id === room.id ? 'bg-[#1E263D] border-l-4 border-[#6366F1]' : ''"
          >
            <div class="w-10 h-10 rounded-full bg-gradient-to-tr from-[#6366F1] to-[#22D3EE] flex items-center justify-center font-bold text-sm text-black shrink-0">
              {{ room.counterparty[0] }}
            </div>
            <div class="flex-1 min-w-0">
              <div class="flex items-center justify-between">
                <span class="font-bold text-xs text-white truncate">{{ room.counterparty }}</span>
                <span class="text-[10px] text-gray-500 font-mono">{{ room.lastTimestamp }}</span>
              </div>
              <div class="text-[11px] text-indigo-300 truncate mt-0.5">{{ room.game }} • {{ room.orderId }}</div>
              <div class="text-[11px] text-gray-400 truncate mt-1">{{ room.lastMessage }}</div>
            </div>
          </button>
        </div>
      </aside>

      <!-- Right: Main Chat Pane -->
      <main v-if="selectedRoom" class="flex-1 flex flex-col min-w-0 bg-[#0B1020]">
        <!-- Chat Header -->
        <header class="h-16 px-6 border-b border-[#283247] bg-[#151C2F] flex items-center justify-between shrink-0">
          <div class="flex items-center gap-3">
            <div class="w-9 h-9 rounded-full bg-gradient-to-tr from-[#6366F1] to-[#22D3EE] flex items-center justify-center font-bold text-sm text-black">
              {{ selectedRoom.counterparty[0] }}
            </div>
            <div>
              <div class="flex items-center gap-2">
                <span class="font-bold text-sm text-white">{{ selectedRoom.counterparty }}</span>
                <span class="px-1.5 py-0.2 rounded bg-indigo-500/20 text-indigo-300 text-[10px] font-semibold border border-indigo-500/30">PRO</span>
                <span class="px-1.5 py-0.2 rounded bg-emerald-500/10 text-emerald-400 text-[10px] font-mono">KYC3</span>
              </div>
              <div class="text-xs text-gray-400">
                Trading: <strong class="text-white">{{ selectedRoom.game }}</strong> ({{ selectedRoom.server }})
              </div>
            </div>
          </div>

          <div class="flex items-center gap-3">
            <div class="text-right hidden sm:block">
              <div class="text-[11px] text-gray-400">Escrow Protected Order</div>
              <div class="font-mono text-xs font-bold text-emerald-400">{{ selectedRoom.orderId }} • ${{ selectedRoom.orderAmount.toFixed(2) }} USD</div>
            </div>
            <NuxtLink
              :to="`/my/orders/${selectedRoom.orderId}`"
              class="px-3 py-1.5 rounded-lg bg-[#283247] hover:bg-[#374463] text-white text-xs font-semibold transition"
            >
              Order Details
            </NuxtLink>
          </div>
        </header>

        <!-- Zero Off-Platform Warning Banner (Article 18) -->
        <div class="bg-amber-500/10 border-b border-amber-500/20 px-6 py-2 flex items-center justify-between text-xs text-amber-200">
          <div class="flex items-center gap-2">
            <span>🛡️</span>
            <span><strong>Anti-Fraud Warning:</strong> Never trade off-platform. Off-platform trades forfeit all escrow refund guarantees. External contact info is automatically intercepted.</span>
          </div>
        </div>

        <!-- Chat Message Log -->
        <div class="flex-1 p-6 overflow-y-auto space-y-4">
          <div
            v-for="(msg, idx) in selectedRoom.messages"
            :key="idx"
            class="flex flex-col"
            :class="msg.sender === 'system' ? 'items-center my-2' : msg.sender === 'me' ? 'items-end' : 'items-start'"
          >
            <!-- System notification message -->
            <div
              v-if="msg.sender === 'system'"
              class="max-w-md px-4 py-1.5 rounded-full bg-[#151C2F] border border-[#283247] text-[11px] text-indigo-300 font-medium text-center"
            >
              ⚡ {{ msg.text }}
            </div>

            <!-- User/Seller Message Bubble -->
            <div v-else class="max-w-lg space-y-1">
              <div class="flex items-center gap-2 text-[10px] text-gray-500" :class="msg.sender === 'me' ? 'justify-end' : 'justify-start'">
                <span class="font-medium text-gray-400">{{ msg.sender === 'me' ? 'You' : selectedRoom.counterparty }}</span>
                <span>{{ msg.timestamp }}</span>
              </div>

              <!-- Filtered / Masked Notice if off-platform leak detected -->
              <div
                v-if="msg.isMasked"
                class="px-4 py-2.5 rounded-2xl bg-rose-500/10 border border-rose-500/30 text-rose-300 text-xs"
              >
                🚫 [BLOCKED BY RISK ENGINE: Off-platform contact details detected]
              </div>

              <!-- Normal Message -->
              <div
                v-else
                class="px-4 py-2.5 rounded-2xl text-xs leading-relaxed"
                :class="msg.sender === 'me' ? 'bg-[#6366F1] text-white rounded-br-sm' : 'bg-[#151C2F] text-gray-200 border border-[#283247] rounded-bl-sm'"
              >
                {{ msg.text }}
              </div>
            </div>
          </div>
        </div>

        <!-- Quick Handover Presets -->
        <div class="px-6 py-2 border-t border-[#283247] bg-[#111726] flex items-center gap-2 overflow-x-auto text-[11px]">
          <span class="text-gray-500 shrink-0">Quick Presets:</span>
          <button
            v-for="preset in presets"
            :key="preset"
            @click="sendPreset(preset)"
            class="px-2.5 py-1 rounded-full bg-[#1A233A] hover:bg-[#283247] text-gray-300 hover:text-white transition whitespace-nowrap border border-[#283247]"
          >
            {{ preset }}
          </button>
        </div>

        <!-- Message Input Bar -->
        <footer class="p-4 border-t border-[#283247] bg-[#151C2F]">
          <form @submit.prevent="sendMessage" class="flex items-center gap-3">
            <input
              v-model="inputMessage"
              type="text"
              placeholder="Type your message... (Off-platform contact sharing is prohibited)"
              class="flex-1 bg-[#0B1020] border border-[#283247] rounded-xl px-4 py-2.5 text-xs text-white placeholder-gray-500 focus:outline-none focus:border-[#6366F1]"
            />
            <button
              type="submit"
              :disabled="!inputMessage.trim()"
              class="px-5 py-2.5 rounded-xl bg-[#6366F1] hover:bg-[#4F46E5] disabled:opacity-40 text-white text-xs font-semibold transition shrink-0"
            >
              Send
            </button>
          </form>
        </footer>
      </main>

      <div v-else class="flex-1 flex items-center justify-center text-gray-500 text-xs">
        Select a conversation from the sidebar to open the secure trade chat.
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

const searchQuery = ref('')
const inputMessage = ref('')

const presets = [
  '📍 I am at the meeting spot right now.',
  '⚔️ In-game trade request sent to your character.',
  '📸 Delivery screenshot uploaded to order details.',
  '✅ Trade completed in-game. Please verify and confirm receipt!'
]

interface Message {
  sender: 'me' | 'counterparty' | 'system'
  text: string
  timestamp: string
  isMasked?: boolean
}

interface Room {
  id: string
  counterparty: string
  orderId: string
  orderAmount: number
  game: string
  server: string
  lastMessage: string
  lastTimestamp: string
  messages: Message[]
}

const rooms = ref<Room[]>([
  {
    id: 'room-1',
    counterparty: 'ExileTraderPRO',
    orderId: 'ORD-847291',
    orderAmount: 42.50,
    game: 'Path of Exile 2',
    server: 'Standard League',
    lastMessage: 'Trade accepted! Uploaded SHA-256 proof.',
    lastTimestamp: '20:14',
    messages: [
      { sender: 'system', text: 'Order ORD-847291 placed. $42.50 locked in external escrow vault.', timestamp: '19:15' },
      { sender: 'counterparty', text: 'Hello! I am ready to deliver 5,000 Chaos Orbs. Meet me at Act 1 Lioneye\'s Watch Instance #2.', timestamp: '19:18' },
      { sender: 'me', text: 'On my way! My character is WraeclastSlayer_99.', timestamp: '19:20' },
      { sender: 'counterparty', text: 'Trade accepted! Uploaded SHA-256 proof.', timestamp: '20:14' },
      { sender: 'system', text: 'Seller submitted cryptographic delivery proof (e3b0c442...). 24h inspection period started.', timestamp: '20:14' }
    ]
  },
  {
    id: 'room-2',
    counterparty: 'MogCourier',
    orderId: 'ORD-719302',
    orderAmount: 32.00,
    game: 'Final Fantasy XIV',
    server: 'Chocobo (Mana)',
    lastMessage: 'Standing by Limsa Lominsa Hawkers\' Alley.',
    lastTimestamp: '20:02',
    messages: [
      { sender: 'system', text: 'Order ORD-719302 placed. Escrow funded.', timestamp: '20:00' },
      { sender: 'counterparty', text: 'Standing by Limsa Lominsa Hawkers\' Alley.', timestamp: '20:02' }
    ]
  }
])

const selectedRoom = ref<Room | null>(rooms.value[0])

const filteredRooms = computed(() => {
  if (!searchQuery.value) return rooms.value
  const q = searchQuery.value.toLowerCase()
  return rooms.value.filter(r =>
    r.counterparty.toLowerCase().includes(q) ||
    r.orderId.toLowerCase().includes(q) ||
    r.game.toLowerCase().includes(q)
  )
})

function selectRoom(room: Room) {
  selectedRoom.value = room
}

function sendPreset(text: string) {
  inputMessage.value = text
  sendMessage()
}

// Regex heuristics to detect off-platform leak attempts (Article 18)
const offPlatformRegex = /(discord|telegram|t\.me|kakao|wa\.me|whatsapp|skype|paypal|gmail|@[\w.-]+|#\d{4}|\+\d{10,})/i

function sendMessage() {
  if (!inputMessage.value.trim() || !selectedRoom.value) return

  const text = inputMessage.value.trim()
  const isOffPlatform = offPlatformRegex.test(text)

  const newMsg: Message = {
    sender: 'me',
    text: text,
    timestamp: new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' }),
    isMasked: isOffPlatform
  }

  selectedRoom.value.messages.push(newMsg)
  selectedRoom.value.lastMessage = isOffPlatform ? '[Blocked Contact Leak]' : text
  selectedRoom.value.lastTimestamp = newMsg.timestamp
  inputMessage.value = ''
}
</script>

