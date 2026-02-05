<script setup>
import { computed } from 'vue';
import { useI18n } from 'vue-i18n';
import Icon from 'dashboard/components-next/icon/Icon.vue';

const props = defineProps({
  header: { type: Object, default: null },
  body: { type: String, default: '' },
  footer: { type: String, default: '' },
  buttons: { type: Array, default: () => [] },
});

const { t } = useI18n();

const processedBody = computed(() => {
  if (!props.body) return '';
  return props.body.replace(
    /\{\{([^}]+)\}\}/g,
    '<span class="px-1 rounded bg-n-amber-3 text-n-amber-11 font-medium">[$1]</span>'
  );
});

const processedHeader = computed(() => {
  if (props.header?.type !== 'TEXT' || !props.header?.text) return '';
  return props.header.text.replace(
    /\{\{([^}]+)\}\}/g,
    '<span class="px-1 rounded bg-n-amber-3 text-n-amber-11 font-medium">[$1]</span>'
  );
});

const buttonIcon = type => {
  switch (type?.toUpperCase()) {
    case 'URL':
      return 'i-lucide-external-link';
    case 'PHONE_NUMBER':
      return 'i-lucide-phone';
    default:
      return 'i-lucide-reply';
  }
};
</script>

<template>
  <div class="flex flex-col gap-3">
    <span class="text-xs font-medium text-n-slate-10">
      {{ t('WHATSAPP_TEMPLATES_MGMT.CREATE.PREVIEW.TITLE') }}
    </span>
      <div
        class="flex flex-col items-end gap-1.5"
      >
        <div
          class="relative w-full max-w-sm rounded-xl rounded-tr-sm bg-n-teal-3 p-3 shadow-sm flex flex-col gap-1"
        >
          <div
            v-if="header && header.type !== 'NONE'"
            class="mb-1"
          >
            <div
              v-if="header.type === 'TEXT'"
              class="text-sm font-bold text-n-slate-12"
              v-html="processedHeader"
            />
            <div
              v-else
              class="flex items-center justify-center aspect-video rounded-lg bg-n-alpha-1 border border-n-weak text-n-slate-9 overflow-hidden"
            >
            <img
              v-if="header.type === 'IMAGE' && header.imageUrl"
              :src="header.imageUrl"
              class="w-full h-full object-contain bg-n-alpha-2"
            />
              <video
                v-else-if="header.type === 'VIDEO' && header.videoUrl"
                :src="header.videoUrl"
                class="w-full h-full object-cover"
                controls
              />
              <div
                v-else-if="header.type === 'DOCUMENT' && header.documentName"
                class="flex flex-col items-center gap-2 p-4 text-center"
              >
                <Icon icon="i-lucide-file-text" class="size-8 text-n-slate-9" />
                <span class="text-xs font-medium text-n-slate-11 break-all">
                  {{ header.documentName }}
                </span>
              </div>
              <Icon
                v-else
                :icon="header.type === 'IMAGE' ? 'i-lucide-image' : header.type === 'VIDEO' ? 'i-lucide-play-circle' : 'i-lucide-file-text'"
                class="size-8"
              />
            </div>
          </div>
          <p
            v-if="body"
            class="mb-0 text-sm leading-relaxed text-n-slate-12 whitespace-pre-line break-words"
            v-html="processedBody"
          />
          <p v-else class="mb-0 text-sm italic text-n-slate-9">
            {{ t('WHATSAPP_TEMPLATES_MGMT.CREATE.FORM.BODY.PLACEHOLDER') }}
          </p>
          <div
            v-if="footer"
            class="mt-1 text-[11px] text-n-slate-10 font-medium"
          >
            {{ footer }}
          </div>
        </div>
        <div
          v-if="buttons.length > 0"
          class="flex flex-col w-full max-w-sm gap-1.5"
        >
          <div
            v-for="(btn, idx) in buttons"
            :key="idx"
            class="flex items-center justify-center gap-2 rounded-lg bg-n-solid-2 px-3 py-2 text-sm font-medium text-n-blue-11 outline outline-n-container"
          >
            <Icon :icon="buttonIcon(btn.type)" class="size-4" />
            <span>{{ btn.text || '...' }}</span>
          </div>
        </div>
      </div>
  </div>
</template>
