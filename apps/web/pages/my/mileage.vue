<template>
  <div class="max-w-5xl mx-auto px-4 py-8">
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-8">
      <div>
        <div class="flex items-center gap-2 text-xs text-indigo-400 font-semibold mb-1">
          <NuxtLink to="/trade" class="hover:underline">← 거래소 메인</NuxtLink>
          <span>•</span>
          <span>마이페이지</span>
        </div>
        <h1 class="text-2xl font-black text-white tracking-tight">마일리지 지갑 & 24시간 실시간 출금</h1>
        <p class="text-xs text-gray-400 mt-1">
          아이템 판매 정산 대금 보관, 충전 및 본인 명의 은행 계좌로의 365일 24시간 실시간 즉시 출금을 지원합니다.
        </p>
      </div>

      <div class="flex items-center gap-3">
        <button
          @click="showChargeModal = true"
          class="px-5 py-2.5 rounded-xl bg-gradient-to-r from-indigo-600 to-indigo-700 hover:from-indigo-500 hover:to-indigo-600 text-white font-bold text-xs shadow-lg transition flex items-center gap-1.5"
        >
          <span>💳</span> 마일리지 충전
        </button>
        <button
          @click="showWithdrawModal = true"
          class="px-5 py-2.5 rounded-xl bg-gradient-to-r from-emerald-600 to-teal-700 hover:from-emerald-500 hover:to-teal-600 text-white font-bold text-xs shadow-lg transition flex items-center gap-1.5"
        >
          <span>🏦</span> 실시간 출금신청
        </button>
      </div>
    </div>

    <!-- Balance Status KPI Cards -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 mb-8">
      <div class="bg-[#151C2F] border border-[#283247] rounded-2xl p-5 shadow-lg">
        <div class="text-xs font-semibold text-gray-400">총 보유 마일리지</div>
        <div class="text-2xl font-extrabold text-white font-mono mt-1">
          {{ wallet.totalBalance.toLocaleString() }} <span class="text-xs text-gray-400 font-normal">원</span>
        </div>
        <div class="text-[10px] text-gray-500 mt-2">1 마일리지 = 현금 1원의 가치</div>
      </div>

      <div class="bg-[#151C2F] border-2 border-emerald-500/40 rounded-2xl p-5 shadow-lg relative">
        <div class="text-xs font-semibold text-emerald-400">출금 가능 마일리지</div>
        <div class="text-2xl font-extrabold text-emerald-400 font-mono mt-1">
          {{ wallet.withdrawableBalance.toLocaleString() }} <span class="text-xs text-gray-400 font-normal">원</span>
        </div>
        <div class="text-[10px] text-emerald-400/80 mt-2">✓ 24시간 실시간 계좌이체 가능</div>
      </div>

      <div class="bg-[#151C2F] border border-[#283247] rounded-2xl p-5 shadow-lg">
        <div class="text-xs font-semibold text-amber-300">거래 중 예치 마일리지</div>
        <div class="text-2xl font-extrabold text-amber-300 font-mono mt-1">
          {{ wallet.escrowLocked.toLocaleString() }} <span class="text-xs text-gray-400 font-normal">원</span>
        </div>
        <div class="text-[10px] text-amber-400/80 mt-2">안전 에스크로 보호 중인 주문 2건</div>
      </div>

      <div class="bg-[#151C2F] border border-[#283247] rounded-2xl p-5 shadow-lg">
        <div class="text-xs font-semibold text-indigo-300">거래 보증금 (Deposit)</div>
        <div class="text-2xl font-extrabold text-indigo-300 font-mono mt-1">
          {{ wallet.depositPledge.toLocaleString() }} <span class="text-xs text-gray-400 font-normal">원</span>
        </div>
        <div class="text-[10px] text-gray-500 mt-2">200% 안심보상 셀러 보증 예치금</div>
      </div>
    </div>

    <!-- Transaction History Table -->
    <div class="bg-[#151C2F] border border-[#283247] rounded-2xl overflow-hidden shadow-2xl">
      <div class="p-5 border-b border-[#283247] flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <h2 class="text-sm font-bold text-white uppercase tracking-wider">마일리지 입출금 및 정산 원장</h2>
        <div class="flex items-center gap-2 text-xs font-semibold">
          <button
            v-for="f in ['ALL', 'CHARGE', 'SETTLEMENT', 'WITHDRAWAL']"
            :key="f"
            @click="filterType = f"
            class="px-3 py-1.5 rounded-lg transition"
            :class="filterType === f ? 'bg-[#6366F1] text-white' : 'bg-[#0B1020] text-gray-400 hover:text-white'"
          >
            <span v-if="f === 'ALL'">전체 내역</span>
            <span v-else-if="f === 'CHARGE'">충전</span>
            <span v-else-if="f === 'SETTLEMENT'">정산/환불</span>
            <span v-else>출금</span>
          </button>
        </div>
      </div>

      <div class="overflow-x-auto">
        <table class="w-full text-left text-xs font-mono">
          <thead class="bg-[#0B1020] text-gray-400 uppercase tracking-wider font-semibold font-sans">
            <tr>
              <th class="p-4">거래일시</th>
              <th class="p-4">구분</th>
              <th class="p-4">상세 적요</th>
              <th class="p-4">변동 금액</th>
              <th class="p-4">거래 후 잔액</th>
              <th class="p-4 text-right">상태</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-[#283247] text-gray-300">
            <tr v-for="tx in filteredTransactions" :key="tx.id" class="hover:bg-[#1E263D]/50 transition">
              <td class="p-4 text-gray-400 font-sans text-[11px]">{{ tx.timestamp }}</td>
              <td class="p-4 font-sans">
                <span class="px-2 py-0.5 rounded text-[10px] font-bold border" :class="getTxBadgeClass(tx.type)">
                  {{ tx.typeLabel }}
                </span>
              </td>
              <td class="p-4 font-sans font-medium text-white">{{ tx.description }}</td>
              <td class="p-4 font-bold text-sm" :class="tx.amount > 0 ? 'text-emerald-400' : 'text-rose-400'">
                {{ tx.amount > 0 ? '+' : '' }}{{ tx.amount.toLocaleString() }} 원
              </td>
              <td class="p-4 text-gray-300">{{ tx.balanceAfter.toLocaleString() }} 원</td>
              <td class="p-4 text-right font-sans">
                <span class="px-2 py-0.5 rounded bg-emerald-500/10 text-emerald-400 border border-emerald-500/30 text-[10px] font-semibold">
                  정상 처리
                </span>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Modal: 마일리지 충전 -->
    <div v-if="showChargeModal" class="fixed inset-0 bg-black/70 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <div class="bg-[#151C2F] border border-[#283247] rounded-2xl max-w-md w-full p-6 space-y-4">
        <h3 class="text-base font-bold text-white">마일리지 즉시 충전</h3>
        <p class="text-xs text-gray-300">
          충전된 마일리지는 즉시 게임 아이템 및 게임머니 구매 에스크로 결제에 사용하실 수 있습니다.
        </p>

        <div>
          <label class="block text-xs font-semibold text-gray-300 mb-1.5">충전 금액</label>
          <div class="grid grid-cols-3 gap-2 mb-2 text-xs font-mono">
            <button
              v-for="amt in [10000, 30000, 50000, 100000, 300000, 500000]"
              :key="amt"
              @click="chargeAmount = amt"
              class="py-2 rounded-xl border transition"
              :class="chargeAmount === amt ? 'bg-indigo-600 text-white border-indigo-500' : 'bg-[#0B1020] text-gray-300 border-[#283247]'"
            >
              {{ amt.toLocaleString() }}원
            </button>
          </div>
          <input
            v-model.number="chargeAmount"
            type="number"
            min="1000"
            step="1000"
            class="w-full bg-[#0B1020] border border-[#283247] rounded-xl px-4 py-2.5 text-xs text-white font-mono focus:outline-none focus:border-[#6366F1]"
          />
        </div>

        <div>
          <label class="block text-xs font-semibold text-gray-300 mb-1.5">결제 수단</label>
          <select class="w-full bg-[#0B1020] border border-[#283247] rounded-xl px-3.5 py-2.5 text-xs text-white">
            <option>가상계좌 무통장입금 (입금 즉시 자동 충전)</option>
            <option>신용/체크카드 결제 (토스페이먼츠/KCP)</option>
            <option>카카오페이 / 네이버페이 간편결제</option>
            <option>휴대폰 소액결제</option>
          </select>
        </div>

        <div class="flex items-center justify-end gap-3 pt-3">
          <button @click="showChargeModal = false" class="px-4 py-2 rounded-xl bg-[#283247] text-white text-xs font-semibold">
            취소
          </button>
          <button @click="executeCharge" class="px-5 py-2 rounded-xl bg-indigo-600 hover:bg-indigo-500 text-white text-xs font-bold">
            {{ chargeAmount.toLocaleString() }}원 충전하기
          </button>
        </div>
      </div>
    </div>

    <!-- Modal: 24시간 실시간 은행 출금신청 (BaroTem style) -->
    <div v-if="showWithdrawModal" class="fixed inset-0 bg-black/70 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <div class="bg-[#151C2F] border border-[#283247] rounded-2xl max-w-md w-full p-6 space-y-4">
        <h3 class="text-base font-bold text-white">24시간 실시간 은행 계좌 출금</h3>
        <p class="text-xs text-gray-300">
          출금 가능 잔액: <strong class="text-emerald-400 font-mono text-sm">{{ wallet.withdrawableBalance.toLocaleString() }} 원</strong>
        </p>

        <div class="space-y-3">
          <div>
            <label class="block text-xs font-semibold text-gray-300 mb-1">입금 은행</label>
            <select v-model="withdrawForm.bank" class="w-full bg-[#0B1020] border border-[#283247] rounded-xl px-3.5 py-2 text-xs text-white">
              <option>국민은행</option>
              <option>신한은행</option>
              <option>우리은행</option>
              <option>하나은행</option>
              <option>카카오뱅크</option>
              <option>토스뱅크</option>
              <option>농협은행</option>
              <option>기업은행</option>
            </select>
          </div>

          <div>
            <label class="block text-xs font-semibold text-gray-300 mb-1">계좌번호 (본인 명의)</label>
            <input
              v-model="withdrawForm.account"
              type="text"
              placeholder="- 없이 숫자만 입력"
              class="w-full bg-[#0B1020] border border-[#283247] rounded-xl px-3.5 py-2 text-xs text-white font-mono"
            />
          </div>

          <div>
            <label class="block text-xs font-semibold text-gray-300 mb-1">예금주명</label>
            <input
              v-model="withdrawForm.holder"
              type="text"
              class="w-full bg-[#0B1020] border border-[#283247] rounded-xl px-3.5 py-2 text-xs text-white"
            />
          </div>

          <div>
            <label class="block text-xs font-semibold text-gray-300 mb-1">출금 신청 금액</label>
            <input
              v-model.number="withdrawForm.amount"
              type="number"
              min="10000"
              step="10000"
              :max="wallet.withdrawableBalance"
              class="w-full bg-[#0B1020] border border-[#283247] rounded-xl px-3.5 py-2 text-sm text-white font-mono font-bold"
            />
          </div>

          <!-- Fee Calculation -->
          <div class="p-3 bg-[#0B1020] rounded-xl border border-[#283247] text-xs font-mono space-y-1">
            <div class="flex justify-between text-gray-400">
              <span>이체 수수료:</span>
              <span class="text-rose-400">-1,000 원</span>
            </div>
            <div class="flex justify-between font-bold text-white pt-1 border-t border-[#283247]">
              <span>실제 입금 예정액:</span>
              <span class="text-emerald-400">{{ Math.max(0, withdrawForm.amount - 1000).toLocaleString() }} 원</span>
            </div>
          </div>
        </div>

        <div class="text-[10px] text-gray-500 leading-relaxed">
          * 365일 24시간 실시간 펌뱅킹 망으로 3분 이내 본인 계좌로 자동 입금됩니다.
        </div>

        <div class="flex items-center justify-end gap-3 pt-2">
          <button @click="showWithdrawModal = false" class="px-4 py-2 rounded-xl bg-[#283247] text-white text-xs font-semibold">
            취소
          </button>
          <button @click="executeWithdrawal" class="px-5 py-2 rounded-xl bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-bold">
            실시간 출금 신청
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

const showChargeModal = ref(false)
const showWithdrawModal = ref(false)
const chargeAmount = ref(50000)
const filterType = ref('ALL')

const wallet = ref({
  totalBalance: 1450000,
  withdrawableBalance: 1210000,
  escrowLocked: 140000,
  depositPledge: 100000,
})

const withdrawForm = ref({
  bank: '카카오뱅크',
  account: '3333-01-9284102',
  holder: '홍길동 (본인인증 완료)',
  amount: 200000,
})

const transactions = ref([
  {
    id: 'tx-001',
    timestamp: '2026-10-27 16:42:10',
    type: 'SETTLEMENT',
    typeLabel: '판매 정산',
    description: 'TRD-20261027-9001 물품 인수확인 정산 입금 (5,000 카오스 오브)',
    amount: 57000,
    balanceAfter: 1450000,
  },
  {
    id: 'tx-002',
    timestamp: '2026-10-27 14:10:05',
    type: 'CHARGE',
    typeLabel: '가상계좌 충전',
    description: '케이뱅크 가상계좌 마일리지 충전 완료',
    amount: 100000,
    balanceAfter: 1393000,
  },
  {
    id: 'tx-003',
    timestamp: '2026-10-26 21:05:44',
    type: 'WITHDRAWAL',
    typeLabel: '계좌 출금',
    description: '카카오뱅크 3333-01-••• 실시간 펌뱅킹 이체 완료',
    amount: -301000,
    balanceAfter: 1293000,
  },
  {
    id: 'tx-004',
    timestamp: '2026-10-25 18:30:12',
    type: 'SETTLEMENT',
    typeLabel: '판매 정산',
    description: 'TRD-20261025-8812 디바인 오브 20개 판매 정산 대금 입금',
    amount: 34200,
    balanceAfter: 1594000,
  }
])

const filteredTransactions = computed(() => {
  if (filterType.value === 'ALL') return transactions.value
  return transactions.value.filter(t => t.type === filterType.value)
})

function getTxBadgeClass(type: string) {
  switch (type) {
    case 'CHARGE': return 'bg-indigo-500/20 text-indigo-300 border-indigo-500/30'
    case 'SETTLEMENT': return 'bg-emerald-500/20 text-emerald-300 border-emerald-500/30'
    case 'WITHDRAWAL': return 'bg-rose-500/20 text-rose-300 border-rose-500/30'
    default: return 'bg-gray-500/20 text-gray-300 border-gray-500/30'
  }
}

function executeCharge() {
  wallet.value.totalBalance += chargeAmount.value
  wallet.value.withdrawableBalance += chargeAmount.value
  transactions.value.unshift({
    id: `tx-${Date.now()}`,
    timestamp: new Date().toLocaleString(),
    type: 'CHARGE',
    typeLabel: '마일리지 충전',
    description: '가상계좌 마일리지 즉시 충전 완료',
    amount: chargeAmount.value,
    balanceAfter: wallet.value.totalBalance,
  })
  showChargeModal.value = false
  alert(`${chargeAmount.value.toLocaleString()}원 마일리지가 즉시 충전되었습니다!`)
}

function executeWithdrawal() {
  if (withdrawForm.value.amount > wallet.value.withdrawableBalance) {
    alert('출금 가능 잔액을 초과할 수 없습니다.')
    return
  }
  wallet.value.totalBalance -= withdrawForm.value.amount
  wallet.value.withdrawableBalance -= withdrawForm.value.amount
  transactions.value.unshift({
    id: `tx-${Date.now()}`,
    timestamp: new Date().toLocaleString(),
    type: 'WITHDRAWAL',
    typeLabel: '계좌 출금',
    description: `${withdrawForm.value.bank} 실시간 이체 완료 (${withdrawForm.value.holder})`,
    amount: -withdrawForm.value.amount,
    balanceAfter: wallet.value.totalBalance,
  })
  showWithdrawModal.value = false
  alert(`${withdrawForm.value.bank} 계좌로 ${(withdrawForm.value.amount - 1000).toLocaleString()}원이 3분 이내로 이체됩니다!`)
}
</script>

