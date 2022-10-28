# Get Started

## Build & Install

:::tip
Oui requires the `gzip Static` module of Nginx to work, which is not enabled for Nginx in earlier Openwrt Packages. 

If you are using a earlier OpenWrt, you will need to apply this patch: 

[https://github.com/openwrt/packages/commit/33a93e20a6875873232467621624b8b4df8ca427](https://github.com/openwrt/packages/commit/33a93e20a6875873232467621624b8b4df8ca427)
:::

### Add feed

``` bash
echo "src-git oui https://github.com/zhaojh329/oui.git" >> feeds.conf.default
```

### Update feed

``` bash
./scripts/feeds update -a
./scripts/feeds install -a -p oui
```

### Configure

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

The `Node` is needed to compile Oui, and the version cannot be later than 14.18.

Select `CONFIG_OUI_USE_HOST_NODE` can save compilation time. Ensure that the Node
version installed on hosts is at least 14.18. 

[Install the new version of Node on the host](https://nodejs.org/en/download/package-manager/)

You may have selected the configuration related to Luci before, which will conflict with oui, so you need to deselect it.
:::

### Build

``` bash
make V=s
```

::: tip
Default username: admin

Default password: 123456
:::

## Development & Debugging

Start by modifying the HTTP proxy: oui-ui-core/htdoc/vite.config.js
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
Change the `https://openwrt.lan` to the address of your debug device, such as `https://192.168.1.1`

1. Open the OUI project using VSCode
2. Enter into the directory: `oui-ui-core/htdoc`
3. Execute `npm install`
4. Execute `npm run dev`

After running `npm run dev`, open the browser as prompted. Any changes made to the code at this point are immediately rendered in the browser.

:::tip
After creating a new app, you need to run `npm run dev` again.
:::
