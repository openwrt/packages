<template>
  <n-layout has-sider position="absolute">
    <n-layout-sider content-style="padding: 10px;" bordered :native-scrollbar="false">
      <div class="logo-name">
        <router-link to="/">
          <n-el tag="span" style="color: var(--info-color);">{{ $oui.state.hostname }}</n-el>
        </router-link>
      </div>
      <n-divider/>
      <n-menu ref="menu" :options="menuOptions" accordion
          :expanded-keys="expandedMenus" :value="selectedMenu"
          @update:value="clickMenuItem" @update:expanded-keys="menuExpanded"/>
    </n-layout-sider>
    <n-layout position="absolute" style="left: 272px;">
      <n-layout-header position="absolute" bordered style="padding: 4px">
        <n-space justify="end" size="large">
          <n-tooltip placement="bottom">
            <template #trigger>
              <n-switch v-model:value="darkTheme" :rail-style="() => 'background-color: #000e1c'">
                <template #checked><n-icon size="14" color="#ffd93b"><sunny-sharp-icon/></n-icon></template>
                <template #unchecked><n-icon size="14" color="#ffd93b"><moon-icon/></n-icon></template>
              </n-switch>
            </template>
            <span>{{ $t((darkTheme ? 'Dark' : 'Light') + ' theme') }}</span>
          </n-tooltip>
          <n-dropdown :options="localeOptions" @select="key => $oui.setLocale(key)" :render-icon="renderLocaleIcon">
            <n-button text><n-icon size="25" color="#0e7a0d"><translate-icon/></n-icon></n-button>
          </n-dropdown>
          <n-dropdown :options="userOptions" @select="handleUserAction">
            <n-button text><n-icon size="25" color="#0e7a0d"><user-icon/></n-icon></n-button>
          </n-dropdown>
        </n-space>
      </n-layout-header>
      <n-layout-content embedded position="absolute" style="top: 40px; bottom: 42px" content-style="padding: 10px;" :native-scrollbar="false">
        <router-view>
          <template #default="{ Component }">
            <transition name="zoom-fade" mode="out-in">
              <div :key="$route.path">
                <component :is="Component"/>
              </div>
            </transition>
          </template>
        </router-view>
        <n-back-top/>
      </n-layout-content>
      <n-layout-footer position="absolute" bordered style="padding: 4px">
        <div class="copyright">
          <n-text type="info">Copyright © 2022 Powered by </n-text>
          <n-a href="https://github.com/zhaojh329/oui" target="_blank">oui</n-a>
        </div>
      </n-layout-footer>
    </n-layout>
  </n-layout>
  <n-modal v-model:show="modalSpin" :close-on-esc="false" :mask-closable="false">
    <n-spin size="large">
      <template #description>
        <n-el style="color: var(--primary-color)">{{ $t('Rebooting') }}...</n-el>
      </template>
    </n-spin>
  </n-modal>
</template>

<script>
import { h, resolveComponent } from 'vue'

import {
  Translate as TranslateIcon
} from '@vicons/carbon'

import {
  PersonCircleOutline as UserIcon,
  LogOutOutline as LogoutIcon,
  PowerSharp as PowerSharpIcon,
  ChevronForward as ChevronForwardIcon,
  Moon as MoonIcon,
  SunnySharp as SunnySharpIcon
} from '@vicons/ionicons5'

function renderIcon(icon) {
  return () => h(resolveComponent('n-icon'), () => h(icon))
}

function renderSvg(el, opt) {
  const props = {}
  const children = []

  Object.keys(opt).forEach(key => {
    if (key.startsWith('-')) {
      props[key.substring(1)] = opt[key]
    } else {
      if (Array.isArray(opt[key]))
        opt[key].forEach(item => children.push(renderSvg(key, item)))
      else
        children.push(renderSvg(key, opt[key]))
    }
  })

  return h(el, props, children)
}

function renderIconSvg(opt) {
  return () => h(resolveComponent('n-icon'), () => renderSvg('svg', opt ?? {}))
}

export default {
  props: {
    menus: Array
  },
  components: {
    TranslateIcon,
    UserIcon,
    MoonIcon,
    SunnySharpIcon
  },
  data() {
    return {
      modalSpin: false,
      expandedMenus: [],
      selectedMenu: '',
      userOptions: [
        {
          key: 'logout',
          label: () => this.$t('Logout'),
          icon: renderIcon(LogoutIcon)
        },
        {
          key: 'reboot',
          label: () => this.$t('Reboot'),
          icon: renderIcon(PowerSharpIcon)
        }
      ]
    }
  },
  computed: {
    menuOptions() {
      return this.menus.map(m => {
        if (m.children) {
          return {
            label: this.$t('menus.' + m.title),
            key: m.path,
            icon: renderIconSvg(m.svg),
            children: m.children.map(c => this.renderMenuOption(c))
          }
        } else {
          return this.renderMenuOption(m)
        }
      })
    },
    darkTheme: {
      get() {
        return this.$oui.state.theme === 'dark'
      },
      set(val) {
        this.$oui.setTheme(val ? 'dark' : 'light')
      }
    },
    localeOptions() {
      const titles = {
        'en-US': 'English',
        'ja-JP': '日本語',
        'zh-CN': '简体中文',
        'zh-TW': '繁體中文'
      }

      const options = this.$i18n.availableLocales.map(locale => {
        return {
          label: titles[locale] ?? locale,
          key: locale
        }
      })

      options.unshift({
        label: this.$t('Auto'),
        key: 'auto'
      })

      return options
    }
  },
  watch: {
    '$route'() {
      this.updateMenu()
    }
  },
  methods: {
    renderMenuOption(m) {
      return {
        label: () => h(resolveComponent('router-link'), { to: { path: m.path } }, () => this.$t('menus.' + m.title)),
        key: m.path,
        icon: renderIconSvg(m.svg)
      }
    },
    updateMenu() {
      const path = this.$route.path
      const paths = path.split('/')

      if (path === '/home') {
        this.expandedMenus = []
        this.selectedMenu = ''
        return
      }

      this.selectedMenu = path

      if (paths.length > 2)
        this.expandedMenus = ['/' + paths[1]]
    },
    clickMenuItem(key) {
      this.selectedMenu = key
      if (key.split('/').length === 2)
        this.expandedMenus = []
    },
    menuExpanded(keys) {
      this.expandedMenus = keys
    },
    renderLocaleIcon(o) {
      if (o.key === this.$oui.state.locale)
        return renderIcon(ChevronForwardIcon)()
    },
    renderThemeIcon(o) {
      if (o.key === this.$oui.state.theme)
        return renderIcon(ChevronForwardIcon)()
    },
    handleUserAction(key) {
      if (key === 'logout') {
        this.$oui.logout()
        this.$router.push('/login')
      } else if (key === 'reboot') {
        this.$dialog.warning({
          title: this.$t('Reboot'),
          content: this.$t('RebootConfirm'),
          positiveText: this.$t('OK'),
          onPositiveClick: () => {
            this.$oui.ubus('system', 'reboot').then(() => {
              this.modalSpin = true
              this.$oui.reconnect().then(() => {
                this.modalSpin = false
                this.$router.push('/login')
              })
            })
          }
        })
      }
    }
  },
  mounted() {
    this.updateMenu()
  }
}
</script>

<style scoped>
.logo-name {
  line-height: 50px;
  text-align: center;
  font-size: 2em;
}

.logo-name a {
  text-decoration:none;
}

.copyright {
  text-align: right;
  font-size: medium;
  padding-right: 40px;
}

.copyright .n-a {
  font-size: 1.2em;
}

.zoom-fade-enter-active,
.zoom-fade-leave-active {
  transition: transform 0.35s, opacity 0.28s ease-in-out;
}

.zoom-fade-enter-from {
  opacity: 0;
  transform: scale(0.97);
}

.zoom-fade-leave-to {
  opacity: 0;
  transform: scale(1.03);
}
</style>

<i18n src="./locale.json"/>
