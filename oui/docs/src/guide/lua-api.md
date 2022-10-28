# Lua API

In Oui, Lua API are organized as `module-methods`.

```sh
root@OpenWrt:~# ls /usr/share/oui/rpc/
acl.lua       network.lua   ubus.lua      ui.lua        wireless.lua
demo.lua      system.lua    uci.lua       user.lua
```

Each Lua file here represents a module. Module name is Lua file name(without suffix). 

Each Lua API file needs to return a `Lua Table`, which consists of multiple `Lua functions`.

```lua
-- /usr/share/oui/rpc/test.lua

local M = {}

--[[
param: Parameters passed by the front-end call
section: The login session information is a Table.
         Contains the currently logged in username (username) and the permission group (acl) to which it belongs.
--]]
function M.func1(param, section)
    local res = {}
    ...
    return res
end

return M
```

```js
this.$oui.call('test', 'func1', {a: 1}).then(res => {
    ...
})
```

## Reference data

* [lua-uci](https://openwrt.org/docs/techref/uci#lua_bindings_for_uci)
* [lua-nginx-module](https://github.com/openresty/lua-nginx-module)
* [lua-cjson](https://github.com/mpx/lua-cjson)

## Delay apply

```lua
-- The upgrade is delayed 0.5 seconds
function M.sysupgrade(param)
    ngx.timer.at(0.5, function()
        local arg = param.keep and '' or '-n'
        os.execute('sysupgrade ' .. arg .. ' /tmp/firmware.bin')
    end)
end
```

## Logging

```lua
ngx.log(ngx.ERR, "hello", " world", " nginx", " ok")
```

## Turn off the Lua code cache

During debugging, the Lua code cache function of `Lua-nginx` module can be turned off to facilitate debugging.

Modify `/etc/nginx/conf.d/oui.conf`

```nginx:{4}
gzip_static on;
lua_shared_dict nonces 16k;
lua_shared_dict sessions 16k;
lua_code_cache off;
```

Then execute `/etc/init.d/nginx reload`
