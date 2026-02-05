import * as MutationHelpers from 'shared/helpers/vuex/mutationHelpers';
import types from '../mutation-types';
import ContactTagsAPI from '../../api/contactTags';

export const state = {
  records: [],
  uiFlags: {
    isFetching: false,
    isFetchingItem: false,
    isCreating: false,
    isDeleting: false,
  },
};

export const getters = {
  getContactTags(_state) {
    return _state.records;
  },
  getUIFlags(_state) {
    return _state.uiFlags;
  },
  getContactTagsOnSidebar(_state) {
    return _state.records
      .filter(record => record.show_on_sidebar)
      .sort((a, b) => a.title.localeCompare(b.title));
  },
  getContactTagById: _state => id => {
    return _state.records.find(record => record.id === Number(id));
  },
};

export const actions = {
  get: async function getContactTags({ commit }) {
    commit(types.SET_CONTACT_TAG_UI_FLAG, { isFetching: true });
    try {
      const response = await ContactTagsAPI.get();
      const payload = Array.isArray(response.data.payload)
        ? response.data.payload
        : [];
      const sorted = payload.sort((a, b) => a.title.localeCompare(b.title));
      commit(types.SET_CONTACT_TAGS, sorted);
    } catch (error) {
      console.error('[ContactTags GET]', {
        status: error?.response?.status,
        data: error?.response?.data,
        message: error?.message,
      });
    } finally {
      commit(types.SET_CONTACT_TAG_UI_FLAG, { isFetching: false });
    }
  },

  create: async function createContactTag({ commit }, payload) {
    commit(types.SET_CONTACT_TAG_UI_FLAG, { isCreating: true });
    try {
      const response = await ContactTagsAPI.create(payload);
      commit(types.ADD_CONTACT_TAG, response.data);
      return response.data;
    } catch (error) {
      console.error('[ContactTags CREATE]', {
        status: error?.response?.status,
        data: error?.response?.data,
        message: error?.message,
      });
      const errorMessage = error?.response?.data?.message ?? error?.response?.data?.error ?? error?.message;
      throw new Error(errorMessage);
    } finally {
      commit(types.SET_CONTACT_TAG_UI_FLAG, { isCreating: false });
    }
  },

  update: async function updateContactTag({ commit }, { id, ...updateObj }) {
    commit(types.SET_CONTACT_TAG_UI_FLAG, { isUpdating: true });
    try {
      const response = await ContactTagsAPI.update(id, updateObj);
      commit(types.EDIT_CONTACT_TAG, response.data);
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(types.SET_CONTACT_TAG_UI_FLAG, { isUpdating: false });
    }
  },

  delete: async function deleteContactTag({ commit }, id) {
    commit(types.SET_CONTACT_TAG_UI_FLAG, { isDeleting: true });
    try {
      await ContactTagsAPI.delete(id);
      commit(types.DELETE_CONTACT_TAG, id);
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(types.SET_CONTACT_TAG_UI_FLAG, { isDeleting: false });
    }
  },
};

export const mutations = {
  [types.SET_CONTACT_TAG_UI_FLAG](_state, data) {
    _state.uiFlags = {
      ..._state.uiFlags,
      ...data,
    };
  },

  [types.SET_CONTACT_TAGS]: MutationHelpers.set,
  [types.ADD_CONTACT_TAG]: MutationHelpers.create,
  [types.EDIT_CONTACT_TAG]: MutationHelpers.update,
  [types.DELETE_CONTACT_TAG]: MutationHelpers.destroy,
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations,
};
