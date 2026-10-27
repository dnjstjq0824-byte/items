<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
      <div>
        <h2 class="text-xl font-bold text-white tracking-tight">실시간 P2P 거래 중개 관제 센터 (Trade Monitor)</h2>
        <p class="text-xs text-gray-400 mt-1">
          아이템매니아 · 바로템 방식의 실시간 진행 중 주문 모니터링, 장기 정체 건 알림, 관리자 직권 정산 및 취소 중재.
        </p>
      </div>

      <div class="flex items-center gap-3">
        <input
          v-model="searchQuery"
          type="text"
          placeholder="주문번호 또는 캐릭터명 검색..."
          class="bg-[#0B1020] border border-[#283247] rounded-lg px-3 py-1.5 text-xs text-white focus:outline-none focus:border-[#6366F1]"
        />
        <select v-model="statusFilter" class="bg-[#0B1020] border border-[#283247] rounded-lg px-3 py-1.5 text-xs text-gray-300">
          <option value="ALL">전체 상태</option>
          <option value="ESCROW_LOCKED">입금완료 (인계대기)</option>
          <option value="DELIVERY_CLAIMED">전달완료 (인수대기)</option>
          <option value="PAYMENT_PENDING">입금대기</option>
          <option value="DISPUTED">사고/분쟁</option>
        </select>
      </div>
    </div>

    <!-- Active Trades KPI Summary -->
    <div class="grid grid-cols-1 sm:grid-cols-4 gap-4">
      <div class="bg-[#151C2F] border border-[#283247] p-4 rounded-xl">
        <div class="text-xs text-gray-400">진행 중 거래 건수</div>
        <div class="text-xl font-bold text-white font-mono mt-1">42 건</div>
        <div class="text-[10px] text-emerald-400 mt-1">평균 인계 소요시간: 4분 12초</div>
      </div>
      <div class="bg-[#151C2F] border border-[#283247] p-4 rounded-xl">
        <div class="text-xs text-gray-400">에스크로 예치 총액</div>
        <div class="text-xl font-bold text-emerald-400 font-mono mt-1">4,850,000 원</div>
        <div class="text-[10px] text-gray-500 mt-1">안전 금고(Escrow Vault) 보관 중</div>
      </div>
      <div class="bg-[#151C2F] border border-[#283247] p-4 rounded-xl">
        <div class="text-xs text-gray-400">SLA 1시간 초과 지연 건</div>
        <div class="text-xl font-bold text-amber-300 font-mono mt-1">2 건</div>
        <div class="text-[10px] text-amber-400 mt-1">판매자 잠수 알림 발송됨</div>
      </div>
      <div class="bg-[#151C2F] border border-[#283247] p-4 rounded-xl">
        <div class="text-xs text-gray-400">200% 안심보상 가입률</div>
        <div class="text-xl font-bold text-rose-300 font-mono mt-1">94.2%</div>
        <div class="text-[10px] text-gray-500 mt-1">사고 발생 시 200% 보장</div>
      </div>
    </div>

    <!-- Live Trade Monitor Data Table -->
    <div class="bg-[#151C2F] border border-[#283247] rounded-xl overflow-hidden shadow-xl">
      <div class="overflow-x-auto">
        <table class="w-full text-left text-xs">
          <thead class="bg-[#0B1020] border-b border-[#283247] text-gray-400 uppercase tracking-wider font-bold">
            <tr>
              <th class="p-4">주문번호 / 일시</th>
              <th class="p-4">게임 / 서버</th>
              <th class="p-4">거래 캐릭터 (판매자 ⇄ 구매자)</th>
              <th class="p-4">에스크로 결제액</th>
              <th class="p-4">진행 상태</th>
              <th class="p-4">SLA 경과시간</th>
              <th class="p-4 text-right">중재 및 조치</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-[#283247] text-gray-300">
            <tr v-for="order in filteredTrades" :key="order.id" class="hover:bg-[#1E263D]/50 transition">
              <td class="p-4">
                <div class="font-bold text-white font-mono">{{ order.orderNumber }}</div>
                <div class="text-[10px] text-gray-500">{{ order.createdAt }}</div>
              </td>
              <td class="p-4">
                <div class="font-bold text-white">{{ order.game }}</div>
                <div class="text-[11px] text-indigo-300">{{ order.server }}</div>
              </td>
              <td class="p-4 font-mono">
                <div><span class="text-gray-500">판매:</span> <strong class="text-white">{{ order.sellerChar }}</strong></div>
                <div><span class="text-gray-500">구매:</span> <strong class="text-indigo-300">{{ order.buyerChar }}</strong></div>
              </td>
              <td class="p-4 font-mono font-bold text-emerald-400 text-sm">
                {{ order.amount.toLocaleString() }} 원
              </td>
              <td class="p-4">
                <span class="px-2 py-0.5 rounded text-[10px] font-bold border" :class="getStatusBadgeClass(order.status)">
                  {{ order.statusLabel }}
                </span>
              </td>
              <td class="p-4 font-mono">
                <span :class="order.isOverdue ? 'text-amber-400 font-bold' : 'text-gray-400'">
                  {{ order.elapsedTime }}
                </span>
              </td>
              <td class="p-4 text-right space-x-2">
                <button @click="openInspectModal(order)" class="px-2.5 py-1 rounded bg-[#283247] hover:bg-[#374463] text-white text-[11px]">
                  상세 감사
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Modal: Trade Arbitrate & Audit Drawer -->
    <div v-if="selectedTrade" class="fixed inset-0 bg-black/70 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <div class="bg-[#151C2F] border border-[#283247] rounded-2xl max-w-2xl w-full p-6 space-y-4">
        <div class="flex items-center justify-between border-b border-[#283247] pb-3">
          <div>
            <h3 class="text-base font-bold text-white font-mono">{{ selectedTrade.orderNumber }} 거래 감사</h3>
            <div class="text-xs text-gray-400">에스크로 예치금: <strong class="text-emerald-400 font-mono">{{ selectedTrade.amount.toLocaleString() }} 원</strong></div>
          </div>
          <button @click="selectedTrade = null" class="text-gray-400 hover:text-white">✕</button>
        </div>

        <div class="grid grid-cols-2 gap-4 text-xs font-mono">
          <div class="bg-[#0B1020] p-3 rounded-xl border border-[#283247]">
            <div class="text-gray-400 font-sans">인게임 접선 장소</div>
            <div class="text-white mt-1">{{ selectedTrade.meetingLocation }}</div>
          </div>
          <div class="bg-[#0B1020] p-3 rounded-xl border border-[#283247]">
            <div class="text-gray-400 font-sans">SHA-256 증빙 체크섬</div>
            <div class="text-cyan-300 mt-1 truncate" :title="selectedTrade.proofHash">{{ selectedTrade.proofHash || '증빙 미제출' }}</div>
          </div>
        </div>

        <div class="bg-[#0B1020] p-3 rounded-xl border border-[#283247] text-xs space-y-1">
          <div class="font-bold text-white">최근 거래 채팅 로그:</div>
          <div class="text-gray-400 text-[11px]">"판매자: 접선 장소 2채널 웨이포인트 앞 대기 중입니다."</div>
          <div class="text-gray-400 text-[11px]">"구매자: 이동 중입니다. 캐릭터명 워리어마스터_99 입니다."</div>
        </div>

        <!-- Admin Override Actions (직권 완료 / 직권 취소) -->
        <div class="pt-4 border-t border-[#283247] flex items-center justify-between">
          <button class="px-3 py-1.5 rounded bg-[#283247] hover:bg-[#374463] text-white text-xs font-semibold">
            💬 전체 대화록 보기
          </button>

          <div class="flex items-center gap-2">
            <button
              @click="forceCancelOrder(selectedTrade)"
              class="px-3.5 py-1.5 rounded-lg bg-rose-600 hover:bg-rose-500 text-white text-xs font-bold transition"
            >
              직권 취소 & 구매자 환불
            </button>
            <button
              @click="forceCompleteOrder(selectedTrade)"
              class="px-3.5 py-1.5 rounded-lg bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-bold transition"
            >
              직권 완료 & 판매자 송금
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

const searchQuery = ref('')
const statusFilter = ref('ALL')
const selectedTrade = ref<any>(null)

const trades = ref([
  {
    id: 'trd-1',
    orderNumber: 'TRD-20261027-9001',
    createdAt: '2026-10-27 16:30',
    game: '패스 오브 엑자일 2',
    server: '스탠다드 리그',
    sellerChar: '레이클라스트상단장',
    buyerChar: '워리어마스터_99',
    amount: 60000,
    status: 'DELIVERY_CLAIMED',
    statusLabel: '전달완료 (인수대기)',
    elapsedTime: '12분 경과',
    isOverdue: false,
    meetingLocation: '1장 라이온아이 초소 2채널 웨이포인트 앞',
    proofHash: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855'
  },
  {
    id: 'trd-2',
    orderNumber: 'TRD-20261027-8994',
    createdAt: '2026-10-27 15:10',
    game: '리니지 W',
    server: '에바 01',
    sellerChar: '아덴상단마스터',
    buyerChar: '리니지러버_KR',
    amount: 150000,
    status: 'ESCROW_LOCKED',
    statusLabel: '입금완료 (인계지연)',
    elapsedTime: '1시간 20분 경과',
    isOverdue: true,
    meetingLocation: '기란 마을 분수대 앞',
    proofHash: null
  },
  {
    id: 'trd-3',
    orderNumber: 'TRD-20261027-8980',
    createdAt: '2026-10-27 16:45',
    game: '메이플스토리',
    server: '스카니아',
    sellerChar: '단풍잎골드',
    buyerChar: '메이플꿈나무',
    amount: 110000,
    status: 'PAYMENT_PENDING',
    statusLabel: '가상계좌 입금대기',
    elapsedTime: '3분 경과',
    isOverdue: false,
    meetingLocation: '헤네시스 1채널 자유시장 입구',
    proofHash: null
  }
])

const filteredTrades = computed(() => {
  return trades.value.filter(t => {
    const q = searchQuery.value.toLowerCase()
    const matchesSearch = t.orderNumber.toLowerCase().includes(q) ||
                          t.sellerChar.toLowerCase().includes(q) ||
                          t.buyerChar.toLowerCase().includes(q)
    const matchesStatus = statusFilter.value === 'ALL' || t.status === statusFilter.value
    return matchesSearch && matchesStatus
  })
})

function getStatusBadgeClass(status: string) {
  switch (status) {
    case 'DELIVERY_CLAIMED': return 'bg-cyan-500/20 text-cyan-300 border-cyan-500/30'
    case 'ESCROW_LOCKED': return 'bg-amber-500/20 text-amber-300 border-amber-500/30'
    case 'PAYMENT_PENDING': return 'bg-gray-500/20 text-gray-300 border-gray-500/30'
    case 'DISPUTED': return 'bg-rose-500/20 text-rose-300 border-rose-500/30'
    default: return 'bg-indigo-500/20 text-indigo-300 border-indigo-500/30'
  }
}

function openInspectModal(trade: any) {
  selectedTrade.value = trade
}

function forceCompleteOrder(trade: any) {
  trade.status = 'COMPLETED'
  trade.statusLabel = '직권 정산완료'
  selectedTrade.value = null
  alert(`주문 ${trade.orderNumber}이(가) 관리자 권한으로 직권 완료 처리되었습니다. 판매자 마일리지로 대금이 정산되었습니다.`)
}

function forceCancelOrder(trade: any) {
  trade.status = 'CANCELLED'
  trade.statusLabel = '직권 취소환불'
  selectedTrade.value = null
  alert(`주문 ${trade.orderNumber}이(가) 관리자 권한으로 직권 취소되었습니다. 구매자에게 전액 환불되었습니다.`)
}
</script>

