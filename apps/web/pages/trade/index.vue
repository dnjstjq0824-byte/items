<template>
  <div class="max-w-7xl mx-auto px-4 py-8">
    <!-- Header with Breadcrumb & Quick Action Buttons -->
    <div class="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-6">
      <div>
        <div class="flex items-center gap-2 text-xs text-indigo-400 font-semibold mb-1">
          <span>🎮 GAME ITEM & CURRENCY P2P MARKET</span>
          <span class="text-gray-600">•</span>
          <span class="text-emerald-400">100% ESCROW PROTECTED</span>
        </div>
        <h1 class="text-2xl font-black text-white tracking-tight">아이템 & 게임머니 거래소</h1>
        <p class="text-xs text-gray-400 mt-1">
          아이템매니아 · 바로템 방식의 안전 에스크로 중개 시스템. 사기 피해 200% 보상 및 24시간 실시간 정산 지원.
        </p>
      </div>

      <div class="flex items-center gap-3">
        <NuxtLink
          to="/trade/sell"
          class="px-5 py-2.5 rounded-xl bg-gradient-to-r from-indigo-600 to-indigo-700 hover:from-indigo-500 hover:to-indigo-600 text-white font-bold text-xs shadow-lg shadow-indigo-950/50 flex items-center gap-2 transition"
        >
          <span>🏷️</span> 팝니다 등록
        </NuxtLink>
        <NuxtLink
          to="/trade/buy"
          class="px-5 py-2.5 rounded-xl bg-gradient-to-r from-emerald-600 to-teal-700 hover:from-emerald-500 hover:to-teal-600 text-white font-bold text-xs shadow-lg shadow-teal-950/50 flex items-center gap-2 transition"
        >
          <span>🛒</span> 삽니다 등록
        </NuxtLink>
        <NuxtLink
          to="/my/mileage"
          class="px-4 py-2.5 rounded-xl bg-[#151C2F] hover:bg-[#1E263D] border border-[#283247] text-white font-semibold text-xs flex items-center gap-1.5 transition"
        >
          <span>💰</span> 마일리지 관리
        </NuxtLink>
      </div>
    </div>

    <!-- Multi-Step Game & Server Selector Bar (BaroTem / ItemMania style) -->
    <div class="bg-[#151C2F] border border-[#283247] rounded-2xl p-5 mb-6 shadow-xl">
      <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
        <!-- Game Selector -->
        <div>
          <label class="block text-[11px] font-bold text-gray-400 mb-1.5 uppercase tracking-wider">1. 게임 선택</label>
          <select
            v-model="selectedGameId"
            @change="onGameChange"
            class="w-full bg-[#0B1020] border border-[#283247] rounded-xl px-3.5 py-2.5 text-xs text-white font-semibold focus:outline-none focus:border-[#6366F1]"
          >
            <option v-for="g in games" :key="g.id" :value="g.id">{{ g.name }}</option>
          </select>
        </div>

        <!-- Server Selector -->
        <div>
          <label class="block text-[11px] font-bold text-gray-400 mb-1.5 uppercase tracking-wider">2. 서버 선택</label>
          <select
            v-model="selectedServer"
            class="w-full bg-[#0B1020] border border-[#283247] rounded-xl px-3.5 py-2.5 text-xs text-white font-semibold focus:outline-none focus:border-[#6366F1]"
          >
            <option value="ALL">전체 서버</option>
            <option v-for="s in availableServers" :key="s" :value="s">{{ s }}</option>
          </select>
        </div>

        <!-- Category Selector -->
        <div>
          <label class="block text-[11px] font-bold text-gray-400 mb-1.5 uppercase tracking-wider">3. 물품 분류</label>
          <select
            v-model="selectedCategory"
            class="w-full bg-[#0B1020] border border-[#283247] rounded-xl px-3.5 py-2.5 text-xs text-white font-semibold focus:outline-none focus:border-[#6366F1]"
          >
            <option value="ALL">전체 물품</option>
            <option value="GAME_MONEY">게임머니 (골드/메소/다이아)</option>
            <option value="GAME_ITEM">일반/고가 아이템</option>
            <option value="PACKAGE_CODE">공식 기프트/패키지 코드</option>
          </select>
        </div>

        <!-- Keyword Search -->
        <div>
          <label class="block text-[11px] font-bold text-gray-400 mb-1.5 uppercase tracking-wider">4. 검색어 (아이템/판매자)</label>
          <div class="relative">
            <input
              v-model="searchKeyword"
              type="text"
              placeholder="예: 카오스 오브, 100만 골드..."
              class="w-full bg-[#0B1020] border border-[#283247] rounded-xl px-3.5 py-2.5 text-xs text-white placeholder-gray-500 focus:outline-none focus:border-[#6366F1]"
            />
          </div>
        </div>
      </div>
    </div>

    <!-- Trade Mode Tabs: 팝니다 (SELL) vs 삽니다 (BUY) -->
    <div class="flex items-center justify-between border-b border-[#283247] pb-3 mb-6">
      <div class="flex items-center gap-3">
        <button
          @click="activeArticleType = 'SELL'"
          class="px-5 py-2 rounded-xl text-xs font-black transition flex items-center gap-2"
          :class="activeArticleType === 'SELL' ? 'bg-[#6366F1] text-white shadow-lg shadow-indigo-900/40' : 'bg-[#151C2F] text-gray-400 hover:text-white hover:bg-[#1E263D]'"
        >
          <span>📢 팝니다 (판매 목록)</span>
          <span class="px-1.5 py-0.5 rounded-full bg-white/20 text-[10px]">{{ filteredSellArticles.length }}</span>
        </button>

        <button
          @click="activeArticleType = 'BUY'"
          class="px-5 py-2 rounded-xl text-xs font-black transition flex items-center gap-2"
          :class="activeArticleType === 'BUY' ? 'bg-emerald-600 text-white shadow-lg shadow-emerald-900/40' : 'bg-[#151C2F] text-gray-400 hover:text-white hover:bg-[#1E263D]'"
        >
          <span>🎯 삽니다 (구매 의뢰)</span>
          <span class="px-1.5 py-0.5 rounded-full bg-white/20 text-[10px]">{{ filteredBuyArticles.length }}</span>
        </button>
      </div>

      <!-- Quick Trust Indicators -->
      <div class="hidden lg:flex items-center gap-4 text-xs font-semibold">
        <span class="text-amber-400 flex items-center gap-1">
          <span>🛡️</span> 200% 보상제도 운영
        </span>
        <span class="text-emerald-400 flex items-center gap-1">
          <span>⚡</span> 3분 이내 빠른 인계 보장
        </span>
      </div>
    </div>

    <!-- Articles Data Grid Table (ItemMania / BaroTem layout) -->
    <div class="bg-[#151C2F] border border-[#283247] rounded-2xl overflow-hidden shadow-2xl">
      <div class="overflow-x-auto">
        <table class="w-full text-left text-xs">
          <thead class="bg-[#0B1020] border-b border-[#283247] text-gray-400 uppercase tracking-wider font-bold">
            <tr>
              <th class="p-4">구분 / 서버</th>
              <th class="p-4">물품 제목 및 거래 조건</th>
              <th class="p-4">판매수량</th>
              <th class="p-4">단가 / 총금액</th>
              <th class="p-4">판매자 / 신용도</th>
              <th class="p-4 text-right">신청하기</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-[#283247] text-gray-300">
            <tr
              v-for="item in currentArticles"
              :key="item.id"
              class="hover:bg-[#1E263D]/70 transition group"
            >
              <!-- Server & Type -->
              <td class="p-4">
                <div class="flex items-center gap-2">
                  <span
                    class="px-2 py-0.5 rounded text-[10px] font-black"
                    :class="item.type === 'SELL' ? 'bg-indigo-500/20 text-indigo-300 border border-indigo-500/30' : 'bg-emerald-500/20 text-emerald-300 border border-emerald-500/30'"
                  >
                    {{ item.type === 'SELL' ? '팝니다' : '삽니다' }}
                  </span>
                  <span class="font-bold text-white">{{ item.server }}</span>
                </div>
                <div class="text-[11px] text-gray-500 font-mono mt-1">{{ item.categoryLabel }}</div>
              </td>

              <!-- Title & Badges -->
              <td class="p-4">
                <div class="flex items-center gap-2">
                  <span
                    v-if="item.has200Guarantee"
                    class="px-1.5 py-0.5 rounded bg-rose-500/20 text-rose-300 border border-rose-500/40 text-[10px] font-black tracking-tight"
                  >
                    200% 보상
                  </span>
                  <span
                    v-if="item.isSplitTrade"
                    class="px-1.5 py-0.5 rounded bg-blue-500/20 text-blue-300 border border-blue-500/30 text-[10px] font-semibold"
                  >
                    분할가능
                  </span>
                  <NuxtLink :to="`/trade/${item.id}`" class="font-bold text-white group-hover:text-indigo-400 transition">
                    {{ item.title }}
                  </NuxtLink>
                </div>
                <div class="text-[11px] text-gray-400 mt-1 flex items-center gap-3">
                  <span>인게임 접선 캐릭터: <strong class="text-gray-300 font-mono">{{ item.characterName }}</strong></span>
                  <span v-if="item.safetyPhone" class="text-emerald-400 font-mono">📞 안심번호 제공</span>
                </div>
              </td>

              <!-- Quantity -->
              <td class="p-4 font-mono font-bold text-white">
                <div>{{ item.quantity.toLocaleString() }} {{ item.unit }}</div>
                <div v-if="item.isSplitTrade" class="text-[10px] text-gray-500 font-sans font-normal">
                  최소 {{ item.minQuantity }} {{ item.unit }} 단위
                </div>
              </td>

              <!-- Price -->
              <td class="p-4 font-mono">
                <div class="text-base font-extrabold text-emerald-400">
                  {{ item.totalPrice.toLocaleString() }} 원
                </div>
                <div class="text-[11px] text-gray-400">
                  ({{ item.unitPrice.toLocaleString() }} 원 / 1 {{ item.unit }})
                </div>
              </td>

              <!-- Counterparty Trust -->
              <td class="p-4">
                <div class="flex items-center gap-2">
                  <span class="font-bold text-white">{{ item.userName }}</span>
                  <span class="px-1.5 py-0.5 rounded bg-amber-500/20 text-amber-300 text-[10px] font-bold border border-amber-500/30">
                    {{ item.userGrade }}
                  </span>
                </div>
                <div class="text-[11px] text-gray-400 mt-0.5">
                  거래 {{ item.tradeCount }}건 • 만족도 <strong class="text-emerald-400">{{ item.satisfaction }}%</strong>
                </div>
              </td>

              <!-- Action Button -->
              <td class="p-4 text-right">
                <NuxtLink
                  :to="`/trade/${item.id}`"
                  class="px-4 py-2 rounded-xl text-xs font-bold transition inline-flex items-center gap-1 shadow-md"
                  :class="item.type === 'SELL' ? 'bg-indigo-600 hover:bg-indigo-500 text-white' : 'bg-emerald-600 hover:bg-emerald-500 text-white'"
                >
                  {{ item.type === 'SELL' ? '구매신청' : '판매신청' }}
                </NuxtLink>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Empty State -->
      <div v-if="currentArticles.length === 0" class="p-12 text-center text-gray-400">
        <div class="text-4xl mb-3">🔍</div>
        <div class="text-base font-bold text-white">해당 조건에 일치하는 물품이 없습니다.</div>
        <p class="text-xs text-gray-500 mt-1">검색어나 서버 필터를 변경하거나 새로운 거래를 등록해 보세요.</p>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

const activeArticleType = ref<'SELL' | 'BUY'>('SELL')
const selectedGameId = ref('poe2')
const selectedServer = ref('ALL')
const selectedCategory = ref('ALL')
const searchKeyword = ref('')

const games = [
  { id: 'poe2', name: '패스 오브 엑자일 2 (PoE 2)', servers: ['스탠다드 리그', '하드코어 리그'] },
  { id: 'lineagew', name: '리니지 W (Lineage W)', servers: ['에바 01', '에바 02', '아덴 01', '기란 01'] },
  { id: 'odin', name: '오딘: 발할라 라이징', servers: ['오딘 01', '토르 03', '로키 02'] },
  { id: 'maple', name: '메이플스토리', servers: ['스카니아', '루나', '엘리시움', '크로아'] },
  { id: 'ff14', name: '파이널 판타지 14', servers: ['초코보 (마나)', '모그리 (가이아)', '카벙클 (엘레)'] },
]

const availableServers = computed(() => {
  const g = games.find(item => item.id === selectedGameId.value)
  return g ? g.servers : []
})

function onGameChange() {
  selectedServer.value = 'ALL'
}

const mockArticles = ref([
  {
    id: 'TRD-9001',
    gameId: 'poe2',
    server: '스탠다드 리그',
    type: 'SELL',
    category: 'GAME_MONEY',
    categoryLabel: '게임머니',
    title: '5,000 카오스 오브 즉시거래 (접선 즉시 1분 전달)',
    characterName: '레이클라스트상인',
    unit: '카오스 오브',
    quantity: 5000,
    minQuantity: 1000,
    isSplitTrade: true,
    unitPrice: 12,
    totalPrice: 60000,
    userName: '엑자일전문상단',
    userGrade: 'VIP 플래티넘',
    tradeCount: 1420,
    satisfaction: 99.8,
    has200Guarantee: true,
    safetyPhone: true,
  },
  {
    id: 'TRD-9002',
    gameId: 'poe2',
    server: '스탠다드 리그',
    type: 'SELL',
    category: 'GAME_ITEM',
    categoryLabel: '아이템',
    title: '디바인 오브 20개 일괄 처분합니다 (에스크로 환영)',
    characterName: '디바인창고',
    unit: '디바인 오브',
    quantity: 20,
    minQuantity: 20,
    isSplitTrade: false,
    unitPrice: 1800,
    totalPrice: 36000,
    userName: '새벽거래러',
    userGrade: '골드',
    tradeCount: 312,
    satisfaction: 100.0,
    has200Guarantee: true,
    safetyPhone: false,
  },
  {
    id: 'TRD-9003',
    gameId: 'lineagew',
    server: '에바 01',
    type: 'SELL',
    category: 'GAME_MONEY',
    categoryLabel: '게임머니',
    title: '1억 아데나 분할판매 (안심번호 통화 가능)',
    characterName: '아덴상단마스터',
    unit: '만 아데나',
    quantity: 10000,
    minQuantity: 1000,
    isSplitTrade: true,
    unitPrice: 15,
    totalPrice: 150000,
    userName: '아덴보부상',
    userGrade: 'VIP 다이아',
    tradeCount: 3840,
    satisfaction: 99.4,
    has200Guarantee: true,
    safetyPhone: true,
  },
  {
    id: 'TRD-9004',
    gameId: 'maple',
    server: '스카니아',
    type: 'SELL',
    category: 'GAME_MONEY',
    categoryLabel: '게임머니',
    title: '스카니아 50억 메소 일괄판매 (친절거래)',
    characterName: '단풍잎골드',
    unit: '억 메소',
    quantity: 50,
    minQuantity: 10,
    isSplitTrade: true,
    unitPrice: 2200,
    totalPrice: 110000,
    userName: '메이플마스터',
    userGrade: 'VIP 골드',
    tradeCount: 890,
    satisfaction: 99.1,
    has200Guarantee: true,
    safetyPhone: true,
  },
  {
    id: 'TRD-9005',
    gameId: 'poe2',
    server: '스탠다드 리그',
    type: 'BUY',
    category: 'GAME_MONEY',
    categoryLabel: '게임머니',
    title: '[급구] 카오스 오브 10,000개 일괄 삽니다. 즉시 입금완료',
    characterName: '구매자전사용',
    unit: '카오스 오브',
    quantity: 10000,
    minQuantity: 10000,
    isSplitTrade: false,
    unitPrice: 11,
    totalPrice: 110000,
    userName: '파워바이어',
    userGrade: '일반',
    tradeCount: 45,
    satisfaction: 100.0,
    has200Guarantee: false,
    safetyPhone: true,
  }
])

const filteredSellArticles = computed(() => {
  return mockArticles.value.filter(a => a.type === 'SELL')
})

const filteredBuyArticles = computed(() => {
  return mockArticles.value.filter(a => a.type === 'BUY')
})

const currentArticles = computed(() => {
  return mockArticles.value.filter(item => {
    if (item.type !== activeArticleType.value) return false
    if (item.gameId !== selectedGameId.value) return false
    if (selectedServer.value !== 'ALL' && item.server !== selectedServer.value) return false
    if (selectedCategory.value !== 'ALL' && item.category !== selectedCategory.value) return false
    if (searchKeyword.value.trim()) {
      const q = searchKeyword.value.toLowerCase()
      const matchesTitle = item.title.toLowerCase().includes(q)
      const matchesUser = item.userName.toLowerCase().includes(q)
      const matchesChar = item.characterName.toLowerCase().includes(q)
      if (!matchesTitle && !matchesUser && !matchesChar) return false
    }
    return true
  })
})
</script>
