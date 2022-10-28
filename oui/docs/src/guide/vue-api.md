# Vue API

The Oui framework registers some instance objects in Vue for easy invocation by individual pages.
The variable name 'vm' (short for ViewModel) is used in the documentation to denote Vue instances.

## vm.$oui

### state: global state

A reactive object with the following fields

| Name  | Type | description |
| ---------- | --------| ------------- |
| locale     | String  | The current language |
| theme      | String  | The current theme    |
| hostname   | String  | The current hostname of the system |

```vue
<div>{{ $oui.state.locale }}</div>
<div>{{ $oui.state.theme }}</div>
<div>{{ $oui.state.hostname }}</div>
```

### call: Call the backend API

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

### ubus: Encapsulation of `call`

```js
this.$oui.ubus('system', 'validate_firmware_image',
    {
        path: '/tmp/firmware.bin'
    }
).then(({ valid }) => {
})
```
Equivalent to

```js
this.$oui.call('ubus', 'call', {
    object: 'system',
    method: 'validate_firmware_image',
    { path: '/tmp/firmware.bin' }
}).then(r => {
})
```

### login: log in

```js
this.$oui.login('admin', '123456').then(() => {
})
```

### logout: log out

```js
this.$oui.logout().then(() => {
})
```

### setLocale: switch the language

```js
this.$oui.setLocale('en-US')
```

### setTheme: Switch the theme

```js
this.$oui.setTheme('dark')
```

### setHostname: Set the system's hostname

```js
this.$oui.setHostname('OpenWrt')
```

:::tip
You need to set the hostname by calling this function so that `$oui.state.hostname` can be updated.
:::

### reloadConfig: reload config

Encapsulation of the following UBUS operations

```sh
ubus call service event '{"type":"config.change", "data": {"package": "system"}}'
```

```js
this.$oui.reloadConfig('system')
```

### reconnect: Wait until the system restarts finish

This method is useful when performing a restart operation.

```js
this.$oui.reconnect().then(() => {
    this.$router.push('/login')
})
```

## $timer

You might have written something like this before:

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

After using `vm.$timer`, it looks like this:

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

`vm.$timer.create` takes three arguments:

* name: Timer name (cannot be repeated)
* callback: The callback method
* option: options

`option` includes the following fields:

| Name  | Type | Description |
| ---------- | --------| ------------- |
| time      | Number   | Timeout or interval (default value: 1000) |
| autostart | Boolean  | Whether to automatically start after creation (default is true)  |
| immediate | Boolean  | Whether to execute a callback function immediately after creation |
| repeat    | Boolean  | Whether to repeat |

`vm.$timer.start`: Start timer(If you set autostart as false, you need to call the function)

`vm.$timer.stop`: Stop the timer (the user does not need to call this function unless otherwise required)

```js
this.$timer.start('test')
this.$timer.stop('test')
```

## $md5

```js
const md5 = this.$md5('123')
```
