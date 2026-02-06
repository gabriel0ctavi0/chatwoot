import WhatsappTemplatesAPI from '../../api/whatsappTemplates';

const state = {
  records: [],
  uiFlags: {
    isFetching: false,
    isCreating: false,
    isUpdating: false,
    isDeleting: false,
  },
};

const getters = {
  getTemplates: $state => $state.records,
  getUIFlags: $state => $state.uiFlags,
  getTemplatesByStatus: $state => status => {
    if (!status) return $state.records;
    return $state.records.filter(
      t => t.status?.toLowerCase() === status.toLowerCase()
    );
  },
};

const actions = {
  async fetch({ commit }, { inboxId } = {}) {
    commit('SET_UI_FLAG', { isFetching: true });
    try {
      const { data } = await WhatsappTemplatesAPI.getTemplates(inboxId);
      commit('SET_TEMPLATES', data.templates || []);
    } catch (error) {
      throw error;
    } finally {
      commit('SET_UI_FLAG', { isFetching: false });
    }
  },

  async create({ commit }, { inboxId, templateData } = {}) {
    commit('SET_UI_FLAG', { isCreating: true });
    try {
      const { data } = await WhatsappTemplatesAPI.createTemplate(
        inboxId,
        templateData
      );
      return data;
    } catch (error) {
      throw error;
    } finally {
      commit('SET_UI_FLAG', { isCreating: false });
    }
  },

  async update({ commit }, { inboxId, templateId, templateData } = {}) {
    commit('SET_UI_FLAG', { isUpdating: true });
    try {
      const { data } = await WhatsappTemplatesAPI.updateTemplate(
        inboxId,
        templateId,
        templateData
      );
      return data;
    } catch (error) {
      throw error;
    } finally {
      commit('SET_UI_FLAG', { isUpdating: false });
    }
  },

  async uploadMedia(_, { inboxId, file } = {}) {
    const { data } = await WhatsappTemplatesAPI.uploadMedia(inboxId, file);
    return data;
  },

  async delete(
    { commit },
    { inboxId, templateId, templateName } = {}
  ) {
    commit('SET_UI_FLAG', { isDeleting: true });
    try {
      await WhatsappTemplatesAPI.deleteTemplate(
        inboxId,
        templateId,
        templateName
      );
      commit('REMOVE_TEMPLATE', templateId);
    } catch (error) {
      throw error;
    } finally {
      commit('SET_UI_FLAG', { isDeleting: false });
    }
  },
};

const mutations = {
  SET_UI_FLAG($state, flag) {
    $state.uiFlags = { ...$state.uiFlags, ...flag };
  },
  SET_TEMPLATES($state, templates) {
    $state.records = templates;
  },
  REMOVE_TEMPLATE($state, templateId) {
    $state.records = $state.records.filter(t => t.id !== templateId);
  },
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations,
};
