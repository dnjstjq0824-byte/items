<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
      <div>
        <h2 class="text-xl font-bold text-white tracking-tight">24시간 실시간 마일리지 출금 심사 센터</h2>
        <p class="text-xs text-gray-400 mt-1">
          판매자의 원화(KRW) 은행 계좌 실시간 펌뱅킹 이체 심사, 이상금융거래(FDS) 이상징후 감지 및 즉시 승인/반려.
        </p>
      </div>

      <div class="flex items-center gap-3">
        <button
          @click="batchApproveLowRisk"
          class="px-3.5 py-1.5 rounded-lg bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-bold transition flex items-center gap-1.5"
        >
          <span>⚡</span> 안전 건(FDS&lt;20) 일괄 자동이체 승인
        </button>
      </div>
    </div>

    <!-- KPI Summary Cards -->
    <div class="grid grid-cols-1 sm:grid-cols-4 gap-4">
      <div class="bg-[#151C2F] border border-[#283247] p-4 rounded-xl">
        <div class="text-xs text-gray-400">출금 심사 대기</div>
        <div class="text-xl font-bold text-amber-300 font-mono mt-1">4 건</div>
        <div class="text-[10px] text-gray-500 mt-1">총 대기액: 1,480,000 원</div>
      </div>
      <div class="bg-[#151C2F] border border-[#283247] p-4 rounded-xl">
        <div class="text-xs text-gray-400">금일 이체 완료액 (24h)</div>
        <div class="text-xl font-bold text-emerald-400 font-mono mt-1">18,450,000 원</div>
        <div class="text-[10px] text-emerald-400 mt-1">100% 펌뱅킹 망 실시간 정산</div>
      </div>
      <div class="bg-[#151C2F] border border-[#283247] p-4 rounded-xl">
        <div class="text-xs text-gray-400">FDS 고위험 차단 건</div>
        <div class="text-xl font-bold text-rose-400 font-mono mt-1">1 건</div>
        <div class="text-[10px] text-rose-400 mt-1">사기계좌 의심 블랙리스트 매칭</div>
      </div>
      <div class="bg-[#151C2F] border border-[#283247] p-4 rounded-xl">
        <div class="text-xs text-gray-400">평균 이체 소요시간</div>
        <div class="text-xl font-bold text-white font-mono mt-1">1분 40초</div>
        <div class="text-[10px] text-indigo-300 mt-1">자동 승인율: 96.8%</div>
      </div>
    </div>

    <!-- Withdrawal Table -->
    <div class="bg-[#151C2F] border border-[#283247] rounded-xl overflow-hidden shadow-xl">
      <div class="overflow-x-auto">
        <table class="w-full text-left text-xs font-mono">
          <thead class="bg-[#0B1020] border-b border-[#283247] text-gray-400 uppercase tracking-wider font-bold font-sans">
            <tr>
              <th class="p-4">접수번호 / 일시</th>
              <th class="p-4">신청 회원</th>
              <th class="p-4">입금 은행 및 계좌</th>
              <th class="p-4">신청액 / 수수료</th>
              <th class="p-4">실수령액</th>
              <th class="p-4">FDS 위험도</th>
              <th class="p-4 text-right font-sans">심사 및 이체</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-[#283247] text-gray-300">
            <tr v-for="req in requests" :key="req.id" class="hover:bg-[#1E263D]/50 transition">
              <td class="p-4">
                <div class="font-bold text-white">{{ req.id }}</div>
                <div class="text-[10px] text-gray-500 font-sans">{{ req.createdAt }}</div>
              </td>
              <td class="p-4 font-sans">
                <div class="font-bold text-white">{{ req.userName }}</div>
                <div class="text-[10px] text-gray-500 font-mono">{{ req.userId }}</div>
              </td>
              <td class="p-4">
                <div class="font-bold text-indigo-300 font-sans">{{ req.bankName }}</div>
                <div class="text-[11px] text-gray-400">{{ req.accountNumber }}</div>
                <div class="text-[10px] text-emerald-400 font-sans">예금주: {{ req.holderName }} (일치)</div>
              </td>
              <td class="p-4 font-bold text-white">
                <div>{{ req.amount.toLocaleString() }} 원</div>
                <div class="text-[10px] text-rose-400">-{{ req.fee.toLocaleString() }} 원</div>
              </td>
              <td class="p-4 font-bold text-emerald-400 text-sm">
                {{ req.netAmount.toLocaleString() }} 원
              </td>
              <td class="p-4 font-sans">
                <span
                  class="px-2 py-0.5 rounded text-[10px] font-bold border"
                  :class="req.riskScore >= 70 ? 'bg-rose-500/20 text-rose-300 border-rose-500/40' : req.riskScore >= 30 ? 'bg-amber-500/20 text-amber-300 border-amber-500/30' : 'bg-emerald-500/10 text-emerald-400 border-emerald-500/30'"
                >
                  {{ req.riskScore }}점 ({{ req.riskLabel }})
                </span>
              </td>
              <td class="p-4 text-right space-x-2 font-sans">
                <button
                  @click="rejectWithdrawal(req)"
                  class="px-2.5 py-1 rounded bg-rose-500/10 hover:bg-rose-500/20 text-rose-300 border border-rose-500/30 text-[11px] font-semibold"
                >
                  반려
                </button>
                <button
                  @click="approveWithdrawal(req)"
                  class="px-3 py-1 rounded bg-emerald-600 hover:bg-emerald-500 text-white text-[11px] font-bold shadow"
                >
                  이체 승인
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const requests = ref([
  {
    id: 'WDR-20261027-1048',
    createdAt: '2026-10-27 16:50:12',
    userName: '엑자일전문상단',
    userId: 'usr_8921a8f2-1092',
    bankName: '카카오뱅크',
    accountNumber: '3333-01-•••••••',
    holderName: '홍길동',
    amount: 500000,
    fee: 1000,
    netAmount: 499000,
    riskScore: 4,
    riskLabel: '정상',
  },
  {
    id: 'WDR-20261027-1047',
    createdAt: '2026-10-27 16:48:30',
    userName: '아덴보부상',
    userId: 'usr_3914b102-4412',
    bankName: '신한은행',
    accountNumber: '110-384-••••••',
    holderName: '이아덴',
    amount: 800000,
    fee: 1000,
    netAmount: 799000,
    riskScore: 8,
    riskLabel: '정상',
  },
  {
    id: 'WDR-20261027-1046',
    createdAt: '2026-10-27 16:32:05',
    userName: '신규판매자99',
    userId: 'usr_771928ba-9912',
    bankName: '국민은행',
    accountNumber: '482102-••••••',
    holderName: '김철수',
    amount: 180000,
    fee: 1000,
    netAmount: 179000,
    riskScore: 84,
    riskLabel: '고위험 (신규회원 급증출금)',
  }
])

function approveWithdrawal(req: any) {
  const idx = requests.value.findIndex(r => r.id === req.id)
  if (idx !== -1) {
    requests.value.splice(idx, 1)
  }
  alert(`출금 요청 ${req.id} (${req.netAmount.toLocaleString()}원)의 실시간 펌뱅킹 이체가 성공적으로 실행되었습니다.`)
}

function rejectWithdrawal(req: any) {
  const reason = prompt('출금 반려 사유를 입력하세요 (마일리지가 유저 계정으로 복구됩니다):', '계좌 예금주명 불일치')
  if (reason) {
    const idx = requests.value.findIndex(r => r.id === req.id)
    if (idx !== -1) {
      requests.value.splice(idx, 1)
    }
    alert(`출금 요청 ${req.id}이(가) 반려되었습니다. 사유: [${reason}]. ${req.amount.toLocaleString()}원 마일리지가 복구되었습니다.`)
  }
}

function batchApproveLowRisk() {
  const lowRisk = requests.value.filter(r => r.riskScore < 20)
  const count = lowRisk.length
  requests.value = requests.value.filter(r => r.riskScore >= 20)
  alert(`FDS 정상 건 총 ${count}건의 실시간 펌뱅킹 이체가 일괄 승인 완료되었습니다.`)
}
</script>
