<template>
  <div class="max-w-4xl mx-auto px-4 py-12">
    <!-- Header -->
    <div class="text-center max-w-2xl mx-auto mb-12">
      <span class="px-3 py-1 rounded-full bg-indigo-500/10 text-indigo-400 border border-indigo-500/30 text-xs font-semibold tracking-wide uppercase">
        Safety & Trust Framework
      </span>
      <h1 class="text-3xl sm:text-4xl font-extrabold text-white tracking-tight mt-4">
        Trade Protection & Compliance
      </h1>
      <p class="text-sm text-gray-400 mt-3 leading-relaxed">
        Engineered under Master Execution Order BN-GAMEEX-MASTER-001 to eliminate counterparty fraud, unauthorized custody, and account reclamation risks.
      </p>
    </div>

    <!-- 4 Core Pillars of BN GAMEEX Protection -->
    <div class="space-y-6 mb-12">
      <div class="bg-[#151C2F] border border-[#283247] rounded-2xl p-6 sm:p-8 flex items-start gap-5">
        <div class="w-12 h-12 rounded-xl bg-emerald-500/10 border border-emerald-500/30 text-emerald-400 flex items-center justify-center text-2xl shrink-0">
          🛡️
        </div>
        <div class="space-y-2">
          <h2 class="text-lg font-bold text-white">1. Zero-Custody Escrow Vault</h2>
          <p class="text-xs text-gray-300 leading-relaxed">
            When a buyer pays for an order, the funds are safely authorized and locked inside licensed external PSP rails (Stripe / Bank Escrow). Neither party can manipulate or withdraw funds during an active trade. Sellers are guaranteed payment upon verified delivery, and buyers are guaranteed 100% refund if the item is not handed over.
          </p>
        </div>
      </div>

      <div class="bg-[#151C2F] border border-[#283247] rounded-2xl p-6 sm:p-8 flex items-start gap-5">
        <div class="w-12 h-12 rounded-xl bg-rose-500/10 border border-rose-500/30 text-rose-400 flex items-center justify-center text-2xl shrink-0">
          🚫
        </div>
        <div class="space-y-2">
          <div class="flex items-center gap-2">
            <h2 class="text-lg font-bold text-white">2. Prohibited Game Account Trading (Article 3.4)</h2>
            <span class="px-2 py-0.5 rounded bg-rose-500/20 text-rose-300 text-[10px] font-mono border border-rose-500/30">MANDATORY RULE</span>
          </div>
          <p class="text-xs text-gray-300 leading-relaxed">
            BN GAMEEX strictly prohibits the sale or purchase of entire game accounts, logins, passwords, or recovery codes. Over 88% of industry fraud stems from original owners reclaiming accounts through publisher support tickets. Our platform only facilitates transferable in-game items, currency, and officially approved codes.
          </p>
        </div>
      </div>

      <div class="bg-[#151C2F] border border-[#283247] rounded-2xl p-6 sm:p-8 flex items-start gap-5">
        <div class="w-12 h-12 rounded-xl bg-cyan-500/10 border border-cyan-500/30 text-cyan-400 flex items-center justify-center text-2xl shrink-0">
          📸
        </div>
        <div class="space-y-2">
          <h2 class="text-lg font-bold text-white">3. Cryptographic Proof of Delivery (Article 15)</h2>
          <p class="text-xs text-gray-300 leading-relaxed">
            Every seller must provide an immutable handover proof screenshot upon completion. The upload is stamped with a SHA-256 cryptographic digest, UTC timestamp, and recorded on the order ledger. If a dispute arises, operators audit this tamper-evident hash alongside in-game chat and trade logs.
          </p>
        </div>
      </div>

      <div class="bg-[#151C2F] border border-[#283247] rounded-2xl p-6 sm:p-8 flex items-start gap-5">
        <div class="w-12 h-12 rounded-xl bg-indigo-500/10 border border-indigo-500/30 text-indigo-400 flex items-center justify-center text-2xl shrink-0">
          ⚖️
        </div>
        <div class="space-y-2">
          <h2 class="text-lg font-bold text-white">4. 4-Eyes Dual Approval Dispute Resolution</h2>
          <p class="text-xs text-gray-300 leading-relaxed">
            Disputes cannot be unilaterally decided by a single agent or automated bot. A Tier-1 Operations Moderator examines the evidence, formulates a decision proposal, and an independent Finance Officer must authenticate and sign off before any funds are refunded or disbursed.
          </p>
        </div>
      </div>
    </div>

    <!-- Essential In-Game Safety Commandments -->
    <div class="bg-[#151C2F] border border-[#283247] rounded-2xl p-8 mb-12">
      <h3 class="text-base font-bold text-white mb-4 flex items-center gap-2">
        <span>⚠️</span> Essential In-Game Safety Rules for Buyers & Sellers
      </h3>
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4 text-xs text-gray-300">
        <div class="bg-[#0B1020] p-4 rounded-xl border border-[#283247] space-y-1">
          <div class="font-bold text-white">1. Never Return Items In-Game</div>
          <p class="text-gray-400 text-[11px] leading-relaxed">
            Scammers often impersonate the seller immediately after a trade claiming: "Wrong item, give it back so I can resend." Once you receive the item, never give it back to anyone.
          </p>
        </div>

        <div class="bg-[#0B1020] p-4 rounded-xl border border-[#283247] space-y-1">
          <div class="font-bold text-white">2. Keep All Communication On-Platform</div>
          <p class="text-gray-400 text-[11px] leading-relaxed">
            Never move the conversation to Discord, Telegram, Skype, or WhatsApp. We can only protect trades and verify agreements conducted inside BN GAMEEX secure chat.
          </p>
        </div>

        <div class="bg-[#0B1020] p-4 rounded-xl border border-[#283247] space-y-1">
          <div class="font-bold text-white">3. Double-Check Character Spellings</div>
          <p class="text-gray-400 text-[11px] leading-relaxed">
            Always verify that the in-game character trading with you matches the exact name specified in the order handover details down to capital letters and accents.
          </p>
        </div>

        <div class="bg-[#0B1020] p-4 rounded-xl border border-[#283247] space-y-1">
          <div class="font-bold text-white">4. Take Your Own Screenshots</div>
          <p class="text-gray-400 text-[11px] leading-relaxed">
            Both buyers and sellers are strongly encouraged to record a clip or press F12 during the trade window showing the accepted trade confirmation.
          </p>
        </div>
      </div>
    </div>

    <!-- Dispute Timeline & SLA -->
    <div class="bg-[#0B1020] border border-[#283247] rounded-2xl p-6 text-center text-xs text-gray-400 space-y-2">
      <div class="text-white font-semibold text-sm">Need Help With an Active Order?</div>
      <p class="max-w-md mx-auto">
        If you encounter any delivery issues, click "Open Dispute" directly inside your order details page. Our 24/7 Operations Desk responds within 15 minutes.
      </p>
      <div class="pt-2">
        <NuxtLink to="/my/orders" class="inline-block px-4 py-2 rounded-lg bg-[#6366F1] hover:bg-[#4F46E5] text-white font-semibold transition">
          View My Orders
        </NuxtLink>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
// Help & Compliance static content
</script>

