<template>
  <n-space justify="space-around">
    <dashboard :label="$t('CPU Usage')" :percentage="cpuUsage['cpu']" :color="cpuUsageColor">
      <div v-for="name in Object.keys(cpuUsage).sort()" :key="name">{{ name + ': ' + cpuUsage[name] + '%' }}</div>
    </dashboard>
    <dashboard :label="$t('Memory Usage')" :percentage="memUsage" :color="memUsageColor">
      <div v-for="item in memInfo" :key="item[0]">{{ $t(item[0]) + ': ' + bytesToHuman(item[1])}}</div>
    </dashboard>
    <dashboard v-if="sysinfo && sysinfo.root" :label="$t('Storage Usage')" :percentage="storageUsage" :color="storageUsageColor">
      <div>{{ $t('Total') + ': ' + bytesToHuman(sysinfo.root.total * 1024) }}</div>
      <div>{{ $t('Used') + ': ' + bytesToHuman(sysinfo.root.used * 1024) }}</div>
    </dashboard>
  </n-space>
  <n-divider/>
  <n-space>
    <n-descriptions label-placement="left" :title="$t('System')" bordered :column="1">
      <n-descriptions-item v-for="item in renderSysinfo" :key="item[0]">
        <template #label>{{ $t(item[0]) }}</template>{{ item[1] }}
      </n-descriptions-item>
    </n-descriptions>
    <n-descriptions v-for="net in wanNetworks" :key="net.interface" label-placement="left" :title="'IPv4 ' + $t('Upstream')" bordered :column="1">
      <n-descriptions-item v-for="item in renderNetworkInfo(net)" :key="item[0]">
        <template #label>{{ $t(item[0]) }}</template>{{ item[1] }}
      </n-descriptions-item>
    </n-descriptions>
    <n-descriptions v-for="net in wan6Networks" :key="net.interface" label-placement="left" :title="'IPv6 '+ $t('Upstream')" bordered :column="1">
      <n-descriptions-item v-for="item in renderNetworkInfo(net, true)" :key="item[0]">
        <template #label>{{ $t(item[0]) }}</template>{{ item[1] }}
      </n-descriptions-item>
    </n-descriptions>
  </n-space>
</template>

<script>
import dashboard from './dashboard.vue'

export default {
  data() {
    return {
      cpuTimes: [],
      sysinfo: null,
      boardinfo: null,
      wanNetworks: [],
      wan6Networks: []
    }
  },
  components: {
    dashboard
  },
  computed: {
    cpuUsage() {
      if (this.cpuTimes.length < 2)
        return {cpu: 0}

      const values = {}

      Object.keys(this.cpuTimes[0]).forEach(name => {
        values[name] = this.calcCpuUsage(this.cpuTimes[0][name], this.cpuTimes[1][name])
      })

      return values
    },
    cpuUsageColor() {
      const val = this.cpuUsage['cpu']

      if (val > 95)
        return 'maroon'

      if (val > 90)
        return 'red'

      return undefined
    },
    memUsage() {
      if (!this.sysinfo)
        return 0
      const memory = this.sysinfo.memory
      return parseFloat(((memory.total - memory.free) * 100 / memory.total).toFixed(2))
    },
    memUsageColor() {
      const val = this.memUsage

      if (val > 95)
        return 'maroon'

      if (val > 90)
        return 'red'

      return undefined
    },
    memInfo() {
      if (!this.sysinfo)
        return []

      const memory = this.sysinfo.memory
      const info = [
        ['Total', memory.total],
        ['Available', memory.available ? memory.available : memory.free + memory.buffered],
        ['Used', memory.total - memory.free]
      ]

      if (memory.buffered)
        info.push(['Buffered', memory.buffered])
      if (memory.cached)
        info.push(['Cached', memory.cached])

      return info
    },
    storageUsage() {
      if (!this.sysinfo)
        return 0
      const root = this.sysinfo.root
      return parseFloat((root.used * 100 / root.total).toFixed(2))
    },
    storageUsageColor() {
      const val = this.storageUsage

      if (val > 95)
        return 'maroon'

      if (val > 90)
        return 'red'

      return undefined
    },
    renderSysinfo() {
      const sysinfo = this.sysinfo
      const boardinfo = this.boardinfo

      if (!sysinfo || !boardinfo)
        return []

      const load = sysinfo.load
      const info = [
        ['Hostname', boardinfo.hostname],
        ['Model', boardinfo.model],
        ['Architecture', boardinfo.system],
        ['Target Platform', boardinfo.release ? boardinfo.release.target : ''],
        ['Firmware Version', boardinfo.release ? boardinfo.release.description : ''],
        ['Kernel Version', boardinfo.kernel],
        ['Uptime', this.secondsToHuman(sysinfo.uptime)],
        ['Load Average', load.map(v => (v / 65535).toFixed(2)).join(', ')]
      ]
      return info
    }
  },
  methods: {
    bytesToHuman(bytes) {
      if (isNaN(bytes))
        return ''

      if (bytes < 0)
        return ''

      let units = ''

      const k = Math.floor((Math.log2(bytes) / 10))
      if (k > 0)
        units = 'KMGTPEZY'[k - 1] + 'iB'

      return (bytes / Math.pow(1024, k)).toFixed(2) + ' ' + units
    },
    secondsToHuman(second) {
      if (isNaN(second))
        return ''
      const days = Math.floor(second / 86400)
      const hours = Math.floor((second % 86400) / 3600)
      const minutes = Math.floor(((second % 86400) % 3600) / 60)
      const seconds = Math.floor(((second % 86400) % 3600) % 60)
      return `${days}d ${hours}h ${minutes}m ${seconds}s`
    },
    calcCpuUsage(times0, times1) {
      const times0CPU = times0[0] + times0[1] + times0[2]
      const times1CPU = times1[0] + times1[1] + times1[2]

      const val = (times1CPU - times0CPU) * 100.0 / ((times1CPU + times1[3]) - (times0CPU + times0[3]))

      return parseFloat(val.toFixed(2))
    },
    getCpuTimes() {
      this.$oui.call('system', 'get_cpu_time').then(({ times }) => {
        this.cpuTimes.push(times)
        if (this.cpuTimes.length === 3)
          this.cpuTimes.shift()
      })
    },
    getSysinfo() {
      this.$oui.ubus('system', 'info').then(r => {
        this.sysinfo = r
      })
    },
    getWanNetworks() {
      this.$oui.call('network', 'get_wan_networks').then(({ networks }) => {
        this.wanNetworks = networks
      })
    },
    getWan6Networks() {
      this.$oui.call('network', 'get_wan6_networks').then(({ networks }) => {
        this.wan6Networks = networks
      })
    },
    renderNetworkInfo(net, ipv6) {
      const info = [
        ['Protocol', net.proto]
      ]

      if (ipv6) {
        const prefix = net['ipv6-prefix'][0]
        if (prefix)
          info.push(['Prefix Delegated', prefix.address + '/' + prefix.mask])
        info.push(['Address', net['ipv6-address'].map(a => a.address + '/' + a.mask)[0]])
        info.push(['Gateway', net.route.filter(r => r.target === '::' && r.mask === 0).map(r => r.nexthop)[0]])
      } else {
        info.push(['Address', net['ipv4-address'].map(a => a.address + '/' + a.mask)[0]])
        info.push(['Gateway', net.route.filter(r => r.target === '0.0.0.0' && r.mask === 0).map(r => r.nexthop)[0]])
      }

      info.push(['DNS', net['dns-server'].join(', ')])
      info.push(['Connected', this.secondsToHuman(net.uptime)])

      return info
    }
  },
  created() {
    this.$timer.create('getCpuTimes', this.getCpuTimes, {repeat: true, immediate: true, time: 3000})
    this.$timer.create('getSysinfo', this.getSysinfo, {repeat: true, immediate: true, time: 3000})
    this.$timer.create('getWanNetworks', this.getWanNetworks, {repeat: true, immediate: true, time: 5000})
    this.$timer.create('getWan6Networks', this.getWan6Networks, {repeat: true, immediate: true, time: 5000})

    this.$oui.ubus('system', 'board').then(r => {
      this.boardinfo = r
    })
  }
}
</script>

<i18n src="./locale.json"/>
