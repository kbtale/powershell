import DefaultTheme from 'vitepress/theme'
import Layout from './Layout.vue'
import './custom.css'
import Playground from './components/Playground.vue'

export default {
  extends: DefaultTheme,
  Layout,
  enhanceApp({ app }) {
    app.component('Playground', Playground)
  }
}
