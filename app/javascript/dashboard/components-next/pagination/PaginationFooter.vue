<script setup>
import { computed, ref } from 'vue';
import { useI18n } from 'vue-i18n';
import { useNumberFormatter } from 'shared/composables/useNumberFormatter';
import { vOnClickOutside } from '@vueuse/components';

import Button from 'dashboard/components-next/button/Button.vue';
import DropdownMenu from 'dashboard/components-next/dropdown-menu/DropdownMenu.vue';

const props = defineProps({
  currentPage: {
    type: Number,
    required: true,
  },
  totalItems: {
    type: Number,
    required: true,
  },
  itemsPerPage: {
    type: Number,
    default: 16,
  },
  currentPageInfo: {
    type: String,
    default: '',
  },
});
const emit = defineEmits(['update:currentPage', 'update:itemsPerPage']);
const { t } = useI18n();
const { formatCompactNumber, formatFullNumber } = useNumberFormatter();

const showItemsPerPageMenu = ref(false);

const totalPages = computed(() =>
  Math.ceil(props.totalItems / props.itemsPerPage)
);
const startItem = computed(
  () => (props.currentPage - 1) * props.itemsPerPage + 1
);
const endItem = computed(() =>
  Math.min(startItem.value + props.itemsPerPage - 1, props.totalItems)
);
const isFirstPage = computed(() => props.currentPage === 1);
const isLastPage = computed(() => props.currentPage === totalPages.value);

const itemsPerPageOptions = [25, 50, 100, 150, 200].map(value => ({
  label: value.toString(),
  value,
  action: 'select',
  isSelected: value === props.itemsPerPage,
}));

const changePage = newPage => {
  if (newPage >= 1 && newPage <= totalPages.value) {
    emit('update:currentPage', newPage);
  }
};

const toggleItemsPerPageMenu = () => {
  showItemsPerPageMenu.value = !showItemsPerPageMenu.value;
};

const closeItemsPerPageMenu = () => {
  showItemsPerPageMenu.value = false;
};

const onItemsPerPageChange = ({ value }) => {
  emit('update:itemsPerPage', value);
  closeItemsPerPageMenu();
};

const currentPageInformation = computed(() => {
  const translationKey = props.currentPageInfo || 'PAGINATION_FOOTER.SHOWING';
  return t(
    translationKey,
    {
      startItem: formatFullNumber(startItem.value),
      endItem: formatFullNumber(endItem.value),
      totalItems: formatCompactNumber(props.totalItems),
    },
    Number(props.totalItems)
  );
});

const pageInfo = computed(() => {
  return t(
    'PAGINATION_FOOTER.CURRENT_PAGE_INFO',
    {
      currentPage: '',
      totalPages: formatCompactNumber(totalPages.value),
    },
    Number(totalPages.value)
  );
});
</script>

<template>
  <div
    class="flex justify-between h-12 w-full max-w-[calc(60rem-3px)] outline outline-n-container outline-1 -outline-offset-1 mx-auto bg-n-solid-2 rounded-xl py-2 ltr:pl-4 rtl:pr-4 ltr:pr-3 rtl:pl-3 items-center before:absolute before:inset-x-0 before:-top-4 before:bg-gradient-to-t before:from-n-surface-1 before:from-10% before:dark:from-0% before:to-transparent before:h-4 before:pointer-events-none"
  >
    <div class="flex items-center gap-3">
      <span class="min-w-0 text-sm font-normal line-clamp-1 text-n-slate-11">
        {{ currentPageInformation }}
      </span>
      <div v-on-click-outside="closeItemsPerPageMenu" class="relative">
        <Button
          variant="ghost"
          size="xs"
          color="slate"
          :label="itemsPerPage.toString()"
          trailing-icon
          icon="i-lucide-chevron-down"
          @click="toggleItemsPerPageMenu"
        />
        <transition
          enter-active-class="transition ease-out duration-100"
          enter-from-class="transform opacity-0 scale-95"
          enter-to-class="transform opacity-100 scale-100"
          leave-active-class="transition ease-in duration-75"
          leave-from-class="transform opacity-100 scale-100"
          leave-to-class="transform opacity-0 scale-95"
        >
          <DropdownMenu
            v-if="showItemsPerPageMenu"
            :menu-items="itemsPerPageOptions"
            class="bottom-8 ltr:left-0 rtl:right-0 mt-2"
            @action="onItemsPerPageChange"
          />
        </transition>
      </div>
    </div>
    <div class="flex items-center gap-2">
      <Button
        icon="i-lucide-chevrons-left"
        variant="ghost"
        size="sm"
        color="slate"
        class="!w-8 !h-6"
        :disabled="isFirstPage"
        @click="changePage(1)"
      />
      <Button
        icon="i-lucide-chevron-left"
        variant="ghost"
        color="slate"
        size="sm"
        class="!w-8 !h-6"
        :disabled="isFirstPage"
        @click="changePage(currentPage - 1)"
      />
      <div class="inline-flex items-center gap-2 text-sm text-n-slate-11">
        <span class="px-3 tabular-nums py-0.5 bg-n-alpha-black2 rounded-md">
          {{ formatFullNumber(currentPage) }}
        </span>
        <span class="truncate">
          {{ pageInfo }}
        </span>
      </div>
      <Button
        icon="i-lucide-chevron-right"
        variant="ghost"
        color="slate"
        size="sm"
        class="!w-8 !h-6"
        :disabled="isLastPage"
        @click="changePage(currentPage + 1)"
      />
      <Button
        icon="i-lucide-chevrons-right"
        variant="ghost"
        color="slate"
        size="sm"
        class="!w-8 !h-6"
        :disabled="isLastPage"
        @click="changePage(totalPages)"
      />
    </div>
  </div>
</template>
