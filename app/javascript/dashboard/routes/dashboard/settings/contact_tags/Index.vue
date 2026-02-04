<script setup>
import { useAlert } from 'dashboard/composables';
import { computed, onBeforeMount, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useStoreGetters, useStore } from 'dashboard/composables/store';

import AddContactTag from './AddContactTag.vue';
import EditContactTag from './EditContactTag.vue';
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
const selectedTag = ref({});

const records = computed(() => getters['contactTags/getContactTags'].value);
const uiFlags = computed(() => getters['contactTags/getUIFlags'].value);

const deleteMessage = computed(() => ` ${selectedTag.value.title}?`);

const openAddPopup = () => {
  showAddPopup.value = true;
};
const hideAddPopup = () => {
  showAddPopup.value = false;
};

const openEditPopup = response => {
  showEditPopup.value = true;
  selectedTag.value = response;
};
const hideEditPopup = () => {
  showEditPopup.value = false;
};

const openDeletePopup = response => {
  showDeleteConfirmationPopup.value = true;
  selectedTag.value = response;
};
const closeDeletePopup = () => {
  showDeleteConfirmationPopup.value = false;
};

const deleteTag = async id => {
  try {
    await store.dispatch('contactTags/delete', id);
    useAlert(t('TAG_MGMT.DELETE.API.SUCCESS_MESSAGE'));
  } catch (error) {
    const errorMessage =
      error?.message || t('TAG_MGMT.DELETE.API.ERROR_MESSAGE');
    useAlert(errorMessage);
  } finally {
    loading.value[selectedTag.value.id] = false;
  }
};

const confirmDeletion = () => {
  loading.value[selectedTag.value.id] = true;
  closeDeletePopup();
  deleteTag(selectedTag.value.id);
};

const tableHeaders = computed(() => {
  return [
    t('TAG_MGMT.LIST.TABLE_HEADER.NAME'),
    t('TAG_MGMT.LIST.TABLE_HEADER.DESCRIPTION'),
    t('TAG_MGMT.LIST.TABLE_HEADER.COLOR'),
  ];
});

onBeforeMount(() => {
  store.dispatch('contactTags/get');
});
</script>

<template>
  <SettingsLayout
    :is-loading="uiFlags.isFetching"
    :loading-message="$t('TAG_MGMT.LOADING')"
    :no-records-found="!records.length"
    :no-records-message="$t('TAG_MGMT.LIST.404')"
  >
    <template #header>
      <BaseSettingsHeader
        :title="$t('TAG_MGMT.HEADER')"
        :description="$t('TAG_MGMT.DESCRIPTION')"
        :link-text="$t('TAG_MGMT.LEARN_MORE')"
        feature-name="contact_tags"
      >
        <template #actions>
          <Button
            icon="i-lucide-circle-plus"
            :label="$t('TAG_MGMT.HEADER_BTN_TXT')"
            @click="openAddPopup"
          />
        </template>
      </BaseSettingsHeader>
    </template>
    <template #body>
      <table class="min-w-full overflow-x-auto divide-y divide-n-weak">
        <thead>
          <th
            v-for="thHeader in tableHeaders"
            :key="thHeader"
            class="py-4 font-semibold text-left ltr:pr-4 rtl:pl-4 text-n-slate-11"
          >
            {{ thHeader }}
          </th>
        </thead>
        <tbody class="flex-1 divide-y divide-n-weak text-n-slate-12">
          <tr v-for="(tag, index) in records" :key="tag.title">
            <td class="py-4 ltr:pr-4 rtl:pl-4">
              <span class="mb-1 font-medium break-words text-n-slate-12">
                {{ tag.title }}
              </span>
            </td>
            <td class="py-4 ltr:pr-4 rtl:pl-4">{{ tag.description }}</td>
            <td class="py-4 leading-6 ltr:pr-4 rtl:pl-4">
              <div class="flex items-center">
                <span
                  class="w-4 h-4 mr-1 border border-solid rounded rtl:mr-0 rtl:ml-1 border-n-weak"
                  :style="{ backgroundColor: tag.color }"
                />
                {{ tag.color }}
              </div>
            </td>
            <td class="py-4 min-w-xs">
              <div class="flex gap-1 justify-end">
                <Button
                  v-tooltip.top="$t('TAG_MGMT.FORM.EDIT')"
                  icon="i-lucide-pen"
                  slate
                  xs
                  faded
                  :is-loading="loading[tag.id]"
                  @click="openEditPopup(tag)"
                />
                <Button
                  v-tooltip.top="$t('TAG_MGMT.FORM.DELETE')"
                  icon="i-lucide-trash-2"
                  xs
                  ruby
                  faded
                  :is-loading="loading[tag.id]"
                  @click="openDeletePopup(tag, index)"
                />
              </div>
            </td>
          </tr>
        </tbody>
      </table>
    </template>

    <woot-modal v-model:show="showAddPopup" :on-close="hideAddPopup">
      <AddContactTag @close="hideAddPopup" />
    </woot-modal>

    <woot-modal v-model:show="showEditPopup" :on-close="hideEditPopup">
      <EditContactTag :selected-response="selectedTag" @close="hideEditPopup" />
    </woot-modal>

    <woot-delete-modal
      v-model:show="showDeleteConfirmationPopup"
      :on-close="closeDeletePopup"
      :on-confirm="confirmDeletion"
      :title="$t('TAG_MGMT.DELETE.CONFIRM.TITLE')"
      :message="$t('TAG_MGMT.DELETE.CONFIRM.MESSAGE')"
      :message-value="deleteMessage"
      :confirm-text="$t('TAG_MGMT.DELETE.CONFIRM.YES')"
      :reject-text="$t('TAG_MGMT.DELETE.CONFIRM.NO')"
    />
  </SettingsLayout>
</template>
