<template>
  <n-data-table :row-key="r => r.macaddr" :columns="columns" :data="stations"/>
</template>

<script>
import { h } from 'vue'

export default {
  name: 'dhcp',
  data() {
    return {
      columns: [
        {
          title: () => this.$t('Type'),
          key: 'band'
        },
        {
          title: () => this.$t('Network'),
          key: 'ifname'
        },
        {
          title: () => this.$t('MAC address'),
          key: 'macaddr',
          render: r => r.macaddr.toUpperCase()
        },
        {
          title: () => this.$t('Signal / Noise'),
          key: 'signal',
          render: r => `${r.signal} / ${r.noise} dBm`
        },
        {
          title: () => this.$t('RX Rate / TX Rate'),
          key: 'rate',
          render: r => h('div', [
            h('p', this.wifiRate(r.rx_rate)),
            h('p', this.wifiRate(r.tx_rate))
          ])
        }
      ],
      stations: []
    }
  },
  methods: {
    wifiRate(rate) {
      let s = (rate.rate / 1000).toFixed(1) + ' Mbit/s' + ', ' + rate.mhz + ' MHz'

      if (rate.ht || rate.vht) {
        if (rate.vht)
          s += ', VHT-MCS ' + rate.mcs
        if (rate.nss)
          s += ', VHT-NSS ' + rate.nss
        if (rate.ht)
          s += ', MCS ' + rate.mcs
      }

      if (rate.he) {
        s += ', HE-MCS ' + rate.mcs
        if (rate.nss)
          s += ', HE-NSS ' + rate.nss
        if (rate.he_gi)
          s += ', HE-GI ' + rate.he_gi
        if (rate.he_dcm)
          s += ', HE-DCM ' + rate.he_dcm
      }

      return s
    },
    getStations() {
      this.$oui.call('wireless', 'stations').then(({ stations }) => {
        this.stations = stations
      })
    }
  },
  created() {
    this.$timer.create('getStations', this.getStations, { time: 3000, immediate: true, repeat: true })
  }
}
</script>

<i18n src="./locale.json"/>
