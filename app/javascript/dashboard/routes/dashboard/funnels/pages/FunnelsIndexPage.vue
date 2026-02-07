<script setup>
import { ref, computed, watch, onBeforeMount } from 'vue';
import { useStore } from 'vuex';
import { useI18n } from 'vue-i18n';
import { useMapGetter } from 'dashboard/composables/store';
import KanbanBoard from '../components/KanbanBoard.vue';
import Spinner from 'dashboard/components-next/spinner/Spinner.vue';

const store = useStore();
const { t } = useI18n();

const selectedFunnelId = ref(null);

const funnels = useMapGetter('funnels/getFunnels');
const funnelContacts = useMapGetter('funnels/getFunnelContacts');
const uiFlags = useMapGetter('funnels/getUIFlags');

const selectedFunnel = computed(() => {
  if (!selectedFunnelId.value) return null;
  return funnels.value.find(f => f.id === selectedFunnelId.value);
});

const stages = ['conversando', 'interessado', 'em_fechamento', 'concluido'];

const contactsByStage = computed(() => {
  const grouped = {};
  stages.forEach(stage => {
    grouped[stage] = funnelContacts.value.filter(
      c => c.funnel_stage === stage
    );
  });
  return grouped;
});

const loadContacts = () => {
  if (selectedFunnelId.value) {
    store.dispatch('funnels/getContacts', selectedFunnelId.value);
  }
};

watch(selectedFunnelId, loadContacts);

onBeforeMount(async () => {
  await store.dispatch('funnels/get');
  if (funnels.value.length > 0) {
    selectedFunnelId.value = funnels.value[0].id;
  }
});

const onMoveContact = async ({ contactId, stage }) => {
  await store.dispatch('funnels/moveContact', {
    funnelId: selectedFunnelId.value,
    contactId,
    stage,
  });
};
</script>

<template>
  <div class="flex flex-col flex-1 h-full overflow-hidden bg-n-background">
    <header class="flex items-center gap-4 px-6 py-4 border-b border-n-weak">
      <h1 class="text-lg font-semibold text-n-slate-12">
        {{ t('FUNNEL_MGMT.KANBAN.TITLE') }}
      </h1>
      <select
        v-if="funnels.length"
        v-model="selectedFunnelId"
        class="px-3 py-1.5 rounded-lg border border-n-weak bg-n-background text-n-slate-12 text-sm"
      >
        <option
          v-for="funnel in funnels"
          :key="funnel.id"
          :value="funnel.id"
        >
          {{ funnel.name }}
        </option>
      </select>
    </header>

    <div v-if="uiFlags.isFetching" class="flex justify-center items-center flex-1">
      <Spinner />
    </div>

    <div
      v-else-if="!funnels.length"
      class="flex justify-center items-center flex-1 text-n-slate-10"
    >
      {{ t('FUNNEL_MGMT.KANBAN.NO_FUNNELS') }}
    </div>

    <KanbanBoard
      v-else
      :stages="stages"
      :contacts-by-stage="contactsByStage"
      :is-loading="uiFlags.isFetchingContacts"
      @move-contact="onMoveContact"
    />
  </div>
</template>
