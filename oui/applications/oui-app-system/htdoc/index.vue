<template>
  <n-form size="large" ref="form" label-placement="left" label-width="auto" :model="formValue" :rules="rules">
    <n-form-item :label="$t('Hostname')" path="hostname">
      <n-input v-model:value="formValue.hostname"/>
    </n-form-item>
    <n-form-item :label="$t('Timezone')" path="zonename">
      <n-select v-model:value="formValue.zonename" :options="zoneinfo" filterable/>
    </n-form-item>
  </n-form>
  <n-space justify="end" style="padding-right: 100px">
    <n-button type="primary" :loading="loading" @click="handleSubmit">{{ $t('Save & Apply') }}</n-button>
  </n-space>
</template>

<script>
import zoneinfo from './zoneinfo'

export default {
  data() {
    return {
      loading: false,
      formValue: {
        hostname: this.$oui.state.hostname,
        zonename: ''
      },
      rules: {
        hostname: {
          required: true,
          trigger: 'blur',
          validator: (_, value) => {
            if (!value)
              return Error(this.$t('This field is required'))

            if (value.length <= 253 && (value.match(/^[a-zA-Z0-9_]+$/) || (value.match(/^[a-zA-Z0-9_][a-zA-Z0-9_\-.]*[a-zA-Z0-9]$/) && value.match(/[^0-9.]/))))
              return
            return Error(this.$t('Invalid hostname'))
          }
        }
      }
    }
  },
  computed: {
    zoneinfo() {
      return zoneinfo.map(item => {
        return {
          label: item[0],
          value: item[0]
        }
      })
    }
  },
  created() {
    this.$oui.call('uci', 'get', {
      config: 'system',
      section: '@system[0]',
      option: 'zonename'
    }).then(zonename => {
      this.formValue.zonename = zonename || 'UTC'
    })
  },
  methods: {
    handleSubmit() {
      this.$refs.form.validate(async errors => {
        if (errors)
          return

        this.loading = true

        await this.$oui.setHostname(this.formValue.hostname)

        let timezone = zoneinfo.filter(item => item[0] === this.formValue.zonename)[0][1]
        let zonename = this.formValue.zonename

        if (zonename === 'UTC')
          zonename = ''

        await this.$oui.call('uci', 'set', {
          config: 'system',
          section: '@system[0]',
          values: { timezone, zonename }
        })

        await this.$oui.reloadConfig('system')

        this.loading = false

        this.$message.success(this.$t('Configuration has been applied'))
      })
    }
  }
}
</script>

<i18n src="./locale.json"/>
