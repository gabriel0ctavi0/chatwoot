import { frontendURL } from 'dashboard/helper/URLHelper.js';

import TemplatesPageRouteView from './pages/TemplatesPageRouteView.vue';
import TemplatesPage from 'dashboard/components-next/whatsapp/templates/TemplatesPage.vue';

export const routes = [
  {
    path: frontendURL('accounts/:accountId/templates'),
    component: TemplatesPageRouteView,
    children: [
      {
        path: '',
        name: 'whatsapp_templates_index',
        meta: {
          permissions: ['administrator'],
        },
        component: TemplatesPage,
      },
    ],
  },
];
