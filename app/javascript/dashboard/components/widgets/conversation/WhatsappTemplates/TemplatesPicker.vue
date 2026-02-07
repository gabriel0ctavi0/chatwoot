<script setup>
import { ref, computed, toRef } from 'vue';
import { useAlert } from 'dashboard/composables';
import { useFunctionGetter, useStore } from 'dashboard/composables/store';
import Icon from 'dashboard/components-next/icon/Icon.vue';
import { useI18n } from 'vue-i18n';

const props = defineProps({
  inboxId: {
    type: Number,
    default: undefined,
  },
});

const emit = defineEmits(['onSelect']);

const { t } = useI18n();
const store = useStore();
const query = ref('');
const isRefreshing = ref(false);

const whatsAppTemplateMessages = useFunctionGetter(
  'inboxes/getFilteredWhatsAppTemplates',
  toRef(props, 'inboxId')
);

const filteredTemplateMessages = computed(() =>
  whatsAppTemplateMessages.value.filter(template =>
    template.name.toLowerCase().includes(query.value.toLowerCase())
  )
);

const refreshTemplates = async () => {
  isRefreshing.value = true;
  try {
    await store.dispatch('inboxes/syncTemplates', props.inboxId);
    useAlert(t('WHATSAPP_TEMPLATES.PICKER.REFRESH_SUCCESS'));
  } catch (error) {
    useAlert(t('WHATSAPP_TEMPLATES.PICKER.REFRESH_ERROR'));
  } finally {
    isRefreshing.value = false;
  }
};
</script>

<template>
  <div class="w-full">
    <div class="flex gap-2 mb-2.5">
      <div
        class="flex flex-1 gap-1 items-center px-2.5 py-0 rounded-lg bg-n-alpha-black2 outline outline-1 outline-n-weak hover:outline-n-slate-6 dark:hover:outline-n-slate-6 focus-within:outline-n-brand dark:focus-within:outline-n-brand"
      >
        <fluent-icon icon="search" class="text-n-slate-12" size="16" />
        <input
          v-model="query"
          type="search"
          :placeholder="t('WHATSAPP_TEMPLATES.PICKER.SEARCH_PLACEHOLDER')"
          class="reset-base w-full h-9 bg-transparent text-n-slate-12 !text-sm !outline-0"
        />
      </div>
      <button
        :disabled="isRefreshing"
        class="flex justify-center items-center w-9 h-9 rounded-lg bg-n-alpha-black2 outline outline-1 outline-n-weak hover:outline-n-slate-6 dark:hover:outline-n-slate-6 hover:bg-n-alpha-2 dark:hover:bg-n-solid-2 disabled:opacity-50 disabled:cursor-not-allowed"
        :title="t('WHATSAPP_TEMPLATES.PICKER.REFRESH_BUTTON')"
        @click="refreshTemplates"
      >
        <Icon
          icon="i-lucide-refresh-ccw"
          class="text-n-slate-12 size-4"
          :class="{ 'animate-spin': isRefreshing }"
        />
      </button>
    </div>
    <div
      class="bg-n-background outline-n-container outline outline-1 rounded-lg max-h-[18.75rem] overflow-y-auto p-2.5"
    >
      <div v-for="(template, i) in filteredTemplateMessages" :key="template.id">
        <button
          class="block p-2.5 w-full text-left rounded-lg cursor-pointer hover:bg-n-alpha-2 dark:hover:bg-n-solid-2"
          @click="emit('onSelect', template)"
        >
          <p class="text-sm text-n-slate-12">
            {{ template.name }}
          </p>
        </button>
        <hr
          v-if="i != filteredTemplateMessages.length - 1"
          :key="`hr-${i}`"
          class="border-b border-solid border-n-weak my-2.5 mx-auto max-w-[95%]"
        />
      </div>
      <div v-if="!filteredTemplateMessages.length" class="py-8 text-center">
        <div v-if="query && whatsAppTemplateMessages.length">
          <p>
            {{ t('WHATSAPP_TEMPLATES.PICKER.NO_TEMPLATES_FOUND') }}
            <strong>{{ query }}</strong>
          </p>
        </div>
        <div v-else-if="!whatsAppTemplateMessages.length" class="space-y-4">
          <p class="text-n-slate-11">
            {{ t('WHATSAPP_TEMPLATES.PICKER.NO_TEMPLATES_AVAILABLE') }}
          </p>
        </div>
      </div>
    </div>
  </div>
</template>

