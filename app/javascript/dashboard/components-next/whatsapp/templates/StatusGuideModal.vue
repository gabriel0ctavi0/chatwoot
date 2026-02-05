<script setup>
import { computed } from 'vue';
import { useI18n } from 'vue-i18n';
import Button from 'dashboard/components-next/button/Button.vue';
import Icon from 'dashboard/components-next/icon/Icon.vue';

const props = defineProps({
  currentStatus: { type: String, default: '' },
});

const emit = defineEmits(['close']);

const { t } = useI18n();

const statusList = [
  {
    id: 'APPROVED',
    key: 'APPROVED',
    icon: 'i-lucide-check-circle',
    colorClass: 'text-n-teal-11',
    bgClass: 'bg-n-teal-3',
    badgeColor: 'text-n-teal-11 bg-n-teal-2',
  },
  {
    id: 'PENDING',
    key: 'PENDING',
    icon: 'i-lucide-clock',
    colorClass: 'text-n-amber-11',
    bgClass: 'bg-n-amber-3',
    badgeColor: 'text-n-amber-11 bg-n-amber-2',
  },
  {
    id: 'PAUSED',
    key: 'PAUSED',
    icon: 'i-lucide-pause-circle',
    colorClass: 'text-n-amber-11',
    bgClass: 'bg-n-amber-3',
    badgeColor: 'text-n-amber-11 bg-n-amber-2',
  },
  {
    id: 'REJECTED',
    key: 'REJECTED',
    icon: 'i-lucide-x-circle',
    colorClass: 'text-n-ruby-11',
    bgClass: 'bg-n-ruby-3',
    badgeColor: 'text-n-ruby-11 bg-n-ruby-2',
  },
];

const getStatusData = status => {
  return {
    title: t(`WHATSAPP_TEMPLATES_MGMT.STATUS_GUIDE.${status}.TITLE`),
    badge: t(`WHATSAPP_TEMPLATES_MGMT.STATUS_GUIDE.${status}.BADGE`),
    description: t(`WHATSAPP_TEMPLATES_MGMT.STATUS_GUIDE.${status}.DESCRIPTION`),
    action: t(`WHATSAPP_TEMPLATES_MGMT.STATUS_GUIDE.${status}.ACTION`),
  };
};
</script>

<template>
  <div
    class="fixed inset-0 z-[60] flex items-center justify-center bg-n-alpha-black2 backdrop-blur-sm"
    @click.self="emit('close')"
  >
    <div
      class="flex flex-col w-full max-w-2xl max-h-[85vh] rounded-2xl bg-n-alpha-3 backdrop-blur-[100px] shadow-2xl border border-n-weak overflow-hidden"
    >
      <!-- Header -->
      <div class="flex items-center justify-between px-6 py-5 border-b border-n-weak">
        <div class="flex items-center gap-3">
          <div class="p-2 rounded-lg bg-n-alpha-1">
            <Icon icon="i-lucide-help-circle" class="size-5 text-n-brand" />
          </div>
          <div class="flex flex-col">
            <h2 class="text-lg font-semibold text-n-slate-12 leading-none">
              {{ t('WHATSAPP_TEMPLATES_MGMT.STATUS_GUIDE.TITLE') }}
            </h2>
            <p class="text-xs text-n-slate-10 mt-1">
              {{ t('WHATSAPP_TEMPLATES_MGMT.STATUS_GUIDE.SUBTITLE') }}
            </p>
          </div>
        </div>
        <Button
          icon="i-lucide-x"
          size="sm"
          variant="ghost"
          color="slate"
          class="rounded-full"
          @click="emit('close')"
        />
      </div>

      <!-- Content -->
      <div class="flex-1 overflow-y-auto p-6 flex flex-col gap-4">
        <div
          v-for="status in statusList"
          :key="status.id"
          class="relative flex flex-col gap-3 p-5 rounded-xl border transition-all"
          :class="[
            currentStatus?.toUpperCase() === status.id
              ? 'border-n-brand bg-n-alpha-1 ring-1 ring-n-brand/20'
              : 'border-n-weak bg-n-solid-2 opacity-80'
          ]"
        >
          <div class="flex items-start justify-between">
            <div class="flex items-center gap-3">
              <div :class="['p-2 rounded-lg', status.bgClass]">
                <Icon :icon="status.icon" :class="['size-5', status.colorClass]" />
              </div>
              <div class="flex flex-col">
                <div class="flex items-center gap-2">
                  <h3 class="font-bold text-n-slate-12">
                    {{ getStatusData(status.key).title }}
                  </h3>
                  <span :class="['text-[10px] px-2 py-0.5 rounded-full font-bold uppercase tracking-wider', status.badgeColor]">
                    {{ getStatusData(status.key).badge }}
                  </span>
                </div>
              </div>
            </div>
            <div v-if="currentStatus?.toUpperCase() === status.id" class="flex items-center gap-1.5 text-n-brand text-xs font-medium bg-n-brand/10 px-2.5 py-1 rounded-full">
              <Icon icon="i-lucide-info" class="size-3" />
              Current Status
            </div>
          </div>

          <div class="flex flex-col gap-2 ml-11">
            <p class="text-sm text-n-slate-11 leading-relaxed">
              {{ getStatusData(status.key).description }}
            </p>
            <div class="flex items-start gap-2 mt-1 p-3 rounded-lg bg-n-alpha-1 border border-n-weak/50">
              <Icon icon="i-lucide-lightbulb" class="size-4 text-n-amber-11 shrink-0 mt-0.5" />
              <p class="text-xs text-n-slate-10 font-medium italic">
                {{ getStatusData(status.key).action }}
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
