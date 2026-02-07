<script setup>
import KanbanCard from './KanbanCard.vue';

const props = defineProps({
  stage: {
    type: String,
    required: true,
  },
  label: {
    type: String,
    required: true,
  },
  color: {
    type: String,
    default: 'bg-n-brand',
  },
  contacts: {
    type: Array,
    default: () => [],
  },
});

const emit = defineEmits(['drop']);

const onDragOver = event => {
  event.preventDefault();
  event.dataTransfer.dropEffect = 'move';
};

const onDrop = event => {
  event.preventDefault();
  const contactId = event.dataTransfer.getData('text/plain');
  if (contactId) {
    emit('drop', props.stage, contactId);
  }
};
</script>

<template>
  <div
    class="flex flex-col flex-1 min-w-[260px] max-w-[320px] rounded-xl bg-n-alpha-1"
    @dragover="onDragOver"
    @drop="onDrop"
  >
    <div class="flex items-center gap-2 px-3 py-3">
      <span class="w-2 h-2 rounded-full" :class="color" />
      <span class="text-sm font-semibold text-n-slate-12">{{ label }}</span>
      <span class="ml-auto text-xs text-n-slate-10">
        {{ contacts.length }}
      </span>
    </div>
    <div class="flex flex-col flex-1 gap-2 px-2 pb-2 overflow-y-auto">
      <KanbanCard
        v-for="contact in contacts"
        :key="contact.id"
        :contact="contact"
      />
    </div>
  </div>
</template>
