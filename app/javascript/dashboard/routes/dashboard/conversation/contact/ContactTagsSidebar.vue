<script setup>
import { computed, watch, onMounted } from 'vue';
import { useI18n } from 'vue-i18n';
import { useMapGetter, useStore } from 'dashboard/composables/store';
import TagMultiSelectComboBox from 'dashboard/components-next/combobox/TagMultiSelectComboBox.vue';

const { t } = useI18n();
const store = useStore();

const currentChat = useMapGetter('getSelectedChat');
const contactGetter = useMapGetter('contacts/getContact');
const allContactTags = useMapGetter('contactTags/getContactTags');

const contactId = computed(() => currentChat.value?.meta?.sender?.id ?? null);
const contact = computed(() =>
  contactId.value ? contactGetter.value(contactId.value) : {}
);

const contactTagList = computed(() => {
  const raw =
    contact.value?.contact_tag_list ?? contact.value?.contactTagList ?? [];
  return Array.isArray(raw) ? raw : [];
});

const tagOptions = computed(() =>
  (allContactTags.value || []).map(({ title }) => ({
    label: title,
    value: title,
  }))
);

const handleTagListChange = value => {
  if (!contactId.value) return;
  store.dispatch('contacts/update', {
    id: contactId.value,
    contactTagList: value ?? [],
  });
};

onMounted(() => {
  store.dispatch('contactTags/get');
});

watch(contactId, id => {
  if (id) store.dispatch('contactTags/get');
});
</script>

<template>
  <div v-if="contactId" class="sidebar-tags-wrap">
    <div class="contact-conversation--list">
      <div class="label-wrap flex flex-wrap">
        <TagMultiSelectComboBox
          :model-value="contactTagList"
          :options="tagOptions"
          :placeholder="t('CONTACTS_LAYOUT.CARD.EDIT_DETAILS_FORM.FORM.TAGS.PLACEHOLDER')"
          @update:model-value="handleTagListChange"
        />
      </div>
    </div>
  </div>
</template>

<style lang="scss" scoped>
.sidebar-tags-wrap {
  margin-bottom: 0;
}
.contact-conversation--list {
  width: 100%;

  .label-wrap {
    line-height: 1.5rem;
    position: relative;
  }
}
</style>
