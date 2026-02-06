<script setup>
import { ref, computed } from 'vue';
import { useI18n } from 'vue-i18n';
import { useMapGetter } from 'dashboard/composables/store';
import { vOnClickOutside } from '@vueuse/components';

import NextButton from 'dashboard/components-next/button/Button.vue';
import Input from 'dashboard/components-next/input/Input.vue';

const emit = defineEmits(['close', 'assign']);

const { t } = useI18n();

const tags = useMapGetter('contactTags/getContactTags');

const query = ref('');
const selectedTags = ref([]);

const filteredTags = computed(() => {
  if (!query.value) return tags.value;
  return tags.value.filter(tag =>
    tag.title.toLowerCase().includes(query.value.toLowerCase())
  );
});

const hasTags = computed(() => tags.value.length > 0);
const hasFilteredTags = computed(() => filteredTags.value.length > 0);

const isTagSelected = tag => {
  return selectedTags.value.includes(tag);
};

const onClose = () => {
  emit('close');
};

const handleAssign = () => {
  if (selectedTags.value.length > 0) {
    emit('assign', selectedTags.value);
  }
};
</script>

<template>
  <div
    v-on-click-outside="onClose"
    class="absolute ltr:right-2 rtl:left-2 top-12 origin-top-right z-20 w-60 bg-n-alpha-3 backdrop-blur-[100px] border-n-weak rounded-lg border border-solid shadow-md"
    role="dialog"
    aria-labelledby="tag-dialog-title"
  >
    <div class="triangle">
      <svg height="12" viewBox="0 0 24 12" width="24">
        <path d="M20 12l-8-8-12 12" fill-rule="evenodd" stroke-width="1px" />
      </svg>
    </div>
    <div class="flex items-center justify-between p-2.5">
      <span class="text-sm font-medium">{{
        t('BULK_ACTION.TAGS.ASSIGN_TAGS')
      }}</span>
      <NextButton ghost xs slate icon="i-lucide-x" @click="onClose" />
    </div>
    <div class="flex flex-col max-h-60 min-h-0">
      <header class="py-2 px-2.5">
        <Input
          v-model="query"
          type="search"
          :placeholder="t('BULK_ACTION.SEARCH_INPUT_PLACEHOLDER')"
          icon-left="i-lucide-search"
          size="sm"
          class="w-full"
          :aria-label="t('BULK_ACTION.SEARCH_INPUT_PLACEHOLDER')"
        />
      </header>
      <ul
        v-if="hasTags"
        class="flex-1 overflow-y-auto m-0 list-none"
        role="listbox"
        :aria-label="t('BULK_ACTION.TAGS.ASSIGN_TAGS')"
      >
        <li v-if="!hasFilteredTags" class="p-2 text-center">
          <span class="text-sm text-n-slate-11">{{
            t('BULK_ACTION.TAGS.NO_TAGS_FOUND')
          }}</span>
        </li>
        <li
          v-for="tag in filteredTags"
          :key="tag.id"
          class="my-1 mx-0 py-0 px-2.5"
          role="option"
          :aria-selected="isTagSelected(tag.title)"
        >
          <label
            class="items-center rounded-md cursor-pointer flex py-1 px-2.5 hover:bg-n-slate-3 dark:hover:bg-n-solid-3 has-[:checked]:bg-n-slate-2"
          >
            <input
              v-model="selectedTags"
              type="checkbox"
              :value="tag.title"
              class="my-0 ltr:mr-2.5 rtl:ml-2.5"
              :aria-label="tag.title"
            />
            <span
              class="overflow-hidden flex-grow w-full text-sm whitespace-nowrap text-ellipsis"
            >
              {{ tag.title }}
            </span>
          </label>
        </li>
      </ul>
      <div v-else class="p-2 text-center">
        <span class="text-sm text-n-slate-11">{{
          t('CONTACTS_BULK_ACTIONS.NO_TAGS_FOUND')
        }}</span>
      </div>
      <footer class="p-2">
        <NextButton
          sm
          type="submit"
          class="w-full"
          :label="t('BULK_ACTION.TAGS.ASSIGN_SELECTED_TAGS')"
          :disabled="!selectedTags.length"
          @click="handleAssign"
        />
      </footer>
    </div>
  </div>
</template>

<style scoped lang="scss">
.triangle {
  @apply block z-10 absolute text-left -top-3 ltr:right-[--triangle-position] rtl:left-[--triangle-position];

  svg path {
    @apply fill-n-alpha-3 backdrop-blur-[100px]  stroke-n-weak;
  }
}
</style>
