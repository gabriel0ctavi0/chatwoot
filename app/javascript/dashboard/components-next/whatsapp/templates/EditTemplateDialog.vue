<script setup>
import { ref, computed, onMounted } from 'vue';
import { useI18n } from 'vue-i18n';
import { useAlert } from 'dashboard/composables';
import { useStore } from 'dashboard/composables/store';

import Button from 'dashboard/components-next/button/Button.vue';
import Input from 'dashboard/components-next/input/Input.vue';
import TemplatePreview from './TemplatePreview.vue';
import TemplateButtonsEditor from './TemplateButtonsEditor.vue';

const props = defineProps({
  inboxId: { type: [Number, String], required: true },
  template: { type: Object, required: true },
});

const emit = defineEmits(['close', 'updated']);

const { t } = useI18n();
const store = useStore();

const category = ref('MARKETING');
const body = ref('');
const headerType = ref('NONE');
const headerText = ref('');
const headerFile = ref(null);
const headerImageUrl = ref('');
const headerVideoUrl = ref('');
const headerDocumentName = ref('');
const footerText = ref('');
const buttons = ref([]);

const isUpdating = computed(
  () => store.getters['whatsappTemplates/getUIFlags'].isUpdating
);

const handleHeaderFileChange = event => {
  const file = event.target.files[0];
  if (file) {
    headerFile.value = file;
    const reader = new FileReader();
    reader.onload = e => {
      if (headerType.value === 'IMAGE') {
        headerImageUrl.value = e.target.result;
      } else if (headerType.value === 'VIDEO') {
        headerVideoUrl.value = e.target.result;
      } else if (headerType.value === 'DOCUMENT') {
        headerDocumentName.value = file.name;
      }
    };
    reader.readAsDataURL(file);
  }
};

const HEADER_TYPE_OPTIONS = [
  { value: 'NONE', label: 'None' },
  { value: 'TEXT', label: 'WHATSAPP_TEMPLATES_MGMT.CREATE.FORM.HEADER.TEXT' },
  { value: 'IMAGE', label: 'WHATSAPP_TEMPLATES_MGMT.CREATE.FORM.HEADER.IMAGE' },
  { value: 'VIDEO', label: 'WHATSAPP_TEMPLATES_MGMT.CREATE.FORM.HEADER.VIDEO' },
  { value: 'DOCUMENT', label: 'WHATSAPP_TEMPLATES_MGMT.CREATE.FORM.HEADER.DOCUMENT' },
];

const CATEGORY_OPTIONS = [
  { value: 'MARKETING', label: 'WHATSAPP_TEMPLATES_MGMT.CATEGORIES.MARKETING' },
  { value: 'UTILITY', label: 'WHATSAPP_TEMPLATES_MGMT.CATEGORIES.UTILITY' },
  {
    value: 'AUTHENTICATION',
    label: 'WHATSAPP_TEMPLATES_MGMT.CATEGORIES.AUTHENTICATION',
  },
];

const isFormValid = computed(() => {
  return body.value.trim().length >= 10;
});

onMounted(() => {
  if (props.template) {
    category.value = props.template.category || 'MARKETING';

    const headerComponent = props.template.components?.find(
      c => c.type === 'HEADER'
    );
    if (headerComponent) {
      headerType.value = headerComponent.format || 'TEXT';
      originalHeaderType.value = headerComponent.format || 'TEXT';
      headerText.value = headerComponent.text || '';
      if (headerComponent.example?.header_url?.[0]) {
        headerImageUrl.value = headerComponent.example.header_url[0];
      }
    }

    const bodyComponent = props.template.components?.find(
      c => c.type === 'BODY'
    );
    body.value = bodyComponent?.text || '';

    const footerComponent = props.template.components?.find(
      c => c.type === 'FOOTER'
    );
    footerText.value = footerComponent?.text || '';

    const buttonsComponent = props.template.components?.find(
      c => c.type === 'BUTTONS'
    );
    if (buttonsComponent?.buttons) {
      buttons.value = buttonsComponent.buttons.map(btn => ({
        type: btn.type || 'QUICK_REPLY',
        text: btn.text || '',
        url: btn.url || '',
        phone_number: btn.phone_number || '',
      }));
    }
  }
});

const isUploading = ref(false);
const originalHeaderType = ref('NONE');

const handleSubmit = async () => {
  if (!isFormValid.value) return;

  try {
    let mediaUrl = null;

    if (['IMAGE', 'VIDEO', 'DOCUMENT'].includes(headerType.value) && headerFile.value) {
      isUploading.value = true;
      const uploadResult = await store.dispatch('whatsappTemplates/uploadMedia', {
        inboxId: props.inboxId,
        file: headerFile.value,
      });
      mediaUrl = uploadResult.url;
      isUploading.value = false;
    }

    const headerData = (() => {
      if (headerType.value === 'NONE') return undefined;
      if (headerType.value === 'TEXT') {
        return { type: 'TEXT', text: headerText.value };
      }
      // For media headers: only include if user uploaded a new file or it's a new type
      if (mediaUrl) {
        return { type: headerType.value, media_url: mediaUrl };
      }
      // If no new file and same type as original, don't send header (keep existing)
      if (headerType.value === originalHeaderType.value) return undefined;
      return { type: headerType.value };
    })();

    const templateData = {
      category: category.value,
      body: body.value,
      footer: footerText.value,
      header: headerData,
      buttons: buttons.value.filter(btn => btn.text),
    };

    await store.dispatch('whatsappTemplates/update', {
      inboxId: props.inboxId,
      templateId: props.template.id,
      templateData,
    });

    useAlert(t('WHATSAPP_TEMPLATES_MGMT.EDIT.API.SUCCESS_MESSAGE'));
    emit('updated');
    emit('close');
  } catch {
    isUploading.value = false;
    useAlert(t('WHATSAPP_TEMPLATES_MGMT.EDIT.API.ERROR_MESSAGE'));
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
        <div class="flex flex-col gap-0.5">
          <h2 class="text-base font-medium text-n-slate-12">
            {{ t('WHATSAPP_TEMPLATES_MGMT.EDIT.TITLE') }}
          </h2>
          <span class="text-xs text-n-slate-10">
            {{ template.name }} &middot; {{ template.language }}
          </span>
        </div>
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
          <div class="flex flex-col gap-1">
            <label class="text-sm font-medium text-n-slate-12">
              {{ t('WHATSAPP_TEMPLATES_MGMT.CREATE.FORM.NAME.LABEL') }}
            </label>
            <Input
              :model-value="template.name"
              disabled
              size="md"
            />
          </div>

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
              <Input
                :model-value="template.language"
                disabled
                size="md"
              />
            </div>
          </div>

          <div class="flex flex-col gap-1">
            <label class="text-sm font-medium text-n-slate-12">
              {{ t('WHATSAPP_TEMPLATES_MGMT.CREATE.FORM.HEADER.LABEL') }}
            </label>
            <div class="flex flex-col gap-2">
              <select
                v-model="headerType"
                class="w-full rounded-lg bg-n-solid-3 px-3 py-2 text-sm text-n-slate-12 outline outline-n-weak focus:outline-n-brand"
              >
                <option
                  v-for="opt in HEADER_TYPE_OPTIONS"
                  :key="opt.value"
                  :value="opt.value"
                >
                  {{ t(opt.label) || opt.label }}
                </option>
              </select>
              <Input
                v-if="headerType === 'TEXT'"
                v-model="headerText"
                class="w-full"
                :placeholder="t('WHATSAPP_TEMPLATES_MGMT.CREATE.FORM.HEADER.PLACEHOLDER')"
              />
              <div v-else-if="headerType === 'IMAGE' || headerType === 'VIDEO' || headerType === 'DOCUMENT'" class="flex flex-col gap-2">
                <input
                  type="file"
                  :accept="headerType === 'IMAGE' ? 'image/*' : headerType === 'VIDEO' ? 'video/*' : '.pdf,.doc,.docx,.txt'"
                  class="hidden"
                  ref="headerFileInput"
                  @change="handleHeaderFileChange"
                />
                <Button
                  :label="headerFile ? headerFile.name : t(`WHATSAPP_TEMPLATES_MGMT.CREATE.FORM.HEADER.CHOOSE_${headerType}`)"
                  :icon="headerType === 'IMAGE' ? 'i-lucide-image' : headerType === 'VIDEO' ? 'i-lucide-play-circle' : 'i-lucide-file-text'"
                  variant="faded"
                  color="slate"
                  size="sm"
                  class="w-full"
                  @click="$refs.headerFileInput.click()"
                />
              </div>
            </div>
          </div>

          <div class="flex flex-col gap-1">
            <label class="text-sm font-medium text-n-slate-12">
              {{ t('WHATSAPP_TEMPLATES_MGMT.CREATE.FORM.BODY.LABEL') }}
            </label>
            <textarea
              :value="body"
              :placeholder="
                t('WHATSAPP_TEMPLATES_MGMT.CREATE.FORM.BODY.PLACEHOLDER')
              "
              rows="10"
              class="w-full rounded-lg bg-n-solid-3 px-3 py-2 text-sm text-n-slate-12 outline outline-n-weak placeholder:text-n-slate-9 focus:outline-n-brand resize-none"
              @input="body = $event.target.value"
            />
            <span class="text-xs text-n-slate-10">
              {{ t('WHATSAPP_TEMPLATES_MGMT.CREATE.FORM.BODY.HELP') }}
            </span>
          </div>

          <div class="flex flex-col gap-1">
            <label class="text-sm font-medium text-n-slate-12">
              {{ t('WHATSAPP_TEMPLATES_MGMT.CREATE.FORM.FOOTER.LABEL') }}
            </label>
            <Input
              v-model="footerText"
              :placeholder="t('WHATSAPP_TEMPLATES_MGMT.CREATE.FORM.FOOTER.PLACEHOLDER')"
            />
          </div>

          <TemplateButtonsEditor v-model="buttons" />
        </div>

        <!-- Right Column - Preview -->
        <div
          class="flex flex-col flex-1 rounded-xl border border-n-weak bg-n-alpha-1 p-4"
        >
          <TemplatePreview
            :header="headerType !== 'NONE' ? { 
              type: headerType, 
              text: headerText, 
              imageUrl: headerImageUrl,
              videoUrl: headerVideoUrl,
              documentName: headerDocumentName
            } : null"
            :body="body"
            :footer="footerText"
            :buttons="buttons"
          />
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
          :label="t('WHATSAPP_TEMPLATES_MGMT.EDIT.SUBMIT')"
          icon="i-lucide-save"
          :is-loading="isUpdating || isUploading"
          :disabled="!isFormValid || isUpdating || isUploading"
          @click="handleSubmit"
        />
      </div>
    </div>
  </div>
</template>
