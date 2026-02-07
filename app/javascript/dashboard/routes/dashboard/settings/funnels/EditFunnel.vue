<script setup>
import { ref, computed } from 'vue';
import { useStore } from 'vuex';
import { useI18n } from 'vue-i18n';
import { useAlert } from 'dashboard/composables';
import { useMapGetter } from 'dashboard/composables/store';
import Button from 'dashboard/components-next/button/Button.vue';

const props = defineProps({
  selectedFunnel: {
    type: Object,
    required: true,
  },
});

const emit = defineEmits(['close']);
const store = useStore();
const { t } = useI18n();

const name = ref(props.selectedFunnel.name);
const uiFlags = useMapGetter('funnels/getUIFlags');

const isNameEmpty = computed(() => !name.value.trim());

const onClose = () => {
  emit('close');
};

const editFunnel = async () => {
  try {
    await store.dispatch('funnels/update', {
      id: props.selectedFunnel.id,
      name: name.value.trim(),
    });
    useAlert(t('FUNNEL_MGMT.EDIT.API.SUCCESS_MESSAGE'));
    onClose();
  } catch (error) {
    const errorMessage =
      error.message || t('FUNNEL_MGMT.EDIT.API.ERROR_MESSAGE');
    useAlert(errorMessage);
  }
};
</script>

<template>
  <div class="flex flex-col h-auto overflow-auto">
    <woot-modal-header
      :header-title="$t('FUNNEL_MGMT.EDIT.TITLE')"
    />
    <form class="flex flex-wrap mx-0" @submit.prevent="editFunnel">
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
          :label="$t('FUNNEL_MGMT.FORM.UPDATE')"
          :disabled="isNameEmpty || uiFlags.isUpdating"
          :is-loading="uiFlags.isUpdating"
        />
      </div>
    </form>
  </div>
</template>
