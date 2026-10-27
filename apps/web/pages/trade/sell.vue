<template>
  <div class="max-w-4xl mx-auto px-4 py-8">
    <!-- Header -->
    <div class="mb-8">
      <div class="flex items-center gap-2 text-xs text-indigo-400 font-semibold mb-1">
        <NuxtLink to="/trade" class="hover:underline">← 거래소 메인</NuxtLink>
        <span class="text-gray-600">•</span>
        <span>판매 물품 등록 (팝니다)</span>
      </div>
      <h1 class="text-2xl font-black text-white tracking-tight">팝니다 물품 등록하기</h1>
      <p class="text-xs text-gray-400 mt-1">
        구매자가 안전 에스크로에 입금하면 알림을 받고, 인게임에서 물품을 안전하게 전달하세요.
      </p>
    </div>

    <!-- Registration Form Card -->
    <form @submit.prevent="submitSellListing" class="space-y-6">
      <!-- 1. Game & Server -->
      <div class="bg-[#151C2F] border border-[#283247] rounded-2xl p-6 space-y-4">
        <h2 class="text-sm font-bold text-white uppercase tracking-wider flex items-center gap-2">
          <span class="w-5 h-5 rounded-full bg-indigo-600 flex items-center justify-center text-[10px] text-white">1</span>
          게임 및 서버 정보
        </h2>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label class="block text-xs font-semibold text-gray-300 mb-1.5">게임명</label>
            <select
              v-model="form.gameId"
              @change="onGameChange"
              class="w-full bg-[#0B1020] border border-[#283247] rounded-xl px-3.5 py-2.5 text-xs text-white font-semibold focus:outline-none focus:border-[#6366F1]"
            >
              <option v-for="g in games" :key="g.id" :value="g.id">{{ g.name }}</option>
            </select>
          </div>

          <div>
            <label class="block text-xs font-semibold text-gray-300 mb-1.5">서버명</label>
            <select
              v-model="form.server"
              class="w-full bg-[#0B1020] border border-[#283247] rounded-xl px-3.5 py-2.5 text-xs text-white font-semibold focus:outline-none focus:border-[#6366F1]"
            >
              <option v-for="s in availableServers" :key="s" :value="s">{{ s }}</option>
            </select>
          </div>

          <div>
            <label class="block text-xs font-semibold text-gray-300 mb-1.5">물품 카테고리</label>
            <select
              v-model="form.category"
              class="w-full bg-[#0B1020] border border-[#283247] rounded-xl px-3.5 py-2.5 text-xs text-white font-semibold focus:outline-none focus:border-[#6366F1]"
            >
              <option value="GAME_MONEY">게임머니 (골드/메소/다이아 등)</option>
              <option value="GAME_ITEM">일반/고가 아이템</option>
              <option value="PACKAGE_CODE">공식 패키지 및 바우처</option>
            </select>
          </div>
        </div>
      </div>

      <!-- 2. Listing Details (Title, Quantity, Split Trade) -->
      <div class="bg-[#151C2F] border border-[#283247] rounded-2xl p-6 space-y-4">
        <h2 class="text-sm font-bold text-white uppercase tracking-wider flex items-center gap-2">
          <span class="w-5 h-5 rounded-full bg-indigo-600 flex items-center justify-center text-[10px] text-white">2</span>
          물품 제목 및 수량 설정
        </h2>

        <div>
          <label class="block text-xs font-semibold text-gray-300 mb-1.5">물품 제목</label>
          <input
            v-model="form.title"
            type="text"
            placeholder="구매자들의 시선을 끌 수 있는 명확한 제목을 입력하세요 (예: 5,000 카오스 오브 즉시거래 가능)"
            class="w-full bg-[#0B1020] border border-[#283247] rounded-xl px-4 py-2.5 text-xs text-white placeholder-gray-500 focus:outline-none focus:border-[#6366F1]"
            required
          />
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label class="block text-xs font-semibold text-gray-300 mb-1.5">수량 단위</label>
            <input
              v-model="form.unitName"
              type="text"
              placeholder="예: 골드, 만 메소, 개"
              class="w-full bg-[#0B1020] border border-[#283247] rounded-xl px-3.5 py-2.5 text-xs text-white focus:outline-none focus:border-[#6366F1]"
              required
            />
          </div>

          <div>
            <label class="block text-xs font-semibold text-gray-300 mb-1.5">총 판매 수량</label>
            <input
              v-model.number="form.totalQuantity"
              type="number"
              min="1"
              class="w-full bg-[#0B1020] border border-[#283247] rounded-xl px-3.5 py-2.5 text-xs text-white font-mono focus:outline-none focus:border-[#6366F1]"
              required
            />
          </div>

          <div>
            <label class="block text-xs font-semibold text-gray-300 mb-1.5">분할판매 여부</label>
            <div class="flex items-center gap-4 h-10 px-3 bg-[#0B1020] rounded-xl border border-[#283247]">
              <label class="flex items-center gap-2 text-xs text-gray-300 cursor-pointer">
                <input type="radio" :value="false" v-model="form.isSplitTrade" class="accent-indigo-600" />
                <span>일괄 판매만</span>
              </label>
              <label class="flex items-center gap-2 text-xs text-gray-300 cursor-pointer">
                <input type="radio" :value="true" v-model="form.isSplitTrade" class="accent-indigo-600" />
                <span>분할판매 가능</span>
              </label>
            </div>
          </div>
        </div>

        <div v-if="form.isSplitTrade" class="p-4 bg-[#0B1020] rounded-xl border border-[#283247] grid grid-cols-2 gap-4 text-xs">
          <div>
            <label class="block font-semibold text-gray-400 mb-1">최소 구매 가능 수량</label>
            <input
              v-model.number="form.minQuantity"
              type="number"
              min="1"
              :max="form.totalQuantity"
              class="w-full bg-[#151C2F] border border-[#283247] rounded-lg px-3 py-1.5 text-white font-mono"
            />
          </div>
          <div>
            <label class="block font-semibold text-gray-400 mb-1">최대 구매 가능 수량</label>
            <input
              v-model.number="form.maxQuantity"
              type="number"
              :min="form.minQuantity"
              :max="form.totalQuantity"
              class="w-full bg-[#151C2F] border border-[#283247] rounded-lg px-3 py-1.5 text-white font-mono"
            />
          </div>
        </div>
      </div>

      <!-- 3. Pricing & Settlement Calculation (수수료 5% 투명 계산) -->
      <div class="bg-[#151C2F] border border-[#283247] rounded-2xl p-6 space-y-4">
        <h2 class="text-sm font-bold text-white uppercase tracking-wider flex items-center gap-2">
          <span class="w-5 h-5 rounded-full bg-indigo-600 flex items-center justify-center text-[10px] text-white">3</span>
          판매 가격 및 정산 금액 확인
        </h2>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 items-center">
          <div>
            <label class="block text-xs font-semibold text-gray-300 mb-1.5">총 판매 금액 (원화 KRW)</label>
            <div class="relative">
              <input
                v-model.number="form.totalPrice"
                type="number"
                min="1000"
                step="500"
                class="w-full bg-[#0B1020] border border-[#283247] rounded-xl pl-4 pr-12 py-2.5 text-lg font-mono font-bold text-white focus:outline-none focus:border-[#6366F1]"
                required
              />
              <span class="absolute right-4 top-3 text-xs font-bold text-gray-400">원</span>
            </div>
            <div class="text-[11px] text-gray-500 mt-1">
              단가: 1 {{ form.unitName }}당 약 {{ calculatedUnitPrice }} 원
            </div>
          </div>

          <!-- Settlement Ledger Preview -->
          <div class="bg-[#0B1020] p-4 rounded-xl border border-[#283247] space-y-2 text-xs font-mono">
            <div class="flex justify-between text-gray-400">
              <span>구매자 결제 금액:</span>
              <span class="text-white font-bold">{{ form.totalPrice.toLocaleString() }} 원</span>
            </div>
            <div class="flex justify-between text-gray-400">
              <span>판매 수수료 (5.0%):</span>
              <span class="text-rose-400">-{{ calculatedFee.toLocaleString() }} 원</span>
            </div>
            <div class="pt-2 border-t border-[#283247] flex justify-between text-sm font-bold">
              <span class="text-gray-300 font-sans">예상 실수령 마일리지:</span>
              <span class="text-emerald-400 font-extrabold text-base">{{ calculatedNet.toLocaleString() }} 원</span>
            </div>
          </div>
        </div>
      </div>

      <!-- 4. In-Game Handover Information -->
      <div class="bg-[#151C2F] border border-[#283247] rounded-2xl p-6 space-y-4">
        <h2 class="text-sm font-bold text-white uppercase tracking-wider flex items-center gap-2">
          <span class="w-5 h-5 rounded-full bg-indigo-600 flex items-center justify-center text-[10px] text-white">4</span>
          인게임 거래 접선 정보 (필수)
        </h2>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label class="block text-xs font-semibold text-gray-300 mb-1.5">
              판매자 인게임 캐릭터명 <span class="text-rose-400">*</span>
            </label>
            <input
              v-model="form.characterName"
              type="text"
              placeholder="물품을 전달할 정확한 인게임 닉네임 입력"
              class="w-full bg-[#0B1020] border border-[#283247] rounded-xl px-4 py-2.5 text-xs text-white focus:outline-none focus:border-[#6366F1]"
              required
            />
            <div class="text-[10px] text-amber-400 mt-1">
              ⚠️ 캐릭터명이 다를 경우 사칭 사기로 간주되어 제재될 수 있습니다.
            </div>
          </div>

          <div>
            <label class="block text-xs font-semibold text-gray-300 mb-1.5">지정 접선 장소 / 거래 방식</label>
            <input
              v-model="form.tradeLocation"
              type="text"
              placeholder="예: 1채널 헤네시스 자유시장 앞, 오딘 3구역 창고 앞"
              class="w-full bg-[#0B1020] border border-[#283247] rounded-xl px-4 py-2.5 text-xs text-white focus:outline-none focus:border-[#6366F1]"
              required
            />
          </div>
        </div>

        <!-- Security Extras -->
        <div class="pt-3 border-t border-[#283247] space-y-3">
          <label class="flex items-center gap-3 cursor-pointer">
            <input type="checkbox" v-model="form.useSafetyPhone" class="w-4 h-4 rounded accent-indigo-600" />
            <div>
              <div class="text-xs font-bold text-white">0504 가상 안심번호 무료 사용</div>
              <div class="text-[10px] text-gray-500">실제 휴대폰 번호 대신 가상의 0504 번호로 구매자와 안전하게 통화합니다.</div>
            </div>
          </label>

          <label class="flex items-center gap-3 cursor-pointer">
            <input type="checkbox" v-model="form.has200Guarantee" class="w-4 h-4 rounded accent-rose-600" />
            <div>
              <div class="text-xs font-bold text-rose-300 flex items-center gap-1.5">
                <span>🛡️</span> 바로템형 200% 안심보상 마크 가입 (추천)
              </div>
              <div class="text-[10px] text-gray-400">
                거래 완료 후 회수 등의 사고 발생 시 구매자에게 200% 보상함을 확약하여 구매 전환율을 높입니다.
              </div>
            </div>
          </label>
        </div>
      </div>

      <!-- Agreement & Safety Pledge -->
      <div class="bg-[#0B1020] p-4 rounded-2xl border border-[#283247] space-y-2 text-[11px] text-gray-400">
        <div class="font-bold text-white flex items-center gap-1.5">
          <span>⚖️</span> P2P 거래 안전 준수 서약
        </div>
        <ul class="list-disc list-inside space-y-1 text-gray-400">
          <li>반드시 플랫폼 상에서 <strong class="text-emerald-400">"입금완료"</strong> 상태를 확인한 후에만 인게임 물품을 넘겨야 합니다.</li>
          <li>인게임 귓속말로 거래번호, 아이템매니아, 바로템 등의 단어를 언급하지 마십시오. (게임사 약관 제재 방지)</li>
          <li>전달 완료 후 인게임 교환창 스크린샷(F12)을 증빙으로 업로드해야 빠른 정산이 보장됩니다.</li>
        </ul>
      </div>

      <!-- Submit Button -->
      <div class="flex items-center justify-end gap-3 pt-4">
        <NuxtLink to="/trade" class="px-5 py-2.5 rounded-xl bg-[#283247] hover:bg-[#374463] text-gray-300 text-xs font-semibold transition">
          취소
        </NuxtLink>
        <button
          type="submit"
          class="px-8 py-3 rounded-xl bg-gradient-to-r from-indigo-600 to-indigo-700 hover:from-indigo-500 hover:to-indigo-600 text-white text-sm font-bold shadow-xl shadow-indigo-950/50 transition"
        >
          팝니다 등록 완료
        </button>
      </div>
    </form>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { useRouter } from 'vue-router'

const router = useRouter()

const games = [
  { id: 'poe2', name: '패스 오브 엑자일 2 (PoE 2)', servers: ['스탠다드 리그', '하드코어 리그'] },
  { id: 'lineagew', name: '리니지 W (Lineage W)', servers: ['에바 01', '에바 02', '아덴 01', '기란 01'] },
  { id: 'odin', name: '오딘: 발할라 라이징', servers: ['오딘 01', '토르 03', '로키 02'] },
  { id: 'maple', name: '메이플스토리', servers: ['스카니아', '루나', '엘리시움', '크로아'] },
  { id: 'ff14', name: '파이널 판타지 14', servers: ['초코보 (마나)', '모그리 (가이아)', '카벙클 (엘레)'] },
]

const form = ref({
  gameId: 'poe2',
  server: '스탠다드 리그',
  category: 'GAME_MONEY',
  title: '',
  unitName: '카오스 오브',
  totalQuantity: 5000,
  isSplitTrade: false,
  minQuantity: 1000,
  maxQuantity: 5000,
  totalPrice: 50000,
  characterName: '',
  tradeLocation: '1장 라이온아이 초소 웨이포인트 앞',
  useSafetyPhone: true,
  has200Guarantee: true,
})

const availableServers = computed(() => {
  const g = games.find(item => item.id === form.value.gameId)
  return g ? g.servers : []
})

function onGameChange() {
  const g = games.find(item => item.id === form.value.gameId)
  if (g && g.servers.length > 0) {
    form.value.server = g.servers[0]
  }
}

const calculatedFee = computed(() => {
  return Math.floor(form.value.totalPrice * 0.05)
})

const calculatedNet = computed(() => {
  return form.value.totalPrice - calculatedFee.value
})

const calculatedUnitPrice = computed(() => {
  if (form.value.totalQuantity <= 0) return 0
  return (form.value.totalPrice / form.value.totalQuantity).toFixed(2)
})

function submitSellListing() {
  alert(`물품 [${form.value.title}] 등록이 완료되었습니다. 거래소 팝니다 목록에 즉시 노출됩니다.`)
  router.push('/trade')
}
</script>
