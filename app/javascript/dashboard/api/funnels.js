/* global axios */
import ApiClient from './ApiClient';

class FunnelsAPI extends ApiClient {
  constructor() {
    super('funnels', { accountScoped: true });
  }

  create(data) {
    return axios.post(this.url, { funnel: data });
  }

  update(id, data) {
    return axios.patch(`${this.url}/${id}`, { funnel: data });
  }

  getContacts(funnelId, stage = null) {
    const params = stage ? { stage } : {};
    return axios.get(`${this.url}/${funnelId}/contacts`, { params });
  }

  moveContact(funnelId, contactId, stage) {
    return axios.patch(`${this.url}/${funnelId}/move_contact`, {
      contact_id: contactId,
      stage,
    });
  }
}

export default new FunnelsAPI();
