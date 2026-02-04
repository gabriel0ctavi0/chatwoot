<script setup>
import { ref, computed } from 'vue';
import { useMapGetter } from 'dashboard/composables/store';
import { useI18n } from 'vue-i18n';

import Dialog from 'dashboard/components-next/dialog/Dialog.vue';
import Button from 'dashboard/components-next/button/Button.vue';

const emit = defineEmits(['import']);
const { t } = useI18n();

const uiFlags = useMapGetter('contacts/getUIFlags');
const isImportingContact = computed(() => uiFlags.value.isImporting);

const dialogRef = ref(null);
const fileInput = ref(null);

const hasSelectedFile = ref(null);
const selectedFileName = ref('');
const step = ref('file');
const preview = ref({ validCount: 0, invalidCount: 0 });

const csvUrl = '/downloads/import-contacts-sample.csv';

const HEADER_MAP = {
  nome: 'name',
  name: 'name',
  telefone: 'phone_number',
  phone_number: 'phone_number',
  cidade: 'city',
  city: 'city',
  país: 'country',
  pais: 'country',
  country: 'country',
  'nome da empresa': 'company_name',
  company_name: 'company_name',
  company: 'company_name',
  tag: 'tag',
  label: 'tag',
};

function parseCsvLine(line) {
  const result = [];
  let current = '';
  let inQuotes = false;
  for (let i = 0; i < line.length; i += 1) {
    const char = line[i];
    if (char === '"') {
      inQuotes = !inQuotes;
    } else if ((char === ',' && !inQuotes) || char === '\r') {
      result.push(current.trim());
      current = '';
    } else {
      current += char;
    }
  }
  result.push(current.trim());
  return result;
}

function parseCsvText(text) {
  const lines = text.split(/\n/).filter(l => l.length > 0);
  if (lines.length < 2) return { validCount: 0, invalidCount: 0 };
  const headerLine = lines[0];
  const headers = parseCsvLine(headerLine).map(h => h.toLowerCase().trim());
  const normalizedHeaders = headers.map(h => HEADER_MAP[h] || h);
  let validCount = 0;
  let invalidCount = 0;
  for (let i = 1; i < lines.length; i += 1) {
    const values = parseCsvLine(lines[i]);
    const row = {};
    normalizedHeaders.forEach((key, idx) => {
      row[key] = values[idx] !== undefined ? String(values[idx]).trim() : '';
    });
    const name = (row.name || '').trim();
    const phone = (row.phone_number || '').trim();
    if (name && phone) {
      validCount += 1;
    } else {
      invalidCount += 1;
    }
  }
  return { validCount, invalidCount };
}

const handleFileClick = () => fileInput.value?.click();

const processFileName = fileName => {
  const lastDotIndex = fileName.lastIndexOf('.');
  const extension = fileName.slice(lastDotIndex);
  const baseName = fileName.slice(0, lastDotIndex);

  return baseName.length > 20
    ? `${baseName.slice(0, 20)}...${extension}`
    : fileName;
};

const handleFileChange = () => {
  const file = fileInput.value?.files[0];
  hasSelectedFile.value = file;
  selectedFileName.value = file ? processFileName(file.name) : '';
  step.value = 'file';
};

const handleRemoveFile = () => {
  hasSelectedFile.value = null;
  if (fileInput.value) {
    fileInput.value.value = null;
  }
  selectedFileName.value = '';
  step.value = 'file';
};

const proceedToConfirm = () => {
  if (!hasSelectedFile.value) return;
  const file = hasSelectedFile.value;
  const reader = new FileReader();
  reader.onload = () => {
    try {
      const text = reader.result;
      const { validCount, invalidCount } = parseCsvText(text);
      preview.value = { validCount, invalidCount };
      if (validCount === 0) {
        emit('parseError', t('CONTACTS_LAYOUT.HEADER.ACTIONS.IMPORT_CONTACT.NO_VALID_ROWS'));
        return;
      }
      step.value = 'confirm';
    } catch {
      emit('parseError', t('CONTACTS_LAYOUT.HEADER.ACTIONS.IMPORT_CONTACT.ERROR_MESSAGE'));
    }
  };
  reader.readAsText(file, 'UTF-8');
};

const confirmImport = () => {
  if (!hasSelectedFile.value) return;
  emit('import', hasSelectedFile.value);
};

const confirmButtonLabel = computed(() => {
  if (step.value === 'confirm') {
    return t('CONTACTS_LAYOUT.HEADER.ACTIONS.IMPORT_CONTACT.CONFIRM_IMPORT');
  }
  return t('CONTACTS_LAYOUT.HEADER.ACTIONS.IMPORT_CONTACT.IMPORT');
});

const onConfirm = () => {
  if (step.value === 'file') {
    proceedToConfirm();
  } else {
    confirmImport();
  }
};

const showConfirmationMessage = computed(() => step.value === 'confirm');

const confirmationMessage = computed(() => {
  const { validCount, invalidCount } = preview.value;
  if (invalidCount > 0) {
    return t('CONTACTS_LAYOUT.HEADER.ACTIONS.IMPORT_CONTACT.CONFIRM_MESSAGE_WITH_SKIP', {
      count: validCount,
      invalidCount,
    });
  }
  return t('CONTACTS_LAYOUT.HEADER.ACTIONS.IMPORT_CONTACT.CONFIRM_MESSAGE', { count: validCount });
});

const reset = () => {
  step.value = 'file';
  preview.value = { validCount: 0, invalidCount: 0 };
};

defineExpose({ dialogRef, reset });
</script>

<template>
  <Dialog
    ref="dialogRef"
    :title="t('CONTACTS_LAYOUT.HEADER.ACTIONS.IMPORT_CONTACT.TITLE')"
    :confirm-button-label="confirmButtonLabel"
    :is-loading="isImportingContact"
    :disable-confirm-button="isImportingContact || (step === 'file' && !hasSelectedFile)"
    @confirm="onConfirm"
  >
    <template #description>
      <p class="mb-0 text-sm text-n-slate-11">
        {{ t('CONTACTS_LAYOUT.HEADER.ACTIONS.IMPORT_CONTACT.DESCRIPTION') }}
        <a
          :href="csvUrl"
          target="_blank"
          rel="noopener noreferrer"
          download="import-contacts-sample.csv"
          class="text-n-blue-11"
        >
          {{
            t('CONTACTS_LAYOUT.HEADER.ACTIONS.IMPORT_CONTACT.DOWNLOAD_LABEL')
          }}
        </a>
      </p>
    </template>

    <div class="flex flex-col gap-2">
      <div v-if="showConfirmationMessage" class="p-3 rounded-lg bg-n-alpha-2 text-sm text-n-slate-12">
        {{ confirmationMessage }}
      </div>
      <div class="flex items-center gap-2">
        <label class="text-sm text-n-slate-12 whitespace-nowrap">
          {{ t('CONTACTS_LAYOUT.HEADER.ACTIONS.IMPORT_CONTACT.LABEL') }}
        </label>
        <div class="flex items-center justify-between w-full gap-2">
          <span v-if="hasSelectedFile" class="text-sm text-n-slate-12">
            {{ selectedFileName }}
          </span>
          <Button
            v-if="!hasSelectedFile"
            :label="
              t('CONTACTS_LAYOUT.HEADER.ACTIONS.IMPORT_CONTACT.CHOOSE_FILE')
            "
            icon="i-lucide-upload"
            color="slate"
            variant="ghost"
            size="sm"
            class="!w-fit"
            @click="handleFileClick"
          />
          <div v-else class="flex items-center gap-1">
            <Button
              :label="t('CONTACTS_LAYOUT.HEADER.ACTIONS.IMPORT_CONTACT.CHANGE')"
              color="slate"
              variant="ghost"
              size="sm"
              :disabled="isImportingContact"
              @click="handleFileClick"
            />
            <div class="w-px h-3 bg-n-strong" />
            <Button
              icon="i-lucide-trash"
              color="slate"
              variant="ghost"
              size="sm"
              :disabled="isImportingContact"
              @click="handleRemoveFile"
            />
          </div>
        </div>
      </div>
    </div>
    <input
      ref="fileInput"
      type="file"
      accept="text/csv,.csv"
      class="hidden"
      @change="handleFileChange"
    />
  </Dialog>
</template>
