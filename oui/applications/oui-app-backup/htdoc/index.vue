<template>
  <n-h2>{{ $t('Backup') }}</n-h2>
  <div v-if="backupUrl" class="backup">
    <n-a :href="backupUrl" download="backup.tar.gz">backup.tar.gz</n-a>
    <n-icon size="25"><arrow-down-sharp-icon/></n-icon>
  </div>
  <n-button :loading="loading" type="primary" style="margin-top: 4px" @click="generateBackup">{{ $t('Generate backup file') }}</n-button>
  <n-divider/>
  <n-h2>{{ $t('Restore from backup') }}</n-h2>
  <n-upload ref="upload" directory-dnd action="/oui-upload" :data="{path: '/tmp/backup.tar.gz'}" :on-finish="onUploadFinish">
    <n-upload-dragger>
      <div><n-icon size="48"><arrow-up-circle-icon/></n-icon></div>
      <n-text style="font-size: 16px">{{ $t('Click or drag files to this area to upload') }}</n-text>
    </n-upload-dragger>
  </n-upload>
  <n-modal v-model:show="modalConfirm" preset="dialog" :title="$t('Apply backup') + '?'"
    :positive-text="$t('Continue')"
    :negative-text="$t('Cancel')"
    @positive-click="doRestore">
    <n-space vertical>
      <p>{{ $t('restore-confirm', [ this.$t('Continue'), this.$t('Cancel') ]) }}</p>
      <n-input readonly type="textarea" :autosize="{minRows: 5, maxRows: 10}" :value="backupFiles"/>
    </n-space>
  </n-modal>
  <n-divider/>
  <n-h2>{{ $t('Reset to defaults') }}</n-h2>
  <n-button type="error" @click="doReset">{{ $t('Perform reset') }}</n-button>
  <n-modal v-model:show="modalSpin" :close-on-esc="false" :mask-closable="false">
    <n-spin size="large">
      <template #description>
        <n-el style="color: var(--primary-color)">{{ $t('Rebooting') }}...</n-el>
      </template>
    </n-spin>
  </n-modal>
</template>

<script>
import {
  ArrowDownSharp as ArrowDownSharpIcon,
  ArrowUpCircle as ArrowUpCircleIcon
} from '@vicons/ionicons5'

export default {
  components: {
    ArrowDownSharpIcon,
    ArrowUpCircleIcon
  },
  data() {
    return {
      backupUrl: '',
      backupFiles: '',
      loading: false,
      modalConfirm: false,
      modalSpin: false
    }
  },
  methods: {
    generateBackup() {
      this.loading = true
      this.$oui.call('system', 'create_backup', { path: '/tmp/backup.tar.gz' }).then(() => {
        this.axios.post('/oui-download', { path: '/tmp/backup.tar.gz' }, { responseType: 'blob' }).then(resp => {
          this.backupUrl = window.URL.createObjectURL(resp.data)
          this.loading = false
        })
      })
    },
    onUploadFinish() {
      this.$refs.upload.clear()

      this.$oui.call('system', 'list_backup', { path: '/tmp/backup.tar.gz' }).then(({ files }) => {
        if (!files) {
          this.$dialog.error({
            content: this.$t('The uploaded backup archive is not readable')
          })
        } else {
          this.backupFiles = files
          this.modalConfirm = true
        }
      })
    },
    doRestore() {
      this.$oui.call('system', 'restore_backup', { path: '/tmp/backup.tar.gz' }).then(() => {
        this.modalSpin = true
        this.$oui.reconnect().then(() => {
          this.$router.push('/login')
        })
      })
    },
    doReset() {
      this.$dialog.warning({
        title: this.$t('Reset to defaults'),
        content: this.$t('ResettConfirm') + '?',
        positiveText: this.$t('OK'),
        onPositiveClick: () => {
          this.$oui.ubus('system', 'reset').then(() => {
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
}
</script>

<style scoped>
.backup a {
  font-size: 1.5em;
  text-decoration: none;
  margin-right: 10px;
}

.backup:hover {
  text-decoration: underline;
}
</style>

<i18n src="./locale.json"/>
