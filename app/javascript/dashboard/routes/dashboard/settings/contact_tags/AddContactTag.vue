<script>
import { mapGetters } from 'vuex';
import { useAlert } from 'dashboard/composables';
import validations, { getTagTitleErrorMessage } from './validations';
import { getRandomColor } from 'dashboard/helper/labelColor';
import { useVuelidate } from '@vuelidate/core';

import NextButton from 'dashboard/components-next/button/Button.vue';

export default {
  components: {
    NextButton,
  },
  props: {
    prefillTitle: {
      type: String,
      default: '',
    },
  },
  emits: ['close'],
  setup() {
    return { v$: useVuelidate() };
  },
  data() {
    return {
      color: '#000',
      description: '',
      title: '',
      showOnSidebar: true,
    };
  },
  validations,
  computed: {
    ...mapGetters({
      uiFlags: 'contactTags/getUIFlags',
    }),
    labelTitleErrorMessage() {
      const errorMessage = getTagTitleErrorMessage(this.v$);
      return this.$t(errorMessage);
    },
  },
  mounted() {
    this.color = getRandomColor();
    this.title = this.prefillTitle.toLowerCase();
  },
  methods: {
    onClose() {
      this.$emit('close');
    },
    async addTag() {
      try {
        await this.$store.dispatch('contactTags/create', {
          color: this.color,
          description: this.description,
          title: this.title.toLowerCase(),
          show_on_sidebar: this.showOnSidebar,
        });
        useAlert(this.$t('TAG_MGMT.ADD.API.SUCCESS_MESSAGE'));
        this.onClose();
      } catch (error) {
        const errorMessage =
          error.message || this.$t('TAG_MGMT.ADD.API.ERROR_MESSAGE');
        useAlert(errorMessage);
      }
    },
  },
};
</script>

<template>
  <div class="flex flex-col h-auto overflow-auto">
    <woot-modal-header
      :header-title="$t('TAG_MGMT.ADD.TITLE')"
      :header-content="$t('TAG_MGMT.ADD.DESC')"
    />
    <form class="flex flex-wrap mx-0" @submit.prevent="addTag">
      <woot-input
        v-model="title"
        :class="{ error: v$.title.$error }"
        class="w-full tag-name--input"
        :label="$t('TAG_MGMT.FORM.NAME.LABEL')"
        :placeholder="$t('TAG_MGMT.FORM.NAME.PLACEHOLDER')"
        :error="labelTitleErrorMessage"
        data-testid="tag-title"
        @input="v$.title.$touch"
        @blur="v$.title.$touch"
      />

      <woot-input
        v-model="description"
        :class="{ error: v$.description.$error }"
        class="w-full"
        :label="$t('TAG_MGMT.FORM.DESCRIPTION.LABEL')"
        :placeholder="$t('TAG_MGMT.FORM.DESCRIPTION.PLACEHOLDER')"
        data-testid="tag-description"
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
        <label for="tag_show_on_sidebar">
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
          data-testid="tag-submit"
          :label="$t('TAG_MGMT.FORM.CREATE')"
          :disabled="v$.title.$invalid || uiFlags.isCreating"
          :is-loading="uiFlags.isCreating"
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
