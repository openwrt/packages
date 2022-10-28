import { defineUserConfig } from 'vuepress'
import { registerComponentsPlugin } from '@vuepress/plugin-register-components'
import { searchPlugin } from '@vuepress/plugin-search'
import { getDirname, path } from '@vuepress/utils'
import { defaultTheme } from '@vuepress/theme-default'

const __dirname = getDirname(import.meta.url)

export default defineUserConfig({
  base: '/oui/',
  title: 'Oui',
  locales: {
    '/': {
      lang: 'en-US',
      description: 'A framework used to develop Web interface for OpenWrt'
    },
    '/zh/': {
      lang: 'zh-CN',
      description: '一个用于开发 OpenWrt Web 接口的框架'
    }
  },
  theme: defaultTheme({
    repo: 'zhaojh329/oui',
    docsBranch: 'master',
    docsDir: 'docs/src',
    locales: {
      '/': {
        navbar: [
          {
            text: 'Guide',
            link: '/guide/'
          }
        ],
        sidebar: {
          '/guide/': [
            {
              text: 'Guide',
              children: [
                '/guide/README.md',
                '/guide/getting-started.md',
                '/guide/page.md',
                '/guide/vue-api.md',
                '/guide/lua-lib.md',
                '/guide/lua-api.md',
                '/guide/acl.md'
              ]
            }
          ]
        }
      },
      '/zh/': {
        selectLanguageName: '简体中文',
        selectLanguageText: '选择语言',
        selectLanguageAriaLabel: '选择语言',
        editLinkText: '在 GitHub 上编辑此页',
        lastUpdatedText: '上次更新',
        contributorsText: '贡献者',
        tip: '提示',
        warning: '注意',
        danger: '警告',
        navbar: [
          {
            text: '指南',
            link: '/zh/guide/'
          }
        ],
        sidebar: {
          '/zh/guide/': [
            {
              text: '指南',
              children: [
                '/zh/guide/README.md',
                '/zh/guide/getting-started.md',
                '/zh/guide/page.md',
                '/zh/guide/vue-api.md',
                '/zh/guide/lua-lib.md',
                '/zh/guide/lua-api.md',
                '/zh/guide/acl.md'
              ]
            }
          ]
        }
      }
    }
  }),
  plugins: [
    registerComponentsPlugin({
      componentsDir: path.resolve(__dirname, './components')
    }),
    searchPlugin({
      locales: {
        '/': {
          placeholder: 'Search',
        },
        '/zh/': {
          placeholder: '搜索'
        }
      }
    })
  ]
})
