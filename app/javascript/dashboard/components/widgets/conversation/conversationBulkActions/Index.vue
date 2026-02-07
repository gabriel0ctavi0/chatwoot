<script>
import NextButton from 'dashboard/components-next/button/Button.vue';
import AgentSelector from './AgentSelector.vue';
import LabelActions from './LabelActions.vue';
import TeamActions from './TeamActions.vue';
export default {
  components: {
    AgentSelector,
    LabelActions,
    TeamActions,
    NextButton,
  },
  props: {
    conversations: {
      type: Array,
      default: () => [],
    },
    allConversationsSelected: {
      type: Boolean,
      default: false,
    },
    selectedInboxes: {
      type: Array,
      default: () => [],
    },
  },
  emits: [
    'selectAllConversations',
    'assignAgent',
    'assignLabels',
    'assignTeam',
  ],
  data() {
    return {
      showAgentsList: false,
      showLabelActions: false,
      showTeamsList: false,
    };
  },
  methods: {
    selectAll(e) {
      this.$emit('selectAllConversations', e.target.checked);
    },
    submit(agent) {
      this.$emit('assignAgent', agent);
    },
    assignLabels(labels) {
      this.$emit('assignLabels', labels);
    },
    assignTeam(team) {
      this.$emit('assignTeam', team);
    },
    toggleLabelActions() {
      this.showLabelActions = !this.showLabelActions;
    },
    toggleAgentList() {
      this.showAgentsList = !this.showAgentsList;
    },
    toggleTeamsList() {
      this.showTeamsList = !this.showTeamsList;
    },
  },
};
</script>

<template>
  <div class="bulk-action__container">
    <div class="flex items-center justify-between">
      <label class="flex items-center justify-between bulk-action__panel">
        <input
          type="checkbox"
          class="checkbox"
          :checked="allConversationsSelected"
          :indeterminate.prop="!allConversationsSelected"
          @change="selectAll($event)"
        />
        <span>
          {{
            $t('BULK_ACTION.CONVERSATIONS_SELECTED', {
              conversationCount: conversations.length,
            })
          }}
        </span>
      </label>
      <div class="flex items-center gap-1 bulk-action__actions">
        <NextButton
          v-tooltip="$t('BULK_ACTION.LABELS.ASSIGN_LABELS')"
          icon="i-lucide-tags"
          slate
          xs
          faded
          @click="toggleLabelActions"
        />
        <NextButton
          v-tooltip="$t('BULK_ACTION.ASSIGN_AGENT_TOOLTIP')"
          icon="i-lucide-user-round-plus"
          slate
          xs
          faded
          @click="toggleAgentList"
        />
        <NextButton
          v-tooltip="$t('BULK_ACTION.ASSIGN_TEAM_TOOLTIP')"
          icon="i-lucide-users-round"
          slate
          xs
          faded
          @click="toggleTeamsList"
        />
      </div>
      <transition name="popover-animation">
        <LabelActions
          v-if="showLabelActions"
          class="label-actions-box"
          @assign="assignLabels"
          @close="showLabelActions = false"
        />
      </transition>
      <transition name="popover-animation">
        <AgentSelector
          v-if="showAgentsList"
          class="agent-actions-box"
          :selected-inboxes="selectedInboxes"
          :conversation-count="conversations.length"
          @select="submit"
          @close="showAgentsList = false"
        />
      </transition>
      <transition name="popover-animation">
        <TeamActions
          v-if="showTeamsList"
          class="team-actions-box"
          @assign-team="assignTeam"
          @close="showTeamsList = false"
        />
      </transition>
    </div>
    <div v-if="allConversationsSelected" class="bulk-action__alert">
      {{ $t('BULK_ACTION.ALL_CONVERSATIONS_SELECTED_ALERT') }}
    </div>
  </div>
</template>

<style scoped lang="scss">
.bulk-action__container {
  @apply p-3 relative border-b border-solid border-n-strong dark:border-n-weak;
}

.bulk-action__panel {
  @apply cursor-pointer;

  span {
    @apply text-xs my-0 mx-1;
  }

  input[type='checkbox'] {
    @apply cursor-pointer m-0;
  }
}

.bulk-action__alert {
  @apply bg-n-amber-3 text-n-amber-12 rounded text-xs mt-2 py-1 px-2 border border-solid border-n-amber-5;
}

.popover-animation-enter-active,
.popover-animation-leave-active {
  transition: transform ease-out 0.1s;
}

.popover-animation-enter {
  transform: scale(0.95);
  @apply opacity-0;
}

.popover-animation-enter-to {
  transform: scale(1);
  @apply opacity-100;
}

.popover-animation-leave {
  transform: scale(1);
  @apply opacity-100;
}

.popover-animation-leave-to {
  transform: scale(0.95);
  @apply opacity-0;
}

.label-actions-box {
  --triangle-position: 5.3125rem;
}
.agent-actions-box {
  --triangle-position: 1.75rem;
}
.team-actions-box {
  --triangle-position: 0.125rem;
}
</style>
