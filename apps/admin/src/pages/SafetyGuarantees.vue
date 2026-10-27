<template>
  <div class="space-y-6">
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
      <div>
        <h2 class="text-xl font-bold text-white tracking-tight">바로템형 200% 안심보상 심사 센터 (Safety Guarantee)</h2>
        <p class="text-xs text-gray-400 mt-1">
          거래 완료 후 발생한 게임사 압류/회수 사고 접수 건 조사, 4-Eyes 심사 및 피해액의 200% 마일리지 보상 집행.
        </p>
      </div>

      <div class="flex items-center gap-3">
        <span class="px-2.5 py-1 rounded bg-rose-500/10 text-rose-400 border border-rose-500/30 text-xs font-semibold">
          안심보상 기금 잔고: 150,000,000 원
        </span>
      </div>
    </div>

    <!-- KPI Summary -->
    <div class="grid grid-cols-1 sm:grid-cols-4 gap-4">
      <div class="bg-[#151C2F] border border-[#283247] p-4 rounded-xl">
        <div class="text-xs text-gray-400">보상 청구 심사 대기</div>
        <div class="text-xl font-bold text-amber-300 font-mono mt-1">1 건</div>
        <div class="text-[10px] text-gray-500 mt-1">게임사 1:1 문의 접수증 대조 중</div>
      </div>
      <div class="bg-[#151C2F] border border-[#283247] p-4 rounded-xl">
        <div class="text-xs text-gray-400">당월 200% 보상 집행액</div>
        <div class="text-xl font-bold text-rose-400 font-mono mt-1">1,200,000 원</div>
        <div class="text-[10px] text-rose-300 mt-1">피해 유저 2건 전액 보상 완료</div>
      </div>
      <div class="bg-[#151C2F] border border-[#283247] p-4 rounded-xl">
        <div class="text-xs text-gray-400">가해 판매자 구상권 청구</div>
        <div class="text-xl font-bold text-white font-mono mt-1">2 건 (100% 회수)</div>
        <div class="text-[10px] text-emerald-400 mt-1">보증금 몰수 및 법적 대응 완료</div>
      </div>
      <div class="bg-[#151C2F] border border-[#283247] p-4 rounded-xl">
        <div class="text-xs text-gray-400">사고 발생률</div>
        <div class="text-xl font-bold text-emerald-400 font-mono mt-1">0.03%</div>
        <div class="text-[10px] text-gray-400 mt-1">업계 최저 수준 안전 지표</div>
      </div>
    </div>

    <!-- Claims Table -->
    <div class="bg-[#151C2F] border border-[#283247] rounded-xl overflow-hidden shadow-xl">
      <div class="overflow-x-auto">
        <table class="w-full text-left text-xs font-mono">
          <thead class="bg-[#0B1020] border-b border-[#283247] text-gray-400 uppercase tracking-wider font-bold font-sans">
            <tr>
              <th class="p-4">접수번호 / 주문</th>
              <th class="p-4">사고 유형</th>
              <th class="p-4">청구인 (구매자)</th>
              <th class="p-4">원 거래액</th>
              <th class="p-4">200% 보상 요구액</th>
              <th class="p-4">게임사 문의 번호</th>
              <th class="p-4 text-right font-sans">심사 및 보상</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-[#283247] text-gray-300">
            <tr v-for="claim in claims" :key="claim.id" class="hover:bg-[#1E263D]/50 transition">
              <td class="p-4">
                <div class="font-bold text-white">{{ claim.id }}</div>
                <div class="text-[10px] text-indigo-300">{{ claim.orderNumber }}</div>
              </td>
              <td class="p-4 font-sans font-bold text-rose-400">
                {{ claim.claimTypeLabel }}
              </td>
              <td class="p-4 font-sans">
                <div class="font-bold text-white">{{ claim.claimant }}</div>
                <div class="text-[10px] text-gray-500 font-mono">{{ claim.claimantId }}</div>
              </td>
              <td class="p-4 text-gray-300 font-bold">
                {{ claim.damageAmount.toLocaleString() }} 원
              </td>
              <td class="p-4 text-rose-300 font-extrabold text-sm">
                {{ claim.compensationRequested.toLocaleString() }} 원
              </td>
              <td class="p-4 text-cyan-300">
                {{ claim.gameTicketNumber }}
              </td>
              <td class="p-4 text-right space-x-2 font-sans">
                <button
                  @click="openClaimDetails(claim)"
                  class="px-2.5 py-1 rounded bg-[#283247] hover:bg-[#374463] text-white text-[11px]"
                >
                  증빙 감사
                </button>
                <button
                  @click="awardCompensation(claim)"
                  class="px-3 py-1 rounded bg-rose-600 hover:bg-rose-500 text-white text-[11px] font-bold shadow"
                >
                  200% 보상 승인
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <!-- Claim Detail Modal -->
    <div v-if="selectedClaim" class="fixed inset-0 bg-black/70 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <div class="bg-[#151C2F] border border-[#283247] rounded-2xl max-w-xl w-full p-6 space-y-4">
        <div class="flex items-center justify-between border-b border-[#283247] pb-3">
          <div>
            <h3 class="text-base font-bold text-white font-mono">{{ selectedClaim.id }} • 200% 보상 조사서</h3>
            <div class="text-xs text-rose-300">청구 사유: {{ selectedClaim.claimTypeLabel }}</div>
          </div>
          <button @click="selectedClaim = null" class="text-gray-400 hover:text-white">✕</button>
        </div>

        <div class="bg-[#0B1020] p-4 rounded-xl border border-[#283247] text-xs space-y-2">
          <div class="font-bold text-white">게임사 공식 고객센터 회신 내용:</div>
          <div class="text-gray-300 bg-[#151C2F] p-3 rounded-lg border border-[#283247] font-mono text-[11px]">
            "고객님 계정으로 비정상 유입된 카오스 오브 5,000개는 비인가 불법 복제 작업장 유래로 확인되어 회수 조치되었습니다. (문의번호: {{ selectedClaim.gameTicketNumber }})"
          </div>
          <div class="text-emerald-400 text-[10px]">✓ 게임사 공식 답변 진위 확인 완료 (200% 보상 요건 충족)</div>
        </div>

        <div class="pt-3 border-t border-[#283247] flex items-center justify-between">
          <button @click="selectedClaim = null" class="px-4 py-2 rounded-xl bg-[#283247] text-white text-xs font-semibold">
            닫기
          </button>
          <button @click="awardCompensation(selectedClaim)" class="px-5 py-2 rounded-xl bg-rose-600 hover:bg-rose-500 text-white text-xs font-bold shadow-lg">
            200% 보상금 ({{ selectedClaim.compensationRequested.toLocaleString() }}원) 즉시 지급
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

const selectedClaim = ref<any>(null)

const claims = ref([
  {
    id: 'CLM-20261027-01',
    orderNumber: 'TRD-20261025-8812',
    claimTypeLabel: '불법 복제머니 게임사 회수 사고',
    claimant: '피해구매자_01',
    claimantId: 'usr_buyer_1028',
    damageAmount: 60000,
    compensationRequested: 120000,
    gameTicketNumber: 'GGG-TICKET-2026-9921',
  }
])

function openClaimDetails(claim: any) {
  selectedClaim.value = claim
}

function awardCompensation(claim: any) {
  const idx = claims.value.findIndex(c => c.id === claim.id)
  if (idx !== -1) {
    claims.value.splice(idx, 1)
  }
  selectedClaim.value = null
  alert(`사고 청구 ${claim.id} 승인 완료!\n피해자(${claim.claimant})에게 피해액의 200%인 ${claim.compensationRequested.toLocaleString()}원 마일리지가 즉시 보상 지급되었습니다.\n가해 판매자 계정은 영구정지 및 보증금이 몰수되었습니다.`)
}
</script>

