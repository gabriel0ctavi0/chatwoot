<script setup>
import { ref } from 'vue';
import { useI18n } from 'vue-i18n';

import Button from 'dashboard/components-next/button/Button.vue';
import DropdownMenu from 'dashboard/components-next/dropdown-menu/DropdownMenu.vue';

const emit = defineEmits(['add', 'import', 'export', 'message']);

const { t } = useI18n();

const contactMenuItems = [
  {
    label: t('CONTACTS_LAYOUT.HEADER.MESSAGE_BUTTON'),
    action: 'message',
    value: 'message',
    icon: 'i-lucide-message-circle',
  },
  {
    label: t('CONTACTS_LAYOUT.HEADER.ACTIONS.CONTACT_CREATION.EXPORT_CONTACT'),
    action: 'export',
    value: 'export',
    icon: 'i-lucide-upload',
  },
  {
    label: t('CONTACTS_LAYOUT.HEADER.ACTIONS.CONTACT_CREATION.IMPORT_CONTACT'),
    action: 'import',
    value: 'import',
    icon: 'i-lucide-download',
  },
];
const showActionsDropdown = ref(false);

const handleContactAction = ({ action }) => {
  if (action === 'import') {
    emit('import');
  } else if (action === 'export') {
    emit('export');
  } else if (action === 'message') {
    emit('message');
  }
};
</script>

<template>
  <div v-on-clickaway="() => (showActionsDropdown = false)" class="relative">
    <Button
      icon="i-lucide-ellipsis-vertical"
      color="slate"
      variant="ghost"
      size="sm"
      :class="showActionsDropdown ? 'bg-n-alpha-2' : ''"
      @click="showActionsDropdown = !showActionsDropdown"
    />
    <DropdownMenu
      v-if="showActionsDropdown"
      :menu-items="contactMenuItems"
      class="ltr:right-0 rtl:left-0 mt-1 w-52 top-full"
      @action="handleContactAction($event)"
    />
  </div>
</template>
