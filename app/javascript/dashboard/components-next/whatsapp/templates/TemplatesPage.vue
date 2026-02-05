<script setup>
import { ref, computed, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { useAlert } from 'dashboard/composables';
import { useStore, useStoreGetters } from 'dashboard/composables/store';

import Button from 'dashboard/components-next/button/Button.vue';
import Spinner from 'dashboard/components-next/spinner/Spinner.vue';
import Icon from 'dashboard/components-next/icon/Icon.vue';
import Dialog from 'dashboard/components-next/dialog/Dialog.vue';
import TemplateCard from './TemplateCard.vue';
import CreateTemplateDialog from './CreateTemplateDialog.vue';
import EditTemplateDialog from './EditTemplateDialog.vue';

const { t } = useI18n();
const store = useStore();
const getters = useStoreGetters();

const searchQuery = ref('');
const selectedInboxId = ref(null);
const showCreateDialog = ref(false);
const showEditDialog = ref(false);
const selectedTemplate = ref(null);
const deleteDialogRef = ref(null);
const templateToDelete = ref(null);

const whatsAppInboxes = computed(
  () => getters['inboxes/getWhatsAppInboxes'].value
);

const uiFlags = computed(
  () => store.getters['whatsappTemplates/getUIFlags']
);

const isFetching = computed(() => uiFlags.value.isFetching);
const isDeleting = computed(() => uiFlags.value.isDeleting);

const allTemplates = computed(
  () => store.getters['whatsappTemplates/getTemplates']
);

const filteredTemplates = computed(() => {
  if (!searchQuery.value) return allTemplates.value;
  const query = searchQuery.value.toLowerCase();
  return allTemplates.value.filter(tmpl => {
    const bodyComponent = tmpl.components?.find(c => c.type === 'BODY');
    return (
      tmpl.name?.toLowerCase().includes(query) ||
      bodyComponent?.text?.toLowerCase().includes(query)
    );
  });
});

const hasNoInboxes = computed(() => whatsAppInboxes.value.length === 0);

const hasNoTemplates = computed(
  () => filteredTemplates.value.length === 0 && !isFetching.value
);

// Auto-select first inbox when available
watch(
  whatsAppInboxes,
  inboxes => {
    if (inboxes.length > 0 && !selectedInboxId.value) {
      selectedInboxId.value = inboxes[0].id;
    }
  },
  { immediate: true }
);

// Fetch templates when inbox changes
watch(
  selectedInboxId,
  inboxId => {
    if (inboxId) {
      store.dispatch('whatsappTemplates/fetch', { inboxId });
    }
  },
  { immediate: true }
);

const refreshTemplates = () => {
  if (selectedInboxId.value) {
    store.dispatch('whatsappTemplates/fetch', {
      inboxId: selectedInboxId.value,
    });
  }
};

const handleEdit = template => {
  selectedTemplate.value = template;
  showEditDialog.value = true;
};

const handleDeleteClick = template => {
  templateToDelete.value = template;
  deleteDialogRef.value?.open();
};

const handleDeleteConfirm = async () => {
  if (!templateToDelete.value) return;

  try {
    await store.dispatch('whatsappTemplates/delete', {
      inboxId: selectedInboxId.value,
      templateId: templateToDelete.value.id,
      templateName: templateToDelete.value.name,
    });
    useAlert(t('WHATSAPP_TEMPLATES_MGMT.DELETE.API.SUCCESS_MESSAGE'));
    deleteDialogRef.value?.close();
    refreshTemplates();
  } catch {
    useAlert(t('WHATSAPP_TEMPLATES_MGMT.DELETE.API.ERROR_MESSAGE'));
  }
};
</script>

<template>
  <section class="flex flex-col w-full h-full overflow-hidden bg-n-surface-1">
    <!-- Header -->
    <header class="sticky top-0 z-10 px-6 lg:px-0">
      <div class="w-full max-w-[60rem] mx-auto">
        <div class="flex items-center justify-between w-full h-20 gap-2">
          <span class="text-xl font-medium text-n-slate-12">
            {{ t('WHATSAPP_TEMPLATES_MGMT.HEADER') }}
          </span>
          <Button
            v-if="!hasNoInboxes"
            :label="t('WHATSAPP_TEMPLATES_MGMT.HEADER_BTN_TXT')"
            icon="i-lucide-plus"
            size="sm"
            @click="showCreateDialog = true"
          />
        </div>
      </div>
    </header>

    <main class="flex-1 px-6 overflow-y-auto lg:px-0">
      <div class="w-full max-w-[60rem] mx-auto py-4">
        <!-- No WhatsApp inboxes -->
        <div
          v-if="hasNoInboxes"
          class="flex flex-col items-center justify-center gap-3 py-20"
        >
          <Icon
            icon="i-lucide-message-circle-warning"
            class="size-10 text-n-slate-9"
          />
          <p class="text-sm text-n-slate-10">
            {{ t('WHATSAPP_TEMPLATES_MGMT.NO_WHATSAPP_INBOXES') }}
          </p>
        </div>

        <template v-else>
          <!-- Inbox selector and search -->
          <div class="flex flex-col gap-4 mb-6 sm:flex-row sm:items-end">
            <div class="flex flex-col gap-1 flex-1">
              <label class="text-xs font-medium text-n-slate-10">
                {{ t('WHATSAPP_TEMPLATES_MGMT.INBOX_SELECT_LABEL') }}
              </label>
              <select
                v-model="selectedInboxId"
                class="w-full rounded-lg bg-n-solid-3 px-3 py-2 text-sm text-n-slate-12 outline outline-n-weak focus:outline-n-brand"
              >
                <option
                  v-for="inbox in whatsAppInboxes"
                  :key="inbox.id"
                  :value="inbox.id"
                >
                  {{ inbox.name }}
                </option>
              </select>
            </div>
            <div class="relative flex-1">
              <Icon
                icon="i-lucide-search"
                class="absolute top-1/2 ltr:left-3 rtl:right-3 size-4 -translate-y-1/2 text-n-slate-9"
              />
              <input
                v-model="searchQuery"
                type="text"
                :placeholder="
                  t('WHATSAPP_TEMPLATES_MGMT.SEARCH_PLACEHOLDER')
                "
                class="w-full rounded-lg bg-n-solid-3 py-2 ltr:pl-9 ltr:pr-3 rtl:pr-9 rtl:pl-3 text-sm text-n-slate-12 outline outline-n-weak placeholder:text-n-slate-9 focus:outline-n-brand"
              />
            </div>
          </div>

          <!-- Loading -->
          <div
            v-if="isFetching"
            class="flex items-center justify-center py-20 text-n-slate-11"
          >
            <Spinner />
          </div>

          <!-- Template list -->
          <div
            v-else-if="!hasNoTemplates"
            class="grid gap-3"
          >
            <TemplateCard
              v-for="tmpl in filteredTemplates"
              :key="tmpl.id || tmpl.name"
              :template="tmpl"
              @edit="handleEdit"
              @delete="handleDeleteClick"
            />
          </div>

          <!-- Empty state -->
          <div
            v-else
            class="flex flex-col items-center justify-center gap-3 py-20"
          >
            <Icon
              icon="i-lucide-file-text"
              class="size-10 text-n-slate-9"
            />
            <p class="text-sm font-medium text-n-slate-11">
              {{ t('WHATSAPP_TEMPLATES_MGMT.EMPTY_STATE.TITLE') }}
            </p>
            <p class="text-xs text-n-slate-10">
              {{ t('WHATSAPP_TEMPLATES_MGMT.EMPTY_STATE.SUBTITLE') }}
            </p>
          </div>
        </template>
      </div>
    </main>

    <!-- Create dialog -->
    <CreateTemplateDialog
      v-if="showCreateDialog"
      :inbox-id="selectedInboxId"
      @close="showCreateDialog = false"
      @created="refreshTemplates"
    />

    <!-- Edit dialog -->
    <EditTemplateDialog
      v-if="showEditDialog && selectedTemplate"
      :inbox-id="selectedInboxId"
      :template="selectedTemplate"
      @close="showEditDialog = false; selectedTemplate = null"
      @updated="refreshTemplates"
    />

    <!-- Delete confirmation dialog -->
    <Dialog
      ref="deleteDialogRef"
      type="alert"
      :title="t('WHATSAPP_TEMPLATES_MGMT.DELETE.TITLE')"
      :description="t('WHATSAPP_TEMPLATES_MGMT.DELETE.CONFIRM')"
      :is-loading="isDeleting"
      @confirm="handleDeleteConfirm"
    />
  </section>
</template>
