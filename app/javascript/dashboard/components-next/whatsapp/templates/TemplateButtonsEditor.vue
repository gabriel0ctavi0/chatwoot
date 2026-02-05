<script setup>
import { useI18n } from 'vue-i18n';

import Button from 'dashboard/components-next/button/Button.vue';
import Input from 'dashboard/components-next/input/Input.vue';
import Icon from 'dashboard/components-next/icon/Icon.vue';

const props = defineProps({
  modelValue: { type: Array, default: () => [] },
});

const emit = defineEmits(['update:modelValue']);

const { t } = useI18n();

const MAX_BUTTONS = 3;

const BUTTON_TYPE_OPTIONS = [
  {
    value: 'QUICK_REPLY',
    label: 'WHATSAPP_TEMPLATES_MGMT.CREATE.FORM.BUTTONS.TYPE.QUICK_REPLY',
  },
  {
    value: 'URL',
    label: 'WHATSAPP_TEMPLATES_MGMT.CREATE.FORM.BUTTONS.TYPE.URL',
  },
  {
    value: 'PHONE_NUMBER',
    label: 'WHATSAPP_TEMPLATES_MGMT.CREATE.FORM.BUTTONS.TYPE.PHONE_NUMBER',
  },
];

const addButton = () => {
  if (props.modelValue.length >= MAX_BUTTONS) return;
  emit('update:modelValue', [
    ...props.modelValue,
    { type: 'QUICK_REPLY', text: '', url: '', phone_number: '' },
  ]);
};

const removeButton = index => {
  const updated = [...props.modelValue];
  updated.splice(index, 1);
  emit('update:modelValue', updated);
};

const updateButton = (index, field, value) => {
  const updated = props.modelValue.map((btn, i) =>
    i === index ? { ...btn, [field]: value } : btn
  );
  emit('update:modelValue', updated);
};
</script>

<template>
  <div class="flex flex-col gap-3">
    <div class="flex items-center justify-between">
      <label class="text-sm font-medium text-n-slate-12">
        {{ t('WHATSAPP_TEMPLATES_MGMT.CREATE.FORM.BUTTONS.LABEL') }}
      </label>
      <Button
        v-if="modelValue.length < MAX_BUTTONS"
        :label="t('WHATSAPP_TEMPLATES_MGMT.CREATE.FORM.BUTTONS.ADD')"
        icon="i-lucide-plus"
        size="xs"
        variant="faded"
        color="slate"
        @click="addButton"
      />
    </div>
    <p
      v-if="modelValue.length >= MAX_BUTTONS"
      class="mb-0 text-xs text-n-slate-10"
    >
      {{ t('WHATSAPP_TEMPLATES_MGMT.CREATE.FORM.BUTTONS.MAX_REACHED') }}
    </p>
    <div
      v-for="(btn, idx) in modelValue"
      :key="idx"
      class="flex flex-col gap-2 rounded-lg bg-n-alpha-1 p-3"
    >
      <div class="flex items-center justify-between">
        <div class="flex items-center gap-2">
          <Icon icon="i-lucide-grip-vertical" class="size-4 text-n-slate-9" />
          <select
            :value="btn.type"
            class="rounded-md bg-n-solid-3 px-2 py-1 text-xs text-n-slate-12 outline outline-n-weak focus:outline-n-brand"
            @change="updateButton(idx, 'type', $event.target.value)"
          >
            <option
              v-for="opt in BUTTON_TYPE_OPTIONS"
              :key="opt.value"
              :value="opt.value"
            >
              {{ t(opt.label) }}
            </option>
          </select>
        </div>
        <Button
          icon="i-lucide-trash-2"
          size="xs"
          variant="ghost"
          color="ruby"
          @click="removeButton(idx)"
        />
      </div>
      <Input
        :model-value="btn.text"
        :label="t('WHATSAPP_TEMPLATES_MGMT.CREATE.FORM.BUTTONS.TEXT.LABEL')"
        :placeholder="
          t('WHATSAPP_TEMPLATES_MGMT.CREATE.FORM.BUTTONS.TEXT.PLACEHOLDER')
        "
        size="sm"
        @update:model-value="updateButton(idx, 'text', $event)"
      />
      <Input
        v-if="btn.type === 'URL'"
        :model-value="btn.url"
        :label="t('WHATSAPP_TEMPLATES_MGMT.CREATE.FORM.BUTTONS.URL.LABEL')"
        :placeholder="
          t('WHATSAPP_TEMPLATES_MGMT.CREATE.FORM.BUTTONS.URL.PLACEHOLDER')
        "
        size="sm"
        @update:model-value="updateButton(idx, 'url', $event)"
      />
      <Input
        v-if="btn.type === 'PHONE_NUMBER'"
        :model-value="btn.phone_number"
        :label="t('WHATSAPP_TEMPLATES_MGMT.CREATE.FORM.BUTTONS.PHONE.LABEL')"
        :placeholder="
          t('WHATSAPP_TEMPLATES_MGMT.CREATE.FORM.BUTTONS.PHONE.PLACEHOLDER')
        "
        size="sm"
        @update:model-value="updateButton(idx, 'phone_number', $event)"
      />
    </div>
  </div>
</template>
