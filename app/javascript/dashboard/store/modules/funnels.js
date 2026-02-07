import * as MutationHelpers from 'shared/helpers/vuex/mutationHelpers';
import types from '../mutation-types';
import FunnelsAPI from '../../api/funnels';

export const state = {
  records: [],
  contacts: [],
  uiFlags: {
    isFetching: false,
    isCreating: false,
    isDeleting: false,
    isFetchingContacts: false,
  },
};

export const getters = {
  getFunnels(_state) {
    return _state.records;
  },
  getUIFlags(_state) {
    return _state.uiFlags;
  },
  getFunnelById: _state => id => {
    return _state.records.find(record => record.id === Number(id));
  },
  getFunnelContacts(_state) {
    return _state.contacts;
  },
};

export const actions = {
  get: async function getFunnels({ commit }) {
    commit(types.SET_FUNNEL_UI_FLAG, { isFetching: true });
    try {
      const response = await FunnelsAPI.get();
      const payload = Array.isArray(response.data.payload)
        ? response.data.payload
        : [];
      commit(types.SET_FUNNELS, payload);
    } catch (error) {
      // handle silently
    } finally {
      commit(types.SET_FUNNEL_UI_FLAG, { isFetching: false });
    }
  },

  create: async function createFunnel({ commit }, payload) {
    commit(types.SET_FUNNEL_UI_FLAG, { isCreating: true });
    try {
      const response = await FunnelsAPI.create(payload);
      commit(types.ADD_FUNNEL, response.data);
      return response.data;
    } catch (error) {
      const errorMessage =
        error?.response?.data?.message ?? error?.message;
      throw new Error(errorMessage);
    } finally {
      commit(types.SET_FUNNEL_UI_FLAG, { isCreating: false });
    }
  },

  update: async function updateFunnel({ commit }, { id, ...updateObj }) {
    commit(types.SET_FUNNEL_UI_FLAG, { isUpdating: true });
    try {
      const response = await FunnelsAPI.update(id, updateObj);
      commit(types.EDIT_FUNNEL, response.data);
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(types.SET_FUNNEL_UI_FLAG, { isUpdating: false });
    }
  },

  delete: async function deleteFunnel({ commit }, id) {
    commit(types.SET_FUNNEL_UI_FLAG, { isDeleting: true });
    try {
      await FunnelsAPI.delete(id);
      commit(types.DELETE_FUNNEL, id);
    } catch (error) {
      throw new Error(error);
    } finally {
      commit(types.SET_FUNNEL_UI_FLAG, { isDeleting: false });
    }
  },

  getContacts: async function getFunnelContacts({ commit }, funnelId) {
    commit(types.SET_FUNNEL_UI_FLAG, { isFetchingContacts: true });
    try {
      const response = await FunnelsAPI.getContacts(funnelId);
      const payload = Array.isArray(response.data.payload)
        ? response.data.payload
        : [];
      commit(types.SET_FUNNEL_CONTACTS, payload);
    } catch (error) {
      // handle silently
    } finally {
      commit(types.SET_FUNNEL_UI_FLAG, { isFetchingContacts: false });
    }
  },

  moveContact: async function moveContact(
    { commit, state: _state },
    { funnelId, contactId, stage }
  ) {
    try {
      await FunnelsAPI.moveContact(funnelId, contactId, stage);
      // Update the local contacts list
      const updatedContacts = _state.contacts.map(contact => {
        if (contact.id === contactId) {
          return { ...contact, funnel_stage: stage };
        }
        return contact;
      });
      commit(types.SET_FUNNEL_CONTACTS, updatedContacts);
    } catch (error) {
      throw new Error(error);
    }
  },
};

export const mutations = {
  [types.SET_FUNNEL_UI_FLAG](_state, data) {
    _state.uiFlags = {
      ..._state.uiFlags,
      ...data,
    };
  },

  [types.SET_FUNNELS]: MutationHelpers.set,
  [types.ADD_FUNNEL]: MutationHelpers.create,
  [types.EDIT_FUNNEL]: MutationHelpers.update,
  [types.DELETE_FUNNEL]: MutationHelpers.destroy,
  [types.SET_FUNNEL_CONTACTS](_state, data) {
    _state.contacts = data;
  },
};

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations,
};
