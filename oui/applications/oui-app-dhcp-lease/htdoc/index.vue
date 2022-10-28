<template>
  <n-card :title="$t('Active DHCP Leases')">
    <n-data-table :row-key="r => r.macaddr" :columns="columns" :data="leases"/>
  </n-card>
</template>

<script>
export default {
  data() {
    return {
      columns: [
        {
          title: () => this.$t('Hostname'),
          key: 'hostname'
        },
        {
          title: () => this.$t('IPv4 address'),
          key: 'ipaddr'
        },
        {
          title: () => this.$t('MAC address'),
          key: 'macaddr',
          render: r => r.macaddr.toUpperCase()
        },
        {
          title: () => this.$t('Lease'),
          key: 'expire',
          render: r => this.formatSecond(r.expire)
        }
      ],
      leases: []
    }
  },
  methods: {
    formatSecond(second) {
      const days = Math.floor(second / 86400)
      const hours = Math.floor((second % 86400) / 3600)
      const minutes = Math.floor(((second % 86400) % 3600) / 60)
      const seconds = Math.floor(((second % 86400) % 3600) % 60)
      return `${days}d ${hours}h ${minutes}m ${seconds}s`
    },
    getDhcpLeases() {
      this.$oui.call('network', 'dhcp_leases').then(({ leases }) => {
        this.leases = leases
      })
    }
  },
  created() {
    this.$timer.create('dhcp', this.getDhcpLeases, { time: 3000, immediate: true, repeat: true })
  }
}
</script>

<i18n src="./locale.json"/>
