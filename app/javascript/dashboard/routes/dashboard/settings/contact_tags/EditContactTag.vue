<script>
import { mapGetters } from 'vuex';
import { useAlert } from 'dashboard/composables';
import validations, { getTagTitleErrorMessage } from './validations';
import { useVuelidate } from '@vuelidate/core';

import NextButton from 'dashboard/components-next/button/Button.vue';

export default {
  components: {
    NextButton,
  },
  props: {
    selectedResponse: {
      type: Object,
      default: () => ({}),
    },
  },
  emits: ['close'],
  setup() {
    return { v$: useVuelidate() };
  },
  data() {
    return {
      title: '',
      description: '',
      showOnSidebar: true,
      color: '',
    };
  },
  validations,
  computed: {
    ...mapGetters({
      uiFlags: 'contactTags/getUIFlags',
    }),
    pageTitle() {
      return `${this.$t('TAG_MGMT.EDIT.TITLE')} - ${
        this.selectedResponse.title
      }`;
    },
    labelTitleErrorMessage() {
      const errorMessage = getTagTitleErrorMessage(this.v$);
      return this.$t(errorMessage);
    },
  },
  mounted() {
    this.setFormValues();
  },
  methods: {
    onClose() {
      this.$emit('close');
    },
    setFormValues() {
      this.title = this.selectedResponse.title;
      this.description = this.selectedResponse.description;
      this.showOnSidebar = this.selectedResponse.show_on_sidebar;
      this.color = this.selectedResponse.color;
    },
    editTag() {
      this.$store
        .dispatch('contactTags/update', {
          id: this.selectedResponse.id,
          color: this.color,
          description: this.description,
          title: this.title.toLowerCase(),
          show_on_sidebar: this.showOnSidebar,
        })
        .then(() => {
          useAlert(this.$t('TAG_MGMT.EDIT.API.SUCCESS_MESSAGE'));
          setTimeout(() => this.onClose(), 10);
        })
        .catch(() => {
          useAlert(this.$t('TAG_MGMT.EDIT.API.ERROR_MESSAGE'));
        });
    },
  },
};
</script>

<template>
  <div class="flex flex-col h-auto overflow-auto">
    <woot-modal-header :header-title="pageTitle" />
    <form class="flex flex-wrap mx-0" @submit.prevent="editTag">
      <woot-input
        v-model="title"
        :class="{ error: v$.title.$error }"
        class="w-full tag-name--input"
        :label="$t('TAG_MGMT.FORM.NAME.LABEL')"
        :placeholder="$t('TAG_MGMT.FORM.NAME.PLACEHOLDER')"
        :error="labelTitleErrorMessage"
        @input="v$.title.$touch"
        @blur="v$.title.$touch"
      />
      <woot-input
        v-model="description"
        :class="{ error: v$.description.$error }"
        class="w-full"
        :label="$t('TAG_MGMT.FORM.DESCRIPTION.LABEL')"
        :placeholder="$t('TAG_MGMT.FORM.DESCRIPTION.PLACEHOLDER')"
        @input="v$.description.$touch"
        @blur="v$.description.$touch"
      />

      <div class="w-full">
        <label>
          {{ $t('TAG_MGMT.FORM.COLOR.LABEL') }}
          <woot-color-picker v-model="color" />
        </label>
      </div>
      <div class="flex items-center w-full gap-2">
        <input v-model="showOnSidebar" type="checkbox" :value="true" />
        <label for="tag_show_on_sidebar_edit">
          {{ $t('TAG_MGMT.FORM.SHOW_ON_SIDEBAR.LABEL') }}
        </label>
      </div>
      <div class="flex items-center justify-end w-full gap-2 px-0 py-2">
        <NextButton
          faded
          slate
          type="reset"
          :label="$t('TAG_MGMT.FORM.CANCEL')"
          @click.prevent="onClose"
        />
        <NextButton
          type="submit"
          :label="$t('TAG_MGMT.FORM.EDIT')"
          :disabled="v$.title.$invalid || uiFlags.isUpdating"
          :is-loading="uiFlags.isUpdating"
        />
      </div>
    </form>
  </div>
</template>

<style lang="scss" scoped>
.tag-name--input {
  ::v-deep {
    input {
      @apply lowercase;
    }
  }
}
</style>
