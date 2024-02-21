import MainLayout from './layouts/main.vue'
import PageNotFound from './views/NotFound.vue'
import PowerShellPage from './views/PowerShell.vue'

const routes = [
    {
        path: '/',
        component: MainLayout,
        redirect: '/',
        name: 'Main',
        children: [
          {
            path: 'powershell',
            component: PowerShellPage,
          },
          {
            path: '/:catchAll(.*)',
            component: PageNotFound,
          },
        ],
    },
    { path: '/:catchAll(.*)', component: PageNotFound }
]

export default routes;