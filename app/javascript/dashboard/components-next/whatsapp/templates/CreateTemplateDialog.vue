<script setup>
import { ref, computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { useAlert } from 'dashboard/composables';
import { useStore } from 'dashboard/composables/store';

import Button from 'dashboard/components-next/button/Button.vue';
import Input from 'dashboard/components-next/input/Input.vue';
import TemplatePreview from './TemplatePreview.vue';
import TemplateButtonsEditor from './TemplateButtonsEditor.vue';

const props = defineProps({
  inboxId: { type: [Number, String], required: true },
});

const emit = defineEmits(['close', 'created']);

const { t } = useI18n();
const store = useStore();

const name = ref('');
const category = ref('MARKETING');
const language = ref('en');
const body = ref('');
const buttons = ref([]);

const isCreating = computed(
  () => store.getters['whatsappTemplates/getUIFlags'].isCreating
);

const CATEGORY_OPTIONS = [
  { value: 'MARKETING', label: 'WHATSAPP_TEMPLATES_MGMT.CATEGORIES.MARKETING' },
  { value: 'UTILITY', label: 'WHATSAPP_TEMPLATES_MGMT.CATEGORIES.UTILITY' },
  {
    value: 'AUTHENTICATION',
    label: 'WHATSAPP_TEMPLATES_MGMT.CATEGORIES.AUTHENTICATION',
  },
];

const LANGUAGE_OPTIONS = [
  { value: 'en', label: 'WHATSAPP_TEMPLATES_MGMT.LANGUAGES.en' },
  { value: 'en_US', label: 'WHATSAPP_TEMPLATES_MGMT.LANGUAGES.en_US' },
  { value: 'pt_BR', label: 'WHATSAPP_TEMPLATES_MGMT.LANGUAGES.pt_BR' },
  { value: 'es', label: 'WHATSAPP_TEMPLATES_MGMT.LANGUAGES.es' },
  { value: 'fr', label: 'WHATSAPP_TEMPLATES_MGMT.LANGUAGES.fr' },
  { value: 'de', label: 'WHATSAPP_TEMPLATES_MGMT.LANGUAGES.de' },
  { value: 'it', label: 'WHATSAPP_TEMPLATES_MGMT.LANGUAGES.it' },
  { value: 'hi', label: 'WHATSAPP_TEMPLATES_MGMT.LANGUAGES.hi' },
  { value: 'ar', label: 'WHATSAPP_TEMPLATES_MGMT.LANGUAGES.ar' },
  { value: 'ja', label: 'WHATSAPP_TEMPLATES_MGMT.LANGUAGES.ja' },
  { value: 'zh_CN', label: 'WHATSAPP_TEMPLATES_MGMT.LANGUAGES.zh_CN' },
];

const isFormValid = computed(() => {
  return name.value.trim().length > 0 && body.value.trim().length >= 10;
});

const nameError = computed(() => {
  if (!name.value) return '';
  const pattern = /^[a-z0-9_]+$/;
  if (!pattern.test(name.value)) {
    return t('WHATSAPP_TEMPLATES_MGMT.CREATE.FORM.NAME.HELP');
  }
  return '';
});

const handleSubmit = async () => {
  if (!isFormValid.value) return;

  try {
    const templateData = {
      name: name.value,
      category: category.value,
      language: language.value,
      body: body.value,
      buttons: buttons.value.filter(btn => btn.text),
    };

    await store.dispatch('whatsappTemplates/create', {
      inboxId: props.inboxId,
      templateData,
    });

    useAlert(t('WHATSAPP_TEMPLATES_MGMT.CREATE.API.SUCCESS_MESSAGE'));
    emit('created');
    emit('close');
  } catch {
    useAlert(t('WHATSAPP_TEMPLATES_MGMT.CREATE.API.ERROR_MESSAGE'));
  }
};
</script>

<template>
  <div
    class="fixed inset-0 z-50 flex items-center justify-center bg-n-alpha-black1 backdrop-blur-[4px]"
  >
    <div
      class="flex flex-col w-full max-w-5xl max-h-[90vh] rounded-xl bg-n-alpha-3 backdrop-blur-[100px] shadow-xl"
    >
      <!-- Header -->
      <div
        class="flex items-center justify-between px-6 py-4 border-b border-n-weak"
      >
        <h2 class="text-base font-medium text-n-slate-12">
          {{ t('WHATSAPP_TEMPLATES_MGMT.CREATE.TITLE') }}
        </h2>
        <Button
          icon="i-lucide-x"
          size="sm"
          variant="ghost"
          color="ruby"
          @click="emit('close')"
        />
      </div>

      <!-- Body - 2 columns -->
      <div
        class="flex flex-1 gap-6 px-6 py-5 overflow-y-auto md:flex-row flex-col"
      >
        <!-- Left Column - Form -->
        <div class="flex flex-col flex-1 gap-4">
          <Input
            v-model="name"
            :label="t('WHATSAPP_TEMPLATES_MGMT.CREATE.FORM.NAME.LABEL')"
            :placeholder="
              t('WHATSAPP_TEMPLATES_MGMT.CREATE.FORM.NAME.PLACEHOLDER')
            "
            :message="nameError"
            :message-type="nameError ? 'error' : 'info'"
          />

          <div class="flex gap-3">
            <div class="flex flex-col flex-1 gap-1">
              <label class="text-sm font-medium text-n-slate-12">
                {{ t('WHATSAPP_TEMPLATES_MGMT.CREATE.FORM.CATEGORY.LABEL') }}
              </label>
              <select
                v-model="category"
                class="w-full rounded-lg bg-n-solid-3 px-3 py-2 text-sm text-n-slate-12 outline outline-n-weak focus:outline-n-brand"
              >
                <option
                  v-for="opt in CATEGORY_OPTIONS"
                  :key="opt.value"
                  :value="opt.value"
                >
                  {{ t(opt.label) }}
                </option>
              </select>
            </div>
            <div class="flex flex-col flex-1 gap-1">
              <label class="text-sm font-medium text-n-slate-12">
                {{ t('WHATSAPP_TEMPLATES_MGMT.CREATE.FORM.LANGUAGE.LABEL') }}
              </label>
              <select
                v-model="language"
                class="w-full rounded-lg bg-n-solid-3 px-3 py-2 text-sm text-n-slate-12 outline outline-n-weak focus:outline-n-brand"
              >
                <option
                  v-for="opt in LANGUAGE_OPTIONS"
                  :key="opt.value"
                  :value="opt.value"
                >
                  {{ t(opt.label) }}
                </option>
              </select>
            </div>
          </div>

          <div class="flex flex-col gap-1">
            <label class="text-sm font-medium text-n-slate-12">
              {{ t('WHATSAPP_TEMPLATES_MGMT.CREATE.FORM.BODY.LABEL') }}
            </label>
            <textarea
              v-model="body"
              :placeholder="
                t('WHATSAPP_TEMPLATES_MGMT.CREATE.FORM.BODY.PLACEHOLDER')
              "
              rows="6"
              class="w-full rounded-lg bg-n-solid-3 px-3 py-2 text-sm text-n-slate-12 outline outline-n-weak placeholder:text-n-slate-9 focus:outline-n-brand resize-none"
            />
            <span class="text-xs text-n-slate-10">
              {{ t('WHATSAPP_TEMPLATES_MGMT.CREATE.FORM.BODY.HELP') }}
            </span>
          </div>

          <TemplateButtonsEditor v-model="buttons" />
        </div>

        <!-- Right Column - Preview -->
        <div
          class="flex flex-col flex-1 rounded-xl border border-n-weak bg-n-alpha-1 p-4"
        >
          <TemplatePreview :body="body" :buttons="buttons" />
        </div>
      </div>

      <!-- Footer -->
      <div
        class="flex items-center justify-end gap-3 px-6 py-4 border-t border-n-weak"
      >
        <Button
          :label="t('WHATSAPP_TEMPLATES_MGMT.CREATE.CANCEL')"
          variant="faded"
          color="slate"
          @click="emit('close')"
        />
        <Button
          :label="t('WHATSAPP_TEMPLATES_MGMT.CREATE.SUBMIT')"
          icon="i-lucide-plus"
          :is-loading="isCreating"
          :disabled="!isFormValid || isCreating"
          @click="handleSubmit"
        />
      </div>
    </div>
  </div>
</template>
