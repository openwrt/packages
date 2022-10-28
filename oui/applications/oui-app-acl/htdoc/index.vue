<template>
  <n-space>
    <n-select v-model:value="group" :options="groups" style="width: 200px"/>
    <n-button type="primary" @click="addGroup">{{ $t('Add group') }}</n-button>
  </n-space>
  <n-divider></n-divider>
  <n-data-table :row-key="r => r.cls" :columns="columns" :data="acls"/>
  <n-divider></n-divider>
  <n-space justify="end" style="padding-right: 100px">
    <n-button type="primary" :loading="loading" @click="handleSubmit">{{ $t('Save & Apply') }}</n-button>
  </n-space>
</template>

<script>
import { h, resolveComponent } from 'vue'

export default {
  data() {
    return {
      columns: [
        {
          title: () => this.$t('Class'),
          key: 'cls',
          width: 100
        },
        {
          title: () => this.$t('Matchs'),
          key: 'matchs',
          ellipsis: {
            tooltip: true
          },
          render: r => h(resolveComponent('n-dynamic-tags'), {
            value: r.matchs,
            'on-update:value': value => {
              if (value.length > r.matchs.length) {
                r.matchs.push(value[value.length - 1])
                return
              }

              r.matchs.forEach((m, i) => {
                if (!value.includes(m)) {
                  r.matchs.splice(i, 1)
                  return false
                }
              })
            }
          })
        },
        {
          title: () => this.$t('Negative'),
          key: 'negative',
          width: 100,
          render: r => h(resolveComponent('n-switch'), {
            value: r.negative,
            'on-update:value': value => this.allAcls[this.group][r.cls].negative = value
          })
        }
      ],
      group: '',
      allAcls: {},
      loading: false
    }
  },
  computed: {
    groups() {
      return Object.keys(this.allAcls).map(group => {
        return {
          label: group,
          value: group
        }
      })
    },
    acls() {
      if (!this.allAcls || !this.group)
        return []

      const acls = this.allAcls[this.group]
      return Object.keys(acls).map(cls => {
        return {
          cls: cls,
          matchs: acls[cls].matchs,
          negative: acls[cls].negative || false
        }
      })
    }
  },
  methods: {
    handleSubmit() {
      this.loading = true
      this.$oui.call('acl', 'set', { acls: this.allAcls }).then(() => this.loading = false)
    },
    addGroup() {
      let group = ''
      this.$dialog.create({
        title: this.$t('Add group'),
        content: () => h(resolveComponent('n-input'), {
          'on-update:value': value => group = value
        }),
        positiveText: this.$t('OK'),
        onPositiveClick: () => {
          group = group.trim()
          if (!group)
            return

          this.allAcls[group] = {
            rpc: { matchs: [ '.+' ] },
            menu: { matchs: [ '.+' ] },
            ubus: { matchs: [ '.+' ] },
            uci: { matchs: [ '.+' ] }
          }

          this.group = group
        }
      })
    }
  },
  created() {
    this.$oui.call('acl', 'load').then(acls => {
      this.allAcls = acls
      this.group = this.groups[0].value
    })
  }
}
</script>

<i18n src="./locale.json"/>
