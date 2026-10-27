<template>
  <div class="max-w-6xl mx-auto px-4 py-8">
    <!-- Top Bar & Breadcrumb -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 mb-6">
      <div class="flex items-center gap-2 text-xs text-gray-400">
        <NuxtLink to="/trade" class="text-indigo-400 hover:underline">← 거래소 목록</NuxtLink>
        <span>•</span>
        <span class="font-mono text-white font-semibold">거래번호: {{ trade.orderNumber }}</span>
      </div>

      <!-- Perspective Switcher (구매자 / 판매자 전환 모드) -->
      <div class="flex items-center gap-2 bg-[#151C2F] p-1.5 rounded-xl border border-[#283247] text-xs">
        <span class="text-gray-400 px-2 font-medium">뷰 전환:</span>
        <button
          @click="userPerspective = 'BUYER'"
          class="px-3 py-1 rounded-lg font-bold transition"
          :class="userPerspective === 'BUYER' ? 'bg-indigo-600 text-white' : 'text-gray-400 hover:text-white'"
        >
          👤 구매자 화면
        </button>
        <button
          @click="userPerspective = 'SELLER'"
          class="px-3 py-1 rounded-lg font-bold transition"
          :class="userPerspective === 'SELLER' ? 'bg-indigo-600 text-white' : 'text-gray-400 hover:text-white'"
        >
          🏪 판매자 화면
        </button>
      </div>
    </div>

    <!-- 4-Stage Visual Status Stepper (아이템매니아 / 바로템 표준 4단계) -->
    <div class="bg-[#151C2F] border border-[#283247] rounded-2xl p-6 mb-6 shadow-xl">
      <div class="grid grid-cols-2 md:grid-cols-4 gap-3 text-center text-xs">
        <div
          v-for="(step, idx) in steps"
          :key="step.key"
          class="p-3 rounded-xl border transition relative"
          :class="idx <= currentStepIndex ? 'bg-[#0B1020] border-indigo-500/50 text-white' : 'bg-[#0B1020]/40 border-[#283247] text-gray-500'"
        >
          <div
            class="w-6 h-6 mx-auto rounded-full flex items-center justify-center font-bold text-xs mb-1.5"
            :class="idx < currentStepIndex ? 'bg-emerald-500 text-black' : idx === currentStepIndex ? 'bg-indigo-600 text-white animate-pulse' : 'bg-[#283247] text-gray-500'"
          >
            {{ idx < currentStepIndex ? '✓' : idx + 1 }}
          </div>
          <div class="font-bold text-xs">{{ step.title }}</div>
          <div class="text-[10px] text-gray-400 mt-0.5">{{ step.desc }}</div>
        </div>
      </div>
    </div>

    <!-- Essential In-Game Security Warning Banner (Article 18 & 200% 보상) -->
    <div class="bg-rose-500/10 border-2 border-rose-500/30 rounded-2xl p-5 mb-6 text-xs text-rose-200 space-y-2 shadow-lg shadow-rose-950/20">
      <div class="font-extrabold text-white text-sm flex items-center gap-2">
        <span class="text-base">🚨</span> [필독] 사칭 사기 방지 3대 수칙
      </div>
      <div class="grid grid-cols-1 md:grid-cols-3 gap-3 text-[11px] pt-1">
        <div class="bg-[#0B1020]/80 p-3 rounded-xl border border-rose-500/20">
          <strong class="text-rose-300 block mb-1">1. 물품 재인계 절대 금지</strong>
          물품을 건네받은 직후 "잘못 주었으니 다시 돌려달라"는 귓속말은 <strong>100% 사칭 사기꾼</strong>입니다. 절대 돌려주지 마십시오!
        </div>
        <div class="bg-[#0B1020]/80 p-3 rounded-xl border border-rose-500/20">
          <strong class="text-rose-300 block mb-1">2. 인게임 플랫폼 언급 금지</strong>
          인게임 채팅으로 '거래번호', '아이템매니아', '바로템' 등을 언급할 경우 게임사 운영진에게 제재될 수 있습니다.
        </div>
        <div class="bg-[#0B1020]/80 p-3 rounded-xl border border-rose-500/20">
          <strong class="text-rose-300 block mb-1">3. 입금완료 상태 확인 필수</strong>
          판매자는 반드시 상단 거래 상태가 <strong>'입금완료'</strong>로 변경된 것을 확인한 후에만 인게임 물품을 전달하세요.
        </div>
      </div>
    </div>

    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
      <!-- Left 2 Cols: Handover Protocol, Evidence, Actions -->
      <div class="lg:col-span-2 space-y-6">
        <!-- Trade Asset Overview -->
        <div class="bg-[#151C2F] border border-[#283247] rounded-2xl p-6">
          <div class="flex items-start justify-between gap-4">
            <div>
              <div class="text-xs text-indigo-400 font-semibold">{{ trade.game }} • {{ trade.server }}</div>
              <h2 class="text-lg font-bold text-white mt-1">{{ trade.title }}</h2>
            </div>
            <span class="px-2.5 py-1 rounded bg-rose-500/20 text-rose-300 border border-rose-500/30 text-xs font-black">
              200% 안심보상 가입
            </span>
          </div>

          <div class="grid grid-cols-2 sm:grid-cols-4 gap-3 mt-4 text-xs font-mono">
            <div class="bg-[#0B1020] p-3 rounded-xl border border-[#283247]">
              <div class="text-gray-400 font-sans text-[11px]">거래 수량</div>
              <div class="text-white font-bold mt-0.5">{{ trade.quantity.toLocaleString() }} {{ trade.unit }}</div>
            </div>
            <div class="bg-[#0B1020] p-3 rounded-xl border border-[#283247]">
              <div class="text-gray-400 font-sans text-[11px]">결제 총액</div>
              <div class="text-emerald-400 font-bold mt-0.5">{{ trade.totalAmount.toLocaleString() }} 원</div>
            </div>
            <div class="bg-[#0B1020] p-3 rounded-xl border border-[#283247]">
              <div class="text-gray-400 font-sans text-[11px]">에스크로 상태</div>
              <div class="text-indigo-300 font-bold mt-0.5 font-sans">{{ trade.escrowStatusLabel }}</div>
            </div>
            <div class="bg-[#0B1020] p-3 rounded-xl border border-[#283247]">
              <div class="text-gray-400 font-sans text-[11px]">검수 자동완료 기한</div>
              <div class="text-amber-400 font-bold mt-0.5">{{ trade.autoReleaseTime }}</div>
            </div>
          </div>
        </div>

        <!-- In-Game Handover Protocol Details -->
        <div class="bg-[#151C2F] border border-[#283247] rounded-2xl p-6 space-y-4">
          <div class="flex items-center justify-between">
            <h3 class="text-sm font-bold text-white uppercase tracking-wider">인게임 물품 인계 접선 정보</h3>
            <span class="text-xs text-emerald-400 font-mono">인증코드: #{{ trade.handshakeCode }}</span>
          </div>

          <div class="bg-[#0B1020] rounded-xl border border-[#283247] divide-y divide-[#283247] text-xs">
            <div class="p-3.5 flex justify-between items-center">
              <span class="text-gray-400">판매자 인게임 캐릭터명</span>
              <span class="font-bold text-white font-mono text-sm">{{ trade.sellerCharacter }}</span>
            </div>
            <div class="p-3.5 flex justify-between items-center">
              <span class="text-gray-400">구매자 인게임 수령 캐릭터명</span>
              <span class="font-bold text-indigo-300 font-mono text-sm">{{ trade.buyerCharacter }}</span>
            </div>
            <div class="p-3.5 flex justify-between items-center">
              <span class="text-gray-400">지정 접선 장소</span>
              <span class="font-semibold text-white">{{ trade.meetingLocation }}</span>
            </div>
            <div class="p-3.5 flex justify-between items-center">
              <span class="text-gray-400">인계 방식</span>
              <span class="text-emerald-400 font-medium">1:1 교환창 직접 교환 (스크린샷 촬영)</span>
            </div>
          </div>
        </div>

        <!-- Handover Evidence SHA-256 Inspection -->
        <div class="bg-[#151C2F] border border-[#283247] rounded-2xl p-6 space-y-4">
          <div class="flex items-center justify-between">
            <h3 class="text-sm font-bold text-white uppercase tracking-wider">인계 완료 증빙 내역 (SHA-256)</h3>
            <span v-if="trade.proofSubmitted" class="px-2 py-0.5 rounded bg-emerald-500/10 text-emerald-400 border border-emerald-500/30 text-[10px] font-mono">
              증빙 검증 완료
            </span>
          </div>

          <div v-if="trade.proofSubmitted" class="space-y-3">
            <div class="bg-[#0B1020] p-4 rounded-xl border border-[#283247] text-xs font-mono space-y-2">
              <div class="flex justify-between">
                <span class="text-gray-400">증빙 파일명:</span>
                <span class="text-indigo-300">{{ trade.proofFilename }}</span>
              </div>
              <div class="flex justify-between">
                <span class="text-gray-400">인계 완료 시각:</span>
                <span class="text-white">{{ trade.proofTimestamp }}</span>
              </div>
              <div class="flex flex-col sm:flex-row sm:justify-between gap-1 pt-2 border-t border-[#283247]">
                <span class="text-gray-400">SHA-256 해시:</span>
                <span class="text-emerald-400 break-all text-[11px]">{{ trade.proofHash }}</span>
              </div>
            </div>

            <div class="p-4 rounded-xl bg-gradient-to-r from-[#0B1020] to-[#151C2F] border border-[#283247] flex items-center justify-between">
              <div class="flex items-center gap-3">
                <span class="text-2xl">📸</span>
                <div>
                  <div class="text-xs font-bold text-white">인게임 교환완료 스크린샷 기록됨</div>
                  <div class="text-[10px] text-gray-500">인계 당사자 캐릭터 및 거래 수량이 각인되어 있습니다.</div>
                </div>
              </div>
              <button class="px-3 py-1.5 rounded-lg bg-[#283247] hover:bg-[#374463] text-white text-xs font-semibold">
                증빙 사진 보기
              </button>
            </div>
          </div>

          <!-- If seller and not submitted yet -->
          <div v-else-if="userPerspective === 'SELLER' && trade.status === 'ESCROW_LOCKED'" class="space-y-3">
            <div class="border-2 border-dashed border-[#283247] hover:border-[#6366F1] rounded-xl p-6 text-center bg-[#0B1020] cursor-pointer">
              <span class="text-2xl block mb-1">📷</span>
              <div class="text-xs font-bold text-white">인게임 교환 완료 스크린샷 첨부</div>
              <div class="text-[10px] text-gray-500 mt-0.5">F12 교환창 캡처 파일을 업로드하세요. (SHA-256 자동 계산)</div>
            </div>
            <button
              @click="sellerClaimDelivery"
              class="w-full py-3 rounded-xl bg-gradient-to-r from-emerald-600 to-teal-700 hover:from-emerald-500 hover:to-teal-600 text-white font-bold text-xs shadow-lg transition"
            >
              물품 인계확인 (전달완료 통보)
            </button>
          </div>

          <div v-else class="p-6 text-center text-xs text-gray-500 bg-[#0B1020] rounded-xl border border-[#283247]">
            판매자가 인게임 물품을 전달하고 증빙을 등록할 때까지 잠시 대기해 주세요.
          </div>
        </div>

        <!-- Role Action Buttons Panel -->
        <div class="bg-[#151C2F] border border-[#283247] rounded-2xl p-6 flex flex-col sm:flex-row items-center justify-between gap-4">
          <!-- Buyer View Actions -->
          <template v-if="userPerspective === 'BUYER'">
            <div class="text-xs text-gray-400">
              <strong class="text-white">구매자 안내:</strong> 인게임에서 물품을 정상 수령하셨다면 [물품 인수확인]을 누르세요.
            </div>

            <div class="flex items-center gap-3 w-full sm:w-auto">
              <button
                @click="showCancelModal = true"
                class="px-4 py-2.5 rounded-xl bg-[#283247] hover:bg-[#374463] text-gray-300 text-xs font-semibold transition"
              >
                거래 취소 요청
              </button>
              <button
                @click="showDisputeModal = true"
                class="px-4 py-2.5 rounded-xl bg-rose-500/10 hover:bg-rose-500/20 text-rose-300 border border-rose-500/30 text-xs font-semibold transition"
              >
                사고 접수 (200% 보상)
              </button>
              <button
                v-if="trade.status === 'DELIVERY_CLAIMED'"
                @click="showConfirmModal = true"
                class="px-6 py-2.5 rounded-xl bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-bold shadow-lg shadow-emerald-950/50 transition"
              >
                물품 인수확인 (구매확정)
              </button>
            </div>
          </template>

          <!-- Seller View Actions -->
          <template v-else>
            <div class="text-xs text-gray-400">
              <strong class="text-white">판매자 안내:</strong> 구매자의 인게임 캐릭터명을 확인하고 지정 장소에서 교환을 진행하세요.
            </div>

            <div class="flex items-center gap-3 w-full sm:w-auto">
              <button
                @click="showCancelModal = true"
                class="px-4 py-2.5 rounded-xl bg-[#283247] hover:bg-[#374463] text-gray-300 text-xs font-semibold transition"
              >
                거래 취소 합의
              </button>
              <button
                v-if="trade.status === 'ESCROW_LOCKED'"
                @click="sellerClaimDelivery"
                class="px-6 py-2.5 rounded-xl bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-bold shadow-lg transition"
              >
                물품 인계확인 클릭
              </button>
            </div>
          </template>
        </div>
      </div>

      <!-- Right 1 Col: Counterparty Info & 1:1 In-Trade Chat -->
      <div class="space-y-6">
        <!-- Counterparty Card -->
        <div class="bg-[#151C2F] border border-[#283247] rounded-2xl p-6">
          <h3 class="text-xs font-bold text-gray-400 uppercase tracking-wider mb-3">거래 상대방 정보</h3>
          <div class="flex items-center gap-3">
            <div class="w-12 h-12 rounded-full bg-gradient-to-tr from-indigo-600 to-cyan-400 flex items-center justify-center font-bold text-black text-lg">
              {{ userPerspective === 'BUYER' ? trade.sellerName[0] : trade.buyerName[0] }}
            </div>
            <div>
              <div class="flex items-center gap-2">
                <span class="font-bold text-white text-sm">
                  {{ userPerspective === 'BUYER' ? trade.sellerName : trade.buyerName }}
                </span>
                <span class="px-1.5 py-0.2 rounded bg-amber-500/20 text-amber-300 text-[10px] font-bold border border-amber-500/30">
                  VIP 플래티넘
                </span>
              </div>
              <div class="text-[11px] text-gray-400 mt-0.5">신용도 99.8% • 거래 1,420건</div>
            </div>
          </div>

          <div class="mt-4 pt-4 border-t border-[#283247] space-y-2 text-xs">
            <div class="flex justify-between text-gray-400">
              <span>본인확인 여부:</span>
              <span class="text-emerald-400 font-semibold">PASS 휴대폰 인증 완료</span>
            </div>
            <div class="flex justify-between text-gray-400">
              <span>더치트 사기이력:</span>
              <span class="text-emerald-400 font-semibold">피해사례 0건 (클린)</span>
            </div>
          </div>
        </div>

        <!-- In-Trade 1:1 Real-Time Chat (아이템매니아 / 바로템 전용 거래 채팅) -->
        <div class="bg-[#151C2F] border border-[#283247] rounded-2xl overflow-hidden flex flex-col h-[480px] shadow-xl">
          <div class="p-4 bg-[#111726] border-b border-[#283247] flex items-center justify-between">
            <div class="font-bold text-xs text-white flex items-center gap-2">
              <span class="w-2 h-2 rounded-full bg-emerald-400"></span>
              1:1 거래 보안 채팅
            </div>
            <span class="text-[10px] text-gray-500 font-mono">기록 보존 중</span>
          </div>

          <!-- Chat Message Stream -->
          <div class="flex-1 p-4 overflow-y-auto space-y-3 bg-[#0B1020] text-xs">
            <div
              v-for="(msg, idx) in chatMessages"
              :key="idx"
              class="flex flex-col"
              :class="msg.sender === 'system' ? 'items-center my-1' : msg.isMe ? 'items-end' : 'items-start'"
            >
              <div
                v-if="msg.sender === 'system'"
                class="px-3 py-1 rounded-full bg-[#151C2F] border border-[#283247] text-[10px] text-indigo-300 font-semibold"
              >
                ⚡ {{ msg.text }}
              </div>
              <div v-else class="max-w-[85%] space-y-1">
                <div class="text-[10px] text-gray-500" :class="msg.isMe ? 'text-right' : 'text-left'">{{ msg.sender }}</div>
                <div
                  class="px-3.5 py-2 rounded-xl leading-relaxed"
                  :class="msg.isMe ? 'bg-[#6366F1] text-white rounded-br-none' : 'bg-[#151C2F] text-gray-200 border border-[#283247] rounded-bl-none'"
                >
                  {{ msg.text }}
                </div>
              </div>
            </div>
          </div>

          <!-- Quick Presets -->
          <div class="p-2 border-t border-[#283247] bg-[#111726] flex items-center gap-1.5 overflow-x-auto text-[10px]">
            <button
              v-for="p in presets"
              :key="p"
              @click="sendPreset(p)"
              class="px-2 py-1 rounded bg-[#1A233A] hover:bg-[#283247] text-gray-300 whitespace-nowrap border border-[#283247]"
            >
              {{ p }}
            </button>
          </div>

          <!-- Input bar -->
          <form @submit.prevent="sendMessage" class="p-3 border-t border-[#283247] bg-[#151C2F] flex items-center gap-2">
            <input
              v-model="inputMsg"
              type="text"
              placeholder="메시지 입력... (연락처 유출 감지 시 차단)"
              class="flex-1 bg-[#0B1020] border border-[#283247] rounded-xl px-3 py-2 text-xs text-white placeholder-gray-500 focus:outline-none focus:border-[#6366F1]"
            />
            <button
              type="submit"
              class="px-4 py-2 rounded-xl bg-[#6366F1] text-white font-bold text-xs"
            >
              전송
            </button>
          </form>
        </div>
      </div>
    </div>

    <!-- Modal: 인수확인 (구매확정) -->
    <div v-if="showConfirmModal" class="fixed inset-0 bg-black/70 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <div class="bg-[#151C2F] border border-[#283247] rounded-2xl max-w-md w-full p-6 space-y-4">
        <h3 class="text-base font-bold text-white">물품 인수확인 (구매확정)</h3>
        <p class="text-xs text-gray-300 leading-relaxed">
          인게임에서 판매자로부터 <strong>{{ trade.quantity.toLocaleString() }} {{ trade.unit }}</strong>를 이상 없이 전달받으셨습니까?
        </p>
        <div class="p-3 bg-amber-500/10 border border-amber-500/30 rounded-xl text-xs text-amber-300">
          ⚠️ 인수확인을 완료하면 에스크로에 예치된 대금이 판매자에게 즉시 입금되며, 이후에는 취소할 수 없습니다.
        </div>
        <div class="flex items-center justify-end gap-3 pt-2">
          <button @click="showConfirmModal = false" class="px-4 py-2 rounded-xl bg-[#283247] text-white text-xs font-semibold">
            취소
          </button>
          <button @click="executeBuyerConfirm" class="px-4 py-2 rounded-xl bg-emerald-600 hover:bg-emerald-500 text-white text-xs font-bold">
            인수확인 및 판매자 송금
          </button>
        </div>
      </div>
    </div>

    <!-- Modal: 사고 접수 (200% 보상 청구) -->
    <div v-if="showDisputeModal" class="fixed inset-0 bg-black/70 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <div class="bg-[#151C2F] border border-[#283247] rounded-2xl max-w-lg w-full p-6 space-y-4">
        <h3 class="text-base font-bold text-white">거래 사고 접수 & 200% 안심보상 청구</h3>
        <p class="text-xs text-gray-300">
          거래 중 사기, 미인계, 또는 물품 회수 사고가 발생한 경우 접수해 주시면 에스크로 지급이 즉시 동결되고 전담 중재관이 배정됩니다.
        </p>
        <div>
          <label class="block text-xs font-semibold text-gray-300 mb-1">사고 유형</label>
          <select v-model="disputeForm.type" class="w-full bg-[#0B1020] border border-[#283247] rounded-xl px-3 py-2 text-xs text-white">
            <option value="NOT_RECEIVED">판매자가 허위로 인계확인을 눌렀으나 물품을 받지 못함</option>
            <option value="QUANTITY_SHORTAGE">전달받은 수량이 약속된 수량보다 부족함</option>
            <option value="RECOVERY_ACCIDENT">거래 완료 후 게임사에서 불법 복제/회수 조치됨 (200% 보상 대상)</option>
            <option value="WRONG_SERVER">지정된 서버가 아닌 다른 서버로 전달함</option>
          </select>
        </div>
        <div>
          <label class="block text-xs font-semibold text-gray-300 mb-1">상세 경위 작성</label>
          <textarea
            v-model="disputeForm.detail"
            rows="3"
            placeholder="인게임에서 발생한 구체적인 정황을 작성해 주세요..."
            class="w-full bg-[#0B1020] border border-[#283247] rounded-xl p-3 text-xs text-white focus:outline-none focus:border-[#6366F1]"
          ></textarea>
        </div>
        <div class="flex items-center justify-end gap-3 pt-2">
          <button @click="showDisputeModal = false" class="px-4 py-2 rounded-xl bg-[#283247] text-white text-xs font-semibold">
            닫기
          </button>
          <button @click="executeDispute" class="px-4 py-2 rounded-xl bg-rose-600 hover:bg-rose-500 text-white text-xs font-bold">
            사고 접수 및 대금 동결
          </button>
        </div>
      </div>
    </div>

    <!-- Modal: 거래 취소 요청 -->
    <div v-if="showCancelModal" class="fixed inset-0 bg-black/70 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <div class="bg-[#151C2F] border border-[#283247] rounded-2xl max-w-md w-full p-6 space-y-4">
        <h3 class="text-base font-bold text-white">거래 취소 요청</h3>
        <p class="text-xs text-gray-300">
          아직 인게임 물품이 전달되지 않은 경우에만 취소할 수 있습니다. 상대방이 취소에 동의하거나 30분 동안 미응답 시 자동 환불됩니다.
        </p>
        <div>
          <label class="block text-xs font-semibold text-gray-300 mb-1">취소 사유</label>
          <select class="w-full bg-[#0B1020] border border-[#283247] rounded-xl px-3 py-2 text-xs text-white">
            <option>상대방이 접속하지 않거나 장시간 응답 없음</option>
            <option>캐릭터명 또는 접선 장소 불일치</option>
            <option>상호 합의에 의한 거래 취소</option>
          </select>
        </div>
        <div class="flex items-center justify-end gap-3 pt-2">
          <button @click="showCancelModal = false" class="px-4 py-2 rounded-xl bg-[#283247] text-white text-xs font-semibold">
            취소
          </button>
          <button @click="executeCancel" class="px-4 py-2 rounded-xl bg-amber-600 hover:bg-amber-500 text-white text-xs font-bold">
            취소 요청서 제출
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'

const userPerspective = ref<'BUYER' | 'SELLER'>('BUYER')
const showConfirmModal = ref(false)
const showDisputeModal = ref(false)
const showCancelModal = ref(false)
const inputMsg = ref('')

const disputeForm = ref({
  type: 'NOT_RECEIVED',
  detail: '',
})

const steps = [
  { key: 'PAYMENT_PENDING', title: '1. 입금 대기', desc: '구매자 에스크로 결제' },
  { key: 'ESCROW_LOCKED', title: '2. 물품 인계 중', desc: '인게임 접선 및 교환' },
  { key: 'DELIVERY_CLAIMED', title: '3. 전달 완료', desc: '증빙 제출 & 인수 대기' },
  { key: 'COMPLETED', title: '4. 정산 완료', desc: '판매자 마일리지 입금' },
]

const trade = ref({
  orderNumber: 'TRD-20261027-9001',
  game: '패스 오브 엑자일 2 (PoE 2)',
  server: '스탠다드 리그',
  title: '5,000 카오스 오브 즉시거래 (접선 즉시 1분 전달)',
  quantity: 5000,
  unit: '카오스 오브',
  totalAmount: 60000,
  sellerName: '엑자일전문상단',
  buyerName: '파워바이어_KR',
  sellerCharacter: '레이클라스트상단장',
  buyerCharacter: '워리어마스터_99',
  meetingLocation: '1장 라이온아이 초소 웨이포인트 앞 (2채널)',
  handshakeCode: '8294',
  status: 'DELIVERY_CLAIMED',
  escrowStatusLabel: '입금완료 (에스크로 안전예치 중)',
  autoReleaseTime: '23시간 42분 남음',
  proofSubmitted: true,
  proofFilename: 'poe2_trade_window_8294.jpg',
  proofTimestamp: '2026-10-27 16:40:12',
  proofHash: 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
})

const currentStepIndex = computed(() => {
  switch (trade.value.status) {
    case 'PAYMENT_PENDING': return 0
    case 'ESCROW_LOCKED': return 1
    case 'DELIVERY_CLAIMED': return 2
    case 'COMPLETED': return 3
    default: return 2
  }
})

const presets = [
  '안녕하세요! 접선 장소에 대기 중입니다.',
  '인게임 교환 요청을 보냈습니다. 확인해주세요.',
  '물품 인계 완료했습니다. 인수확인 부탁드립니다!',
  '정상 확인했습니다. 감사합니다.'
]

const chatMessages = ref([
  { sender: 'system', text: '구매자가 60,000원을 에스크로에 예치 완료했습니다. 물품을 전달하세요.', isMe: false },
  { sender: '엑자일전문상단', text: '안녕하세요! 라이온아이 초소 2채널 웨이포인트 앞에 와 있습니다.', isMe: false },
  { sender: '파워바이어_KR', text: '네, 지금 이동 중입니다. 캐릭터명 워리어마스터_99 입니다.', isMe: true },
  { sender: 'system', text: '판매자가 인게임 전달 완료를 통보하고 증빙(SHA-256)을 등록했습니다.', isMe: false },
])

function sendPreset(text: string) {
  inputMsg.value = text
  sendMessage()
}

function sendMessage() {
  if (!inputMsg.value.trim()) return
  const isMe = userPerspective.value === 'BUYER'
  chatMessages.value.push({
    sender: isMe ? trade.value.buyerName : trade.value.sellerName,
    text: inputMsg.value.trim(),
    isMe: true,
  })
  inputMsg.value = ''
}

function sellerClaimDelivery() {
  trade.value.status = 'DELIVERY_CLAIMED'
  trade.value.proofSubmitted = true
  trade.value.proofFilename = 'in_game_trade_proof_upload.png'
  trade.value.proofTimestamp = new Date().toLocaleString()
  chatMessages.value.push({
    sender: 'system',
    text: '판매자가 인게임 인계를 완료하고 스크린샷 증빙을 제출하였습니다.',
    isMe: false,
  })
  alert('인계 완료가 등록되었습니다! 구매자에게 인수확인 요청 알림이 전송되었습니다.')
}

function executeBuyerConfirm() {
  trade.value.status = 'COMPLETED'
  showConfirmModal.value = false
  chatMessages.value.push({
    sender: 'system',
    text: '구매자가 물품 인수를 확인했습니다. 에스크로 대금이 판매자 마일리지로 즉시 정산되었습니다.',
    isMe: false,
  })
  alert('인수확인이 완료되었습니다! 판매자에게 대금이 즉시 정산 지급되었습니다.')
}

function executeDispute() {
  showDisputeModal.value = false
  alert('사고 접수가 완료되었습니다. 에스크로 대금이 동결되었으며 4-Eyes 전담 조사관이 배정되었습니다.')
}

function executeCancel() {
  showCancelModal.value = false
  alert('거래 취소 요청이 접수되었습니다. 상대방 동의 또는 타임아웃 시 전액 자동 환불됩니다.')
}
</script>
