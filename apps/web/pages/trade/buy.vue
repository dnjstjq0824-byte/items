<template>
  <div class="max-w-4xl mx-auto px-4 py-8">
    <!-- Header -->
    <div class="mb-8">
      <div class="flex items-center gap-2 text-xs text-emerald-400 font-semibold mb-1">
        <NuxtLink to="/trade" class="hover:underline">← 거래소 메인</NuxtLink>
        <span class="text-gray-600">•</span>
        <span>구매 의뢰 등록 (삽니다)</span>
      </div>
      <h1 class="text-2xl font-black text-white tracking-tight">삽니다 구매 의뢰 등록</h1>
      <p class="text-xs text-gray-400 mt-1">
        원하는 게임머니나 아이템을 등록해두면, 판매자가 확인하고 즉시 거래를 신청합니다.
      </p>
    </div>

    <!-- Registration Form Card -->
    <form @submit.prevent="submitBuyListing" class="space-y-6">
      <!-- 1. Game & Server -->
      <div class="bg-[#151C2F] border border-[#283247] rounded-2xl p-6 space-y-4">
        <h2 class="text-sm font-bold text-white uppercase tracking-wider flex items-center gap-2">
          <span class="w-5 h-5 rounded-full bg-emerald-600 flex items-center justify-center text-[10px] text-white">1</span>
          구매 희망 게임 및 서버
        </h2>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label class="block text-xs font-semibold text-gray-300 mb-1.5">게임명</label>
            <select
              v-model="form.gameId"
              @change="onGameChange"
              class="w-full bg-[#0B1020] border border-[#283247] rounded-xl px-3.5 py-2.5 text-xs text-white font-semibold focus:outline-none focus:border-emerald-500"
            >
              <option v-for="g in games" :key="g.id" :value="g.id">{{ g.name }}</option>
            </select>
          </div>

          <div>
            <label class="block text-xs font-semibold text-gray-300 mb-1.5">서버명</label>
            <select
              v-model="form.server"
              class="w-full bg-[#0B1020] border border-[#283247] rounded-xl px-3.5 py-2.5 text-xs text-white font-semibold focus:outline-none focus:border-emerald-500"
            >
              <option v-for="s in availableServers" :key="s" :value="s">{{ s }}</option>
            </select>
          </div>

          <div>
            <label class="block text-xs font-semibold text-gray-300 mb-1.5">물품 카테고리</label>
            <select
              v-model="form.category"
              class="w-full bg-[#0B1020] border border-[#283247] rounded-xl px-3.5 py-2.5 text-xs text-white font-semibold focus:outline-none focus:border-emerald-500"
            >
              <option value="GAME_MONEY">게임머니 (골드/메소/다이아 등)</option>
              <option value="GAME_ITEM">일반/고가 아이템</option>
            </select>
          </div>
        </div>
      </div>

      <!-- 2. Quantity & Budget -->
      <div class="bg-[#151C2F] border border-[#283247] rounded-2xl p-6 space-y-4">
        <h2 class="text-sm font-bold text-white uppercase tracking-wider flex items-center gap-2">
          <span class="w-5 h-5 rounded-full bg-emerald-600 flex items-center justify-center text-[10px] text-white">2</span>
          희망 구매 수량 및 예산
        </h2>

        <div>
          <label class="block text-xs font-semibold text-gray-300 mb-1.5">의뢰 제목</label>
          <input
            v-model="form.title"
            type="text"
            placeholder="예: [급구] 카오스 오브 10,000개 삽니다. 접속 즉시 1분 쿨거래"
            class="w-full bg-[#0B1020] border border-[#283247] rounded-xl px-4 py-2.5 text-xs text-white placeholder-gray-500 focus:outline-none focus:border-emerald-500"
            required
          />
        </div>

        <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label class="block text-xs font-semibold text-gray-300 mb-1.5">단위</label>
            <input
              v-model="form.unitName"
              type="text"
              class="w-full bg-[#0B1020] border border-[#283247] rounded-xl px-3.5 py-2.5 text-xs text-white focus:outline-none focus:border-emerald-500"
              required
            />
          </div>

          <div>
            <label class="block text-xs font-semibold text-gray-300 mb-1.5">희망 수량</label>
            <input
              v-model.number="form.quantity"
              type="number"
              min="1"
              class="w-full bg-[#0B1020] border border-[#283247] rounded-xl px-3.5 py-2.5 text-xs text-white font-mono focus:outline-none focus:border-emerald-500"
              required
            />
          </div>

          <div>
            <label class="block text-xs font-semibold text-gray-300 mb-1.5">구매 예산 (원화 KRW)</label>
            <input
              v-model.number="form.budgetPrice"
              type="number"
              min="1000"
              step="500"
              class="w-full bg-[#0B1020] border border-[#283247] rounded-xl px-3.5 py-2.5 text-xs text-white font-mono focus:outline-none focus:border-emerald-500"
              required
            />
          </div>
        </div>
      </div>

      <!-- 3. Character Info -->
      <div class="bg-[#151C2F] border border-[#283247] rounded-2xl p-6 space-y-4">
        <h2 class="text-sm font-bold text-white uppercase tracking-wider flex items-center gap-2">
          <span class="w-5 h-5 rounded-full bg-emerald-600 flex items-center justify-center text-[10px] text-white">3</span>
          인게임 수령 캐릭터명 (필수)
        </h2>

        <div>
          <label class="block text-xs font-semibold text-gray-300 mb-1.5">인게임 수령 캐릭터 닉네임</label>
          <input
            v-model="form.characterName"
            type="text"
            placeholder="인게임에서 물품을 건네받을 본인의 캐릭터명"
            class="w-full bg-[#0B1020] border border-[#283247] rounded-xl px-4 py-2.5 text-xs text-white focus:outline-none focus:border-emerald-500"
            required
          />
        </div>

        <div class="p-4 bg-[#0B1020] rounded-xl border border-[#283247] text-xs text-gray-400">
          💡 판매자가 거래를 수락하면 마일리지 또는 등록 결제수단으로 에스크로 결제가 진행됩니다.
        </div>
      </div>

      <!-- Submit Button -->
      <div class="flex items-center justify-end gap-3 pt-4">
        <NuxtLink to="/trade" class="px-5 py-2.5 rounded-xl bg-[#283247] hover:bg-[#374463] text-gray-300 text-xs font-semibold transition">
          취소
        </NuxtLink>
        <button
          type="submit"
          class="px-8 py-3 rounded-xl bg-gradient-to-r from-emerald-600 to-teal-700 hover:from-emerald-500 hover:to-teal-600 text-white text-sm font-bold shadow-xl shadow-teal-950/50 transition"
        >
          삽니다 등록 완료
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
  quantity: 10000,
  budgetPrice: 110000,
  characterName: '',
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

function submitBuyListing() {
  alert(`구매 의뢰 [${form.value.title}] 등록이 완료되었습니다. 거래소 삽니다 목록에 노출됩니다.`)
  router.push('/trade')
}
</script>
