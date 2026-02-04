/* global axios */
import ApiClient from './ApiClient';

class ContactTagsAPI extends ApiClient {
  constructor() {
    super('contact_tags', { accountScoped: true });
  }

  create(data) {
    return axios.post(this.url, { contact_tag: data });
  }

  update(id, data) {
    return axios.patch(`${this.url}/${id}`, { contact_tag: data });
  }
}

export default new ContactTagsAPI();
