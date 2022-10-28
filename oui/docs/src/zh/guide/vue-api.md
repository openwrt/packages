# Vue API

Oui 框架在 Vue 中注册了一些实例对象，方便各个页面调用。
文档中使用 `vm` (ViewModel 的缩写) 这个变量名表示 Vue 实例。

## vm.$oui

### state: 全局状态

一个响应式对象，包括如下字段

| 名称  | 类型 | 描述 |
| ---------- | --------| ------------- |
| locale     | String  | 当前语言       |
| theme      | String  | 当前主题       |
| hostname   | String  |当前系统的主机名 |

```vue
<div>{{ $oui.state.locale }}</div>
<div>{{ $oui.state.theme }}</div>
<div>{{ $oui.state.hostname }}</div>
```

### call: 调用后端接口

vm.$oui.call(mod, func, [param])

<CodeGroup>
  <CodeGroupItem title="Vue" active>

```js
this.$oui.call('system', 'get_cpu_time').then(({ times }) => {
  ...
})
```

  </CodeGroupItem>

  <CodeGroupItem title="Lua">

```lua
-- /usr/share/oui/rpc/system.lua

local fs = require 'oui.fs'

local M = {}

function M.get_cpu_time()
    local result = {}

    for line in io.lines('/proc/stat') do
        local cpu = line:match('^(cpu%d?)')
        if cpu then
            local times = {}
            for field in line:gmatch('%S+') do
                if not field:match('cpu') then
                    times[#times + 1] = tonumber(field)
                end
            end
            result[cpu] = times
        end
    end

    return { times = result }
end

return M
```

  </CodeGroupItem>
</CodeGroup>

### ubus: 对 `call` 的封装

```js
this.$oui.ubus('system', 'validate_firmware_image',
    {
        path: '/tmp/firmware.bin'
    }
).then(({ valid }) => {
})
```
等价于
```js
this.$oui.call('ubus', 'call', {
    object: 'system',
    method: 'validate_firmware_image',
    { path: '/tmp/firmware.bin' }
}).then(r => {
})
```

### login：登录

```js
this.$oui.login('admin', '123456').then(() => {
})
```

### logout: 退出登录

```js
this.$oui.logout().then(() => {
})
```

### setLocale: 切换语言

```js
this.$oui.setLocale('en-US')
```

### setTheme: 切换主题

```js
this.$oui.setTheme('dark')
```

### setHostname: 设置系统主机名

```js
this.$oui.setHostname('OpenWrt')
```

:::tip
你需要通过调用该函数来设置主机名，这样 `$oui.state.hostname` 才能得到更新。
:::

### reloadConfig: 重载配置

对下面的 ubus 操作的封装
```sh
ubus call service event '{"type":"config.change", "data": {"package": "system"}}'
```

```js
this.$oui.reloadConfig('system')
```

### reconnect: 等待系统重启完成

当执行重启操作时，该方法比较有用。

```js
this.$oui.reconnect().then(() => {
    this.$router.push('/login')
})
```

## $timer

你以前可能是这样写的：

```vue
<script>
export default {
  data() {
    return {
      timer: null,
      interval: null
    }
  },
  created() {
    this.timer = setTimeout(() => {
        ...
    }, 5000)

    this.interval = setInterval(() => {
        ...
    }, 5000);
  },
  beforeUnmount() {
    clearTimeout(this.timer)
    clearInterval(this.interval)
  }
}
</script>
```

使用 `vm.$timer` 后，是这样的：

```vue
<script>
export default {
  methods: {
    getDhcpLeases() {
        ...
    }
  },
  created() {
    this.$timer.create('dhcp', this.getDhcpLeases, { time: 3000, immediate: true, repeat: true })
  }
}
</script>
```

`vm.$timer.create` 接受 3 个参数：

* name: 定时器名称(不能重复)
* callback: 回调方法
* option: 选项

其中 `option` 包括如下字段：

| 名称  | 类型 | 描述 |
| ---------- | --------| ------------- |
| time      | Number   | 超时时间或者间隔时间（默认值为 1000）|
| autostart | Boolean  | 是否创建后自动启动（默认为 true）  |
| immediate | Boolean  | 创建后是否立即执行一次回调函数 |
| repeat    | Boolean  | 是否重复 |

`vm.$timer.start`：启动定时器（如果你设置 autostart 为 false，你需要调用该函数）

`vm.$timer.stop`：停止定时器(用户无需调用该函数，除非有特别需要)

```js
this.$timer.start('test')
this.$timer.stop('test')
```

## $md5

```js
const md5 = this.$md5('123')
```
