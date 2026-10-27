<template>
  <div class="min-h-screen flex bg-[#0B1020] text-[#F8FAFC]">
    <!-- Admin Sidebar (Article 27.1 & BaroTem/ItemMania Operations) -->
    <aside class="w-64 bg-[#151C2F] border-r border-[#283247] flex flex-col justify-between shrink-0">
      <div>
        <div class="h-16 px-6 border-b border-[#283247] flex items-center justify-between">
          <div class="flex items-center gap-2">
            <span class="w-7 h-7 rounded bg-[#6366F1] flex items-center justify-center font-black text-xs text-white">BN</span>
            <span class="font-extrabold text-sm tracking-wider">GAMEEX ADMIN</span>
          </div>
          <span class="text-[10px] px-1.5 py-0.5 rounded bg-emerald-500/20 text-emerald-300 border border-emerald-500/30 font-mono">LIVE ESCROW</span>
        </div>

        <nav class="p-4 space-y-1 text-xs font-medium">
          <router-link to="/" class="flex items-center gap-3 px-3 py-2 rounded-lg text-gray-300 hover:text-white hover:bg-[#283247]/50" active-class="bg-[#6366F1] text-white">
            <span>📊 대시보드 (Overview)</span>
          </router-link>

          <div class="pt-2 pb-1 px-3 text-[10px] font-bold text-gray-500 uppercase tracking-wider">아이템 거래 실시간 관제</div>
          <router-link to="/trade-monitor" class="flex items-center gap-3 px-3 py-2 rounded-lg text-gray-300 hover:text-white hover:bg-[#283247]/50" active-class="bg-[#6366F1] text-white">
            <span>⚡ 실시간 거래 관제 (Monitor)</span>
          </router-link>
          <router-link to="/withdrawals" class="flex items-center gap-3 px-3 py-2 rounded-lg text-gray-300 hover:text-white hover:bg-[#283247]/50" active-class="bg-[#6366F1] text-white">
            <span>🏦 24시간 출금 심사 (Payout)</span>
          </router-link>
          <router-link to="/safety-guarantees" class="flex items-center gap-3 px-3 py-2 rounded-lg text-gray-300 hover:text-white hover:bg-[#283247]/50" active-class="bg-[#6366F1] text-white">
            <span>🛡️ 200% 안심보상 심사 (Safety)</span>
          </router-link>

          <div class="pt-2 pb-1 px-3 text-[10px] font-bold text-gray-500 uppercase tracking-wider">플랫폼 거버넌스 & 재무</div>
          <router-link to="/orders" class="flex items-center gap-3 px-3 py-2 rounded-lg text-gray-300 hover:text-white hover:bg-[#283247]/50" active-class="bg-[#6366F1] text-white">
            <span>📦 마스터 주문 원장 (Orders)</span>
          </router-link>
          <router-link to="/policies" class="flex items-center gap-3 px-3 py-2 rounded-lg text-gray-300 hover:text-white hover:bg-[#283247]/50" active-class="bg-[#6366F1] text-white">
            <span>🌐 게임별 거래 정책 (Policies)</span>
          </router-link>
          <router-link to="/sellers" class="flex items-center gap-3 px-3 py-2 rounded-lg text-gray-300 hover:text-white hover:bg-[#283247]/50" active-class="bg-[#6366F1] text-white">
            <span>👤 판매자 KYC 관리 (Sellers)</span>
          </router-link>
          <router-link to="/disputes" class="flex items-center gap-3 px-3 py-2 rounded-lg text-gray-300 hover:text-white hover:bg-[#283247]/50" active-class="bg-[#6366F1] text-white">
            <span>⚖️ 분쟁 조정 4-Eyes (Disputes)</span>
          </router-link>
          <router-link to="/reconciliation" class="flex items-center gap-3 px-3 py-2 rounded-lg text-gray-300 hover:text-white hover:bg-[#283247]/50" active-class="bg-[#6366F1] text-white">
            <span>📑 복식부기 원장 대사 (Ledger)</span>
          </router-link>
          <router-link to="/payments" class="flex items-center gap-3 px-3 py-2 rounded-lg text-gray-300 hover:text-white hover:bg-[#283247]/50" active-class="bg-[#6366F1] text-white">
            <span>💳 결제 웹훅 게이트웨이</span>
          </router-link>
          <router-link to="/risk" class="flex items-center gap-3 px-3 py-2 rounded-lg text-gray-300 hover:text-white hover:bg-[#283247]/50" active-class="bg-[#6366F1] text-white">
            <span>🚨 FDS 사기방지 센터</span>
          </router-link>
          <router-link to="/audit-logs" class="flex items-center gap-3 px-3 py-2 rounded-lg text-gray-300 hover:text-white hover:bg-[#283247]/50" active-class="bg-[#6366F1] text-white">
            <span>📝 불변 감사 로그 (Audit Logs)</span>
          </router-link>
        </nav>
      </div>

      <div class="p-4 border-t border-[#283247] text-xs text-gray-400">
        <div class="font-semibold text-white">SuperOpsAdmin</div>
        <div>Role: SUPER_ADMIN</div>
        <div class="mt-2 text-[10px] text-emerald-400">에스크로 자금 보관: 정상 가동</div>
      </div>
    </aside>

    <!-- Main Content Area -->
    <div class="flex-1 flex flex-col min-w-0">
      <header class="h-16 bg-[#151C2F]/50 backdrop-blur border-b border-[#283247] px-8 flex items-center justify-between shrink-0">
        <h1 class="text-base font-bold text-white tracking-wide">{{ currentRouteName }}</h1>
        <div class="flex items-center gap-4 text-xs">
          <span class="px-2 py-1 rounded bg-emerald-500/10 text-emerald-400 border border-emerald-500/30">System Normal</span>
          <span class="text-gray-400 font-mono">2026-10-27 KST</span>
        </div>
      </header>

      <main class="flex-1 p-8 overflow-y-auto">
        <router-view />
      </main>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()
const currentRouteName = computed(() => {
  switch (route.path) {
    case '/': return '운영 현황 대시보드'
    case '/trade-monitor': return '실시간 P2P 거래 중개 관제 센터'
    case '/withdrawals': return '24시간 실시간 마일리지 출금 심사'
    case '/safety-guarantees': return '바로템형 200% 안심보상 심사 센터'
    case '/orders': return '마스터 주문 원장 및 라이프사이클 감사'
    case '/policies': return '글로벌 게임 거래 정책 게이팅 (Article 3)'
    case '/sellers': return '판매자 KYC 자격 심사 및 제재 관리'
    case '/disputes': return '분쟁 조정 & 4-Eyes 이중 승인 센터'
    case '/reconciliation': return '복식부기 재무 원장 대사 (Reconciliation)'
    case '/payments': return '결제 레일 및 인바운드 웹훅 게이트웨이'
    case '/risk': return 'FDS 이상거래 탐지 및 외부 유출 차단 센터'
    case '/audit-logs': return '불변 규정 감사 로그 (Audit Logs)'
    default: return '관리자 운영 콘솔'
  }
})
</script>
