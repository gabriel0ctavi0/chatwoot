import { frontendURL } from '../../../helper/URLHelper';

const FunnelsIndexPage = () => import('./pages/FunnelsIndexPage.vue');

export const routes = [
  {
    path: frontendURL('accounts/:accountId/funnels'),
    name: 'funnels_index',
    meta: {
      permissions: ['administrator', 'agent'],
    },
    component: FunnelsIndexPage,
  },
];
