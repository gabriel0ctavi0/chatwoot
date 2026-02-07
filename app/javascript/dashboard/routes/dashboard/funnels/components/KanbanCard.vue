<script setup>
import { computed } from 'vue';
import { useI18n } from 'vue-i18n';

const props = defineProps({
  contact: {
    type: Object,
    required: true,
  },
});

const { d } = useI18n();

const initials = computed(() => {
  const name = props.contact.name || '';
  return name
    .split(' ')
    .map(n => n[0])
    .join('')
    .toUpperCase()
    .slice(0, 2);
});

const avatarColor = computed(() => {
  const colors = [
    'bg-n-brand',
    'bg-g-600',
    'bg-y-600',
    'bg-o-600',
    'bg-r-600',
    'bg-p-600',
  ];
  const index = (props.contact.id || 0) % colors.length;
  return colors[index];
});

const lastActivityFormatted = computed(() => {
  const ts = props.contact.last_activity_at || props.contact.updated_at;
  if (!ts) return '';
  const date = new Date(ts * 1000);
  return date.toLocaleString();
});

const companyName = computed(() => {
  return props.contact.company?.name || '';
});

const onDragStart = event => {
  event.dataTransfer.setData('text/plain', String(props.contact.id));
  event.dataTransfer.effectAllowed = 'move';
};
</script>

<template>
  <div
    class="flex flex-col gap-2 p-3 rounded-lg bg-n-background border border-n-weak cursor-grab active:cursor-grabbing shadow-sm hover:shadow-md transition-shadow"
    draggable="true"
    @dragstart="onDragStart"
  >
    <div class="flex items-center gap-2">
      <div
        class="flex items-center justify-center w-7 h-7 rounded-md text-xs font-bold text-white flex-shrink-0"
        :class="avatarColor"
      >
        {{ initials }}
      </div>
      <span class="text-sm font-medium text-n-slate-12 truncate">
        {{ contact.name || contact.email || 'Unknown' }}
      </span>
    </div>
    <div v-if="lastActivityFormatted" class="flex items-center gap-1 text-xs text-n-slate-10">
      <span class="i-lucide-calendar size-3" />
      {{ lastActivityFormatted }}
    </div>
    <div v-if="companyName" class="flex items-center gap-1 text-xs text-n-slate-10">
      <span class="i-lucide-building-2 size-3" />
      {{ companyName }}
    </div>
  </div>
</template>
