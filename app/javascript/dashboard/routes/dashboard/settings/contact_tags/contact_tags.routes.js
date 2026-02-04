import { frontendURL } from '../../../../helper/URLHelper';

import SettingsWrapper from '../SettingsWrapper.vue';
import Index from './Index.vue';

export default {
  routes: [
    {
      path: frontendURL('accounts/:accountId/settings/contact_tags'),
      component: SettingsWrapper,
      children: [
        {
          path: '',
          name: 'contact_tags_wrapper',
          meta: {
            permissions: ['administrator'],
          },
          redirect: to => {
            return { name: 'contact_tags_list', params: to.params };
          },
        },
        {
          path: 'list',
          name: 'contact_tags_list',
          meta: {
            permissions: ['administrator'],
          },
          component: Index,
        },
      ],
    },
  ],
};
