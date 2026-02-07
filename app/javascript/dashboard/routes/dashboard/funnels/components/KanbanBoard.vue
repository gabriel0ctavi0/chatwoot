<script setup>
import { useI18n } from 'vue-i18n';
import KanbanColumn from './KanbanColumn.vue';
import Spinner from 'dashboard/components-next/spinner/Spinner.vue';

defineProps({
  stages: {
    type: Array,
    required: true,
  },
  contactsByStage: {
    type: Object,
    required: true,
  },
  isLoading: {
    type: Boolean,
    default: false,
  },
});

const emit = defineEmits(['moveContact']);
const { t } = useI18n();

const stageLabels = {
  conversando: 'FUNNEL_MGMT.STAGES.CONVERSANDO',
  interessado: 'FUNNEL_MGMT.STAGES.INTERESSADO',
  em_fechamento: 'FUNNEL_MGMT.STAGES.EM_FECHAMENTO',
  concluido: 'FUNNEL_MGMT.STAGES.CONCLUIDO',
};

const stageColors = {
  conversando: 'bg-n-brand',
  interessado: 'bg-y-600',
  em_fechamento: 'bg-o-600',
  concluido: 'bg-g-600',
};

const onDrop = (stage, contactId) => {
  emit('moveContact', { contactId: Number(contactId), stage });
};
</script>

<template>
  <div v-if="isLoading" class="flex justify-center items-center flex-1">
    <Spinner />
  </div>
  <div v-else class="flex flex-1 gap-4 p-4 overflow-x-auto">
    <KanbanColumn
      v-for="stage in stages"
      :key="stage"
      :stage="stage"
      :label="t(stageLabels[stage])"
      :color="stageColors[stage]"
      :contacts="contactsByStage[stage] || []"
      @drop="onDrop"
    />
  </div>
</template>
