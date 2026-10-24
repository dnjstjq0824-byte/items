<template>
  <div class="space-y-6">
    <div class="flex justify-between items-center">
      <div>
        <h2 class="text-xl font-bold text-white">Dispute Center & Adjudication</h2>
        <p class="text-xs text-gray-400">Strict Dual-Approval (4-Eyes Principle) enforced for all buyer refund adjudications (Article 29)</p>
      </div>
    </div>

    <div class="admin-card overflow-hidden">
      <div class="p-6 border-b border-[#283247] flex justify-between items-center">
        <div>
          <span class="text-xs font-mono text-gray-400">CASE #DSP-9042 &bull; ORDER #ORD-1002</span>
          <h3 class="text-lg font-bold text-white mt-1">Claim: NOT_AS_DESCRIBED (+12 Greatsword Stats Discrepancy)</h3>
        </div>
        <span class="px-2 py-1 rounded text-xs font-semibold bg-amber-500/10 text-amber-400 border border-amber-500/20">
          AWAITING SECONDARY FINANCE APPROVAL
        </span>
      </div>

      <div class="p-6 grid grid-cols-1 md:grid-cols-2 gap-6 bg-[#0B1020]/40">
        <div>
          <h4 class="text-xs font-bold text-gray-400 uppercase tracking-wider mb-2">Primary Decision (Adjudicator)</h4>
          <div class="p-4 rounded-lg bg-[#151C2F] border border-[#283247] space-y-2 text-xs">
            <div><span class="text-gray-400">Decision Code:</span> <strong class="text-rose-400">BUYER_FAVOR_FULL_REFUND</strong></div>
            <div><span class="text-gray-400">Decided By:</span> DisputeManagerAgent (ID: d01-agent)</div>
            <div><span class="text-gray-400">Reason:</span> Submitted video evidence proves weapon stats were +10 instead of agreed +12.</div>
            <div><span class="text-gray-400">Status:</span> <span class="text-amber-400 font-semibold">PENDING_APPROVAL</span></div>
          </div>
        </div>

        <div>
          <h4 class="text-xs font-bold text-gray-400 uppercase tracking-wider mb-2">Secondary Approval (Segregation of Duties)</h4>
          <div class="p-4 rounded-lg bg-[#151C2F] border border-[#283247] flex flex-col justify-between h-[135px]">
            <p class="text-xs text-gray-300">
              Dual-Approval Requirement: A separate Finance Approver must authenticate this action before the refund request is dispatched to the PSP.
            </p>
            <div class="flex gap-2 justify-end">
              <button class="bg-rose-500/20 hover:bg-rose-500/30 text-rose-300 border border-rose-500/30 px-3 py-1.5 rounded text-xs font-semibold">
                Reject Decision
              </button>
              <button class="bg-emerald-600 hover:bg-emerald-500 text-white px-4 py-1.5 rounded text-xs font-semibold transition">
                Authenticate & Execute Refund
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// Dispute adjudication reactive controls
</script>
