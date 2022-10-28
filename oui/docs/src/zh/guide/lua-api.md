# Lua 接口

在 Oui 中，Lua 接口以 `模块-方法` 的形式进行组织。

```sh
root@OpenWrt:~# ls /usr/share/oui/rpc/
acl.lua       network.lua   ubus.lua      ui.lua        wireless.lua
demo.lua      system.lua    uci.lua       user.lua
```

这里的每个 Lua 文件代表着一个模块。模块名为 Lua 文件名（不带后缀）。

每个 Lua 接口文件需要返回一个 `Lua Table`，该 `Lua Table` 由多个 `Lua function` 组成。

```lua
-- /usr/share/oui/rpc/test.lua

local M = {}

--[[
param: 前端调用传递的参数
section: 登录的会话信息，为一个 Table，
         包含当前登录的用户名(username)和其所属的权限组(acl)
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

## 参考资料

* [lua-uci](https://openwrt.org/docs/techref/uci#lua_bindings_for_uci)
* [lua-nginx-module](https://github.com/openresty/lua-nginx-module)
* [lua-cjson](https://github.com/mpx/lua-cjson)

## 延迟应用

```lua
-- 延迟 0.5s 执行升级操作
function M.sysupgrade(param)
    ngx.timer.at(0.5, function()
        local arg = param.keep and '' or '-n'
        os.execute('sysupgrade ' .. arg .. ' /tmp/firmware.bin')
    end)
end
```

## 日志

```lua
ngx.log(ngx.ERR, "hello", " world", " nginx", " ok")
```

## 关闭 Lua 代码缓存

调试过程可关闭 `lua-nginx` 模块的 Lua 代码缓存功能，方便调试。

修改 `/etc/nginx/conf.d/oui.conf`

```nginx:{4}
gzip_static on;
lua_shared_dict nonces 16k;
lua_shared_dict sessions 16k;
lua_code_cache off;
```

然后执行 `/etc/init.d/nginx reload`
