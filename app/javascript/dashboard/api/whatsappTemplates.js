/* global axios */
import ApiClient from './ApiClient';

class WhatsappTemplatesAPI extends ApiClient {
  constructor() {
    super('inboxes', { accountScoped: true });
  }

  getTemplates(inboxId, { status } = {}) {
    let url = `${this.url}/${inboxId}/whatsapp_templates`;
    if (status) {
      url += `?status=${status}`;
    }
    return axios.get(url);
  }

  createTemplate(inboxId, data) {
    return axios.post(`${this.url}/${inboxId}/whatsapp_templates`, {
      template: data,
    });
  }

  updateTemplate(inboxId, templateId, data) {
    return axios.patch(
      `${this.url}/${inboxId}/whatsapp_templates/${templateId}`,
      { template: data }
    );
  }

  deleteTemplate(inboxId, templateId, templateName) {
    return axios.delete(
      `${this.url}/${inboxId}/whatsapp_templates/${templateId}?name=${templateName}`
    );
  }
}

export default new WhatsappTemplatesAPI();
