import { reactive } from 'vue'
import * as Vue from 'vue'
import axios from 'axios'
import md5 from 'js-md5'
import i18n from '../i18n'

function mergeLocaleMessage(key, locales) {
  for (const locale in locales) {
    const messages = i18n.global.getLocaleMessage(locale)
    if (!messages.menus)
      messages.menus = {}
    messages.menus[key] = locales[locale]
  }
}

class Oui {
  constructor() {
    window.Vue = Vue
    this.menus = null
    this.inited = false
    this.state = reactive({
      locale: '',
      theme: '',
      hostname: ''
    })
  }

  async rpc(method, param) {
    const { data } = await axios.post('/oui-rpc', { method, param })
    return data
  }

  async call(mod, func, param) {
    const { result } = await this.rpc('call', [mod, func, param ?? {}])
    return result
  }

  ubus(obj, method, param) {
    return this.call('ubus', 'call', {object: obj, method, param})
  }

  reloadConfig(config) {
    return this.ubus('service', 'event', { type: 'config.change', data: { package: config }})
  }

  async login(username, password) {
    const { nonce } = await this.rpc('challenge', { username })
    const hash1 = md5(`${username}:${password}`)
    const hash2 = md5(`${hash1}:${nonce}`)
    return this.rpc('login', { username, password: hash2 })
  }

  logout() {
    this.menus = null
    return this.rpc('logout')
  }

  async isAuthenticated() {
    const { authenticated } = await this.rpc('authenticated')
    return authenticated
  }

  async init() {
    if (this.state.locale)
      return

    let { locale } = await this.call('ui', 'get_locale')

    if (!locale)
      locale = 'auto'

    this.state.locale = locale

    if (locale === 'auto')
      i18n.global.locale = navigator.language
    else
      i18n.global.locale = locale

    const { theme } = await this.call('ui', 'get_theme')
    this.state.theme = theme
  }

  async initWithAuthed() {
    if (this.state.hostname)
      return

    const { hostname } = await this.ubus('system', 'board')
    this.state.hostname = hostname
  }

  parseMenus(raw) {
    const menus = {}

    for (const path in raw) {
      const paths = path.split('/')
      if (paths.length === 2)
        menus[path] = raw[path]
    }

    for (const path in raw) {
      const paths = path.split('/')
      if (paths.length === 3) {
        const parent = menus['/' + paths[1]]
        if (!parent || parent.view)
          continue

        if (!parent.children)
          parent.children = {}

        parent.children[path] = raw[path]
        parent.children[path].parent = parent
      }
    }

    const menusArray = []

    for (const path in menus) {
      const m = menus[path]
      if (m.view || m.children) {
        menusArray.push({
          path: path,
          ...m
        })

        mergeLocaleMessage(m.title, m.locales)
      }
    }

    menusArray.sort((a, b) => (a.index ?? 0) - (b.index ?? 0))

    menusArray.forEach(m => {
      if (!m.children)
        return

      const children = []

      for (const path in m.children) {
        const c = m.children[path]
        children.push({
          path: path,
          ...c
        })

        mergeLocaleMessage(c.title, c.locales)
      }

      children.sort((a, b) => (a.index ?? 0) - (b.index ?? 0))

      m.children = children
    })

    return menusArray
  }

  async loadMenus() {
    if (this.menus)
      return this.menus
    const { menus } = await this.call('ui', 'get_menus')
    this.menus = this.parseMenus(menus)
    return this.menus
  }

  async setLocale(locale) {
    if (locale !== 'auto' && !i18n.global.availableLocales.includes(locale))
      return

    await this.call('uci', 'set', { config: 'oui', section: 'global', values: { locale }})

    this.state.locale = locale

    if (locale === 'auto')
      i18n.global.locale = navigator.language
    else
      i18n.global.locale = locale
  }

  async setTheme(theme) {
    await this.call('uci', 'set', { config: 'oui', section: 'global', values: { theme }})
    this.state.theme = theme
  }

  async setHostname(hostname) {
    await this.call('uci', 'set', { config: 'system', section: '@system[0]', values: { hostname }})
    await this.reloadConfig('system')
    this.state.hostname = hostname
  }

  reconnect(delay) {
    return new Promise(resolve => {
      let interval

      const img = document.createElement('img')

      img.addEventListener('load', () => {
        window.clearInterval(interval)
        img.remove()
        resolve()
      })

      window.setTimeout(() => {
        interval = window.setInterval(() => {
          img.src = '/favicon.ico?r=' + Math.random()
        }, 1000)
      }, delay || 5000)
    })
  }

  install(app) {
    app.config.globalProperties.$oui = this
    app.config.globalProperties.$md5 = md5
  }
}

export default new Oui()
