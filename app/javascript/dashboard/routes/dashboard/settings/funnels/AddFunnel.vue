<script setup>
import { ref, computed } from 'vue';
import { useStore } from 'vuex';
import { useI18n } from 'vue-i18n';
import { useAlert } from 'dashboard/composables';
import { useMapGetter } from 'dashboard/composables/store';
import Button from 'dashboard/components-next/button/Button.vue';

const emit = defineEmits(['close']);
const store = useStore();
const { t } = useI18n();

const name = ref('');
const uiFlags = useMapGetter('funnels/getUIFlags');

const isNameEmpty = computed(() => !name.value.trim());

const onClose = () => {
  emit('close');
};

const addFunnel = async () => {
  try {
    await store.dispatch('funnels/create', { name: name.value.trim() });
    useAlert(t('FUNNEL_MGMT.ADD.API.SUCCESS_MESSAGE'));
    onClose();
  } catch (error) {
    const errorMessage =
      error.message || t('FUNNEL_MGMT.ADD.API.ERROR_MESSAGE');
    useAlert(errorMessage);
  }
};
</script>

<template>
  <div class="flex flex-col h-auto overflow-auto">
    <woot-modal-header
      :header-title="$t('FUNNEL_MGMT.ADD.TITLE')"
      :header-content="$t('FUNNEL_MGMT.ADD.DESC')"
    />
    <form class="flex flex-wrap mx-0" @submit.prevent="addFunnel">
      <woot-input
        v-model="name"
        class="w-full"
        :label="$t('FUNNEL_MGMT.FORM.NAME.LABEL')"
        :placeholder="$t('FUNNEL_MGMT.FORM.NAME.PLACEHOLDER')"
        data-testid="funnel-name"
      />

      <div class="flex items-center justify-end w-full gap-2 px-0 py-2">
        <Button
          faded
          slate
          type="reset"
          :label="$t('FUNNEL_MGMT.FORM.CANCEL')"
          @click.prevent="onClose"
        />
        <Button
          type="submit"
          data-testid="funnel-submit"
          :label="$t('FUNNEL_MGMT.FORM.CREATE')"
          :disabled="isNameEmpty || uiFlags.isCreating"
          :is-loading="uiFlags.isCreating"
        />
      </div>
    </form>
  </div>
</template>
