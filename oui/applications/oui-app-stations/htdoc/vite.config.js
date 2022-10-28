import { defineConfig, loadEnv } from 'vite'
import vue from '@vitejs/plugin-vue'
import viteCompression from 'vite-plugin-compression'
import vueI18n from '@intlify/vite-plugin-vue-i18n'

const env = loadEnv('', process.cwd())

export default defineConfig({
  plugins: [
    vue(),
    viteCompression({
      deleteOriginFile: true
    }),
    vueI18n({
      compositionOnly: false
    })
  ],
  build: {
    cssCodeSplit: true,
    lib: {
      formats: ['umd'],
      entry: 'index.vue',
      name: 'oui-com-' + env.VITE_APP_NAME,
      fileName: env.VITE_APP_NAME
    },
    rollupOptions: {
      external: ['vue'],
      output: {
        globals: {
          vue: 'Vue'
        }
      }
    }
  }
})
