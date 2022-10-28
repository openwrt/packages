import { createI18n } from 'vue-i18n'

const i18n = createI18n({
  locale: 'en-US',
  fallbackLocale: 'en-US',
  silentTranslationWarn: true,
  silentFallbackWarn: true,
  messages: {
    'en-US': {},
    'zh-CN': {},
    'zh-TW': {},
    'ja-JP': {}
  }
})

export default i18n
