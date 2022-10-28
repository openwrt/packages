# 快速上手

## 编译/安装

:::tip
Oui 需要 Nginx 的 `gzip static` 模块才能工作，较早的 Openwrt packages 中的 Nginx 未使能该模块。

如果你用的 OpenWrt 的版本较低，需要应用该补丁:

[https://github.com/openwrt/packages/commit/33a93e20a6875873232467621624b8b4df8ca427](https://github.com/openwrt/packages/commit/33a93e20a6875873232467621624b8b4df8ca427)
:::

### 添加 feed

``` bash
echo "src-git oui https://github.com/zhaojh329/oui.git" >> feeds.conf.default
```

### 更新feed

``` bash
./scripts/feeds update -a
./scripts/feeds install -a -p oui
```

### 配置

```
OUI  --->
    Applications  --->
        <*> oui-app-acl. ACL
        <*> oui-app-backup. Backup / Restore
        <*> oui-app-dhcp-lease. DHCP lease
        <*> oui-app-home. OUI built-in home page
        <*> oui-app-layout. OUI built-in layout page
        <*> oui-app-login. OUI built-in login page
        <*> oui-app-stations. Stations
        <*> oui-app-system. System Configure
        <*> oui-app-upgrade. Upgrade
        <*> oui-app-user. User
  -*- oui-rpc-core. Oui rpc core
  -*- oui-ui-core. Oui ui core
  [*] Use existing nodejs installation on the host system
```

::: tip
编译 Oui 需要用到 Node，而且版本不能低于 14.18。

勾选 `CONFIG_OUI_USE_HOST_NODE` 可节约编译时间，需要确保主机上安装的 Node 版本不低于 14.18。

[在主机上安装新版本的 Node](https://nodejs.org/en/download/package-manager/)

可能你之前勾选了 Luci 相关的配置，这会和 oui 产生冲突，需要将其取消。
:::

### 编译

``` bash
make V=s
```

::: tip
默认用户名：admin

默认密码：123456
:::

## 开发/调试

首先修改 http 代理: oui-ui-core/htdoc/vite.config.js
```js
{
    server: {
        proxy: {
        '/oui-rpc': {
            target: 'https://openwrt.lan',
            secure: false
        },
        '/oui-upload': {
            target: 'https://openwrt.lan',
            secure: false
        },
        '/oui-download': {
            target: 'https://openwrt.lan',
            secure: false
        }
        }
    }
}
```
将其中的 `https://openwrt.lan` 修改为你的调试设备的地址,如 `https://192.168.1.1`

1. 使用 vscode 打开 oui 项目
2. 进入 `oui-ui-core/htdoc` 目录
3. 执行 `npm install`
4. 执行 `npm run dev`

执行完 `npm run dev` 后，根据提示打开浏览器。此时对代码中的任何修改，都将立即呈现在浏览器中。

:::tip
创建新的 app 后，需要重新执行 `npm run dev`

建议在 wsl 或 linux 虚拟机里做开发
:::
