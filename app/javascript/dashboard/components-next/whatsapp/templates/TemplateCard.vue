<script setup>
import { computed } from 'vue';
import { useI18n } from 'vue-i18n';

import Button from 'dashboard/components-next/button/Button.vue';
import Icon from 'dashboard/components-next/icon/Icon.vue';

const props = defineProps({
  template: { type: Object, required: true },
});

const emit = defineEmits(['edit', 'delete', 'show-status-guide']);

const { t } = useI18n();

const statusConfig = computed(() => {
  const status = props.template.status?.toUpperCase();
  switch (status) {
    case 'APPROVED':
      return {
        icon: 'i-lucide-check-circle',
        class: 'text-n-teal-11 bg-n-teal-3 hover:bg-n-teal-4 cursor-pointer',
        label: t('WHATSAPP_TEMPLATES_MGMT.STATUS.APPROVED'),
      };
    case 'REJECTED':
      return {
        icon: 'i-lucide-x-circle',
        class: 'text-n-ruby-11 bg-n-ruby-3 hover:bg-n-ruby-4 cursor-pointer',
        label: t('WHATSAPP_TEMPLATES_MGMT.STATUS.REJECTED'),
      };
    case 'PAUSED':
      return {
        icon: 'i-lucide-pause-circle',
        class: 'text-n-amber-11 bg-n-amber-3 hover:bg-n-amber-4 cursor-pointer',
        label: t('WHATSAPP_TEMPLATES_MGMT.STATUS.PAUSED'),
      };
    case 'DISABLED':
      return {
        icon: 'i-lucide-ban',
        class: 'text-n-slate-10 bg-n-alpha-1 hover:bg-n-alpha-2 cursor-pointer',
        label: t('WHATSAPP_TEMPLATES_MGMT.STATUS.DISABLED'),
      };
    default:
      return {
        icon: 'i-lucide-clock',
        class: 'text-n-amber-11 bg-n-amber-3 hover:bg-n-amber-4 cursor-pointer',
        label: t('WHATSAPP_TEMPLATES_MGMT.STATUS.PENDING'),
      };
  }
});

const bodyText = computed(() => {
  const bodyComponent = props.template.components?.find(
    c => c.type === 'BODY'
  );
  return bodyComponent?.text || '';
});

const categoryLabel = computed(() => {
  const key = `WHATSAPP_TEMPLATES_MGMT.CATEGORIES.${props.template.category?.toUpperCase()}`;
  return t(key) || props.template.category;
});

const languageLabel = computed(() => {
  const lang = props.template.language || 'en';
  const key = `WHATSAPP_TEMPLATES_MGMT.LANGUAGES.${lang}`;
  const translated = t(key);
  return translated !== key ? translated : lang;
});
</script>

<template>
  <div
    class="group relative flex flex-col gap-3 rounded-xl bg-n-solid-2 p-4 outline outline-n-container transition-shadow hover:shadow-md"
  >
    <div class="flex items-start justify-between gap-3">
      <div class="flex flex-col gap-1 min-w-0">
        <h3 class="text-sm font-semibold text-n-slate-12 truncate">
          {{ template.name }}
        </h3>
        <span class="text-xs text-n-slate-10">
          {{ categoryLabel }} &middot; {{ languageLabel }}
        </span>
      </div>
      <span
        class="inline-flex items-center gap-1 shrink-0 rounded-full px-2 py-0.5 text-xs font-medium transition-colors"
        :class="statusConfig.class"
        @click="emit('show-status-guide', template)"
      >
        <Icon :icon="statusConfig.icon" class="size-3.5" />
        {{ statusConfig.label }}
      </span>
    </div>
    <p
      v-if="bodyText"
      class="mb-0 text-sm leading-relaxed text-n-slate-11 line-clamp-3"
    >
      {{ bodyText }}
    </p>
    <div
      class="flex items-center justify-end gap-2 pt-1 border-t border-n-weak"
    >
      <Button
        icon="i-lucide-pencil"
        size="xs"
        variant="ghost"
        color="slate"
        :label="t('WHATSAPP_TEMPLATES_MGMT.CARD.EDIT')"
        @click="emit('edit', template)"
      />
      <Button
        icon="i-lucide-trash-2"
        size="xs"
        variant="ghost"
        color="ruby"
        :label="t('WHATSAPP_TEMPLATES_MGMT.CARD.DELETE')"
        @click="emit('delete', template)"
      />
    </div>
  </div>
</template>
