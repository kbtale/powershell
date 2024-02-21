import { createApp } from 'vue'
import { createI18n } from 'vue-i18n'
import { createRouter, createWebHashHistory } from 'vue-router'
import './style.css'
import App from './App.vue'
import routes from './routes.js' 

const i18n = createI18n({
    // some vue-i18n options here ...
  })
  
  const router = createRouter({
    history: createWebHashHistory(),
    routes, // short for `routes: routes`
  })

  const app = createApp(App)
  
  app.use(i18n)
  app.use(router)
  app.mount('#app')
  
