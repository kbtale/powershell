import DefaultTheme from 'vitepress/theme'
import Layout from './Layout.vue'
import './custom.css'
import Playground from './components/Playground.vue'
import HomeFeatures from './components/HomeFeatures.vue'
import HomeDemo from './components/HomeDemo.vue'

export default {
  extends: DefaultTheme,
  Layout,
  enhanceApp({ app }) {
    app.component('Playground', Playground)
    app.component('HomeFeatures', HomeFeatures)
    app.component('HomeDemo', HomeDemo)
  }
}
