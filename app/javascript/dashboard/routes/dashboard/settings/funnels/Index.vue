<script setup>
import { useAlert } from 'dashboard/composables';
import { computed, onBeforeMount, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useStoreGetters, useStore } from 'dashboard/composables/store';

import AddFunnel from './AddFunnel.vue';
import EditFunnel from './EditFunnel.vue';
import BaseSettingsHeader from '../components/BaseSettingsHeader.vue';
import SettingsLayout from '../SettingsLayout.vue';
import Button from 'dashboard/components-next/button/Button.vue';

const getters = useStoreGetters();
const store = useStore();
const { t } = useI18n();

const loading = ref({});
const showAddPopup = ref(false);
const showEditPopup = ref(false);
const showDeleteConfirmationPopup = ref(false);
const selectedFunnel = ref({});

const records = computed(() => getters['funnels/getFunnels'].value);
const uiFlags = computed(() => getters['funnels/getUIFlags'].value);

const deleteMessage = computed(() => ` ${selectedFunnel.value.name}?`);

const openAddPopup = () => {
  showAddPopup.value = true;
};
const hideAddPopup = () => {
  showAddPopup.value = false;
};

const openEditPopup = funnel => {
  showEditPopup.value = true;
  selectedFunnel.value = funnel;
};
const hideEditPopup = () => {
  showEditPopup.value = false;
};

const openDeletePopup = funnel => {
  showDeleteConfirmationPopup.value = true;
  selectedFunnel.value = funnel;
};
const closeDeletePopup = () => {
  showDeleteConfirmationPopup.value = false;
};

const deleteFunnel = async id => {
  try {
    await store.dispatch('funnels/delete', id);
    useAlert(t('FUNNEL_MGMT.DELETE.API.SUCCESS_MESSAGE'));
  } catch (error) {
    const errorMessage =
      error?.message || t('FUNNEL_MGMT.DELETE.API.ERROR_MESSAGE');
    useAlert(errorMessage);
  } finally {
    loading.value[selectedFunnel.value.id] = false;
  }
};

const confirmDeletion = () => {
  loading.value[selectedFunnel.value.id] = true;
  closeDeletePopup();
  deleteFunnel(selectedFunnel.value.id);
};

onBeforeMount(() => {
  store.dispatch('funnels/get');
});
</script>

<template>
  <SettingsLayout
    :is-loading="uiFlags.isFetching"
    :loading-message="$t('FUNNEL_MGMT.LOADING')"
    :no-records-found="!records.length"
    :no-records-message="$t('FUNNEL_MGMT.LIST.404')"
  >
    <template #header>
      <BaseSettingsHeader
        :title="$t('FUNNEL_MGMT.HEADER')"
        :description="$t('FUNNEL_MGMT.DESCRIPTION')"
      >
        <template #actions>
          <Button
            icon="i-lucide-circle-plus"
            :label="$t('FUNNEL_MGMT.HEADER_BTN_TXT')"
            @click="openAddPopup"
          />
        </template>
      </BaseSettingsHeader>
    </template>
    <template #body>
      <table class="min-w-full overflow-x-auto divide-y divide-n-weak">
        <thead>
          <th
            class="py-4 font-semibold text-left ltr:pr-4 rtl:pl-4 text-n-slate-11"
          >
            {{ $t('FUNNEL_MGMT.LIST.TABLE_HEADER.NAME') }}
          </th>
        </thead>
        <tbody class="flex-1 divide-y divide-n-weak text-n-slate-12">
          <tr v-for="funnel in records" :key="funnel.id">
            <td class="py-4 ltr:pr-4 rtl:pl-4">
              <span class="mb-1 font-medium break-words text-n-slate-12">
                {{ funnel.name }}
              </span>
            </td>
            <td class="py-4 min-w-xs">
              <div class="flex gap-1 justify-end">
                <Button
                  v-tooltip.top="$t('FUNNEL_MGMT.FORM.EDIT')"
                  icon="i-lucide-pen"
                  slate
                  xs
                  faded
                  :is-loading="loading[funnel.id]"
                  @click="openEditPopup(funnel)"
                />
                <Button
                  v-tooltip.top="$t('FUNNEL_MGMT.FORM.DELETE')"
                  icon="i-lucide-trash-2"
                  xs
                  ruby
                  faded
                  :is-loading="loading[funnel.id]"
                  @click="openDeletePopup(funnel)"
                />
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </template>

    <woot-modal v-model:show="showAddPopup" :on-close="hideAddPopup">
      <AddFunnel @close="hideAddPopup" />
    </woot-modal>

    <woot-modal v-model:show="showEditPopup" :on-close="hideEditPopup">
      <EditFunnel
        :selected-funnel="selectedFunnel"
        @close="hideEditPopup"
      />
    </woot-modal>

    <woot-delete-modal
      v-model:show="showDeleteConfirmationPopup"
      :on-close="closeDeletePopup"
      :on-confirm="confirmDeletion"
      :title="$t('FUNNEL_MGMT.DELETE.CONFIRM.TITLE')"
      :message="$t('FUNNEL_MGMT.DELETE.CONFIRM.MESSAGE')"
      :message-value="deleteMessage"
      :confirm-text="$t('FUNNEL_MGMT.DELETE.CONFIRM.YES')"
      :reject-text="$t('FUNNEL_MGMT.DELETE.CONFIRM.NO')"
    />
  </SettingsLayout>
</template>
