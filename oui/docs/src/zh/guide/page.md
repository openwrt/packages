# 页面

通常，一个页面对应一个 oui-app-xx

一个基本的页面的目录结构是这样的
```
oui-app-demo/
├── files
│   ├── menu.json
│   └── rpc
│       └── demo.lua
├── htdoc
│   ├── index.vue
│   ├── locale.json
│   ├── package.json
│   ├── package-lock.json
│   └── vite.config.js
└── Makefile

3 directories, 8 files
```

::: tip
如需创建新的页面，直接复制 oui-app-demo 目录，然后重命名即可
:::

## Makefile 配置

```makefile{9,10}
#
# Copyright (C) 2022 Jianhui Zhao <zhaojh329@gmail.com>
#
# This is free software, licensed under the MIT.
#

include $(TOPDIR)/rules.mk

APP_TITLE:=Demo
APP_NAME:=demo

include ../../oui.mk

# call BuildPackage - OpenWrt buildroot signature
```

* `APP_TITLE` - 对应 OpenWrt 软件包中的 TITLE
* `APP_NAME` - 编译过程，菜单配置文件和打包的 js 文件会以 `APP_NAME` 命名

:::warning
`APP_NAME` 不能重复
:::

## 菜单配置

对于 `login`, `layout`, `home` 这三种页面，不需要菜单配置文件。

``` json
{
    "/demo": {
        "title": "Oui Demo",
        "view": "demo",
        "index": 60,
        "locales": {
            "en-US": "Oui Demo",
            "zh-CN": "Oui 示范",
            "zh-TW": "Oui 示範"
        },
        "svg":{"-xmlns":"http://www.w3.org/2000/svg","-xmlns:xlink":"http://www.w3.org/1999/xlink","-viewBox":"0 0 512 512","path":{"-d":"M407.72 208c-2.72 0-14.44.08-18.67.31l-57.77 1.52L198.06 48h-62.81l74.59 164.61l-97.31 1.44L68.25 160H16.14l20.61 94.18c.15.54.33 1.07.53 1.59a.26.26 0 0 1 0 .15a15.42 15.42 0 0 0-.53 1.58L15.86 352h51.78l45.45-55l96.77 2.17L135.24 464h63l133-161.75l57.77 1.54c4.29.23 16 .31 18.66.31c24.35 0 44.27-3.34 59.21-9.94C492.22 283 496 265.46 496 256c0-30.06-33-48-88.28-48zm-71.29 87.9z","-fill":"currentColor"}}
    }
}
```

* `view` - 和 Makefile 中的 `APP_NAME` 一致
* `index` - 用于菜单排序
* `locales` - 菜单标题翻译
* `svg` - 菜单图标

:::tip
如何配置菜单图标：到 [xicons](https://www.xicons.org/#/) 复制所需图标的 svg 代码，然后到
[xml2json](https://www.w3cschool.cn/tools/index?name=xmljson) 这个网站上将 svg 的代码转换为 json 格式。
:::

菜单分为一级菜单和二级菜单。oui-ui-core 默认提供了一些常用的一级菜单
```json
{
    "/status": {
        "title": "Status",
        "icon": "md-stats",
        "index": 10,
        "locales": {
            "en-US": "Status",
            "zh-CN": "状态",
            "zh-TW": "狀態"
        },
        "svg":{"-xmlns":"http://www.w3.org/2000/svg","-xmlns:xlink":"http://www.w3.org/1999/xlink","-viewBox":"0 0 24 24","path":{"-d":"M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10s10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z","-fill":"currentColor"}}
    },
    "/system": {
        "title": "System",
        "icon": "md-settings",
        "index": 20,
        "locales": {
            "en-US": "System",
            "zh-CN": "系统",
            "zh-TW": "系統"
        },
        "svg":{"-xmlns":"http://www.w3.org/2000/svg","-xmlns:xlink":"http://www.w3.org/1999/xlink","-viewBox":"0 0 24 24","g":{"-fill":"none","path":{"-d":"M4.946 5h14.108C20.678 5 22 6.304 22 7.92v8.16c0 1.616-1.322 2.92-2.946 2.92H4.946C3.322 19 2 17.696 2 16.08V7.92C2 6.304 3.322 5 4.946 5zm0 2A.933.933 0 0 0 4 7.92v8.16c0 .505.42.92.946.92h14.108a.933.933 0 0 0 .946-.92V7.92c0-.505-.42-.92-.946-.92H4.946z","-fill":"currentColor"}}}
    },
    "/network": {
        "title": "Network",
        "icon": "md-git-network",
        "index": 30,
        "locales": {
            "en-US": "Network",
            "zh-CN": "网络",
            "zh-TW": "網絡"
        },
        "svg":{"-xmlns":"http://www.w3.org/2000/svg","-xmlns:xlink":"http://www.w3.org/1999/xlink","-viewBox":"0 0 640 512","path":{"-d":"M640 264v-16c0-8.84-7.16-16-16-16H344v-40h72c17.67 0 32-14.33 32-32V32c0-17.67-14.33-32-32-32H224c-17.67 0-32 14.33-32 32v128c0 17.67 14.33 32 32 32h72v40H16c-8.84 0-16 7.16-16 16v16c0 8.84 7.16 16 16 16h104v40H64c-17.67 0-32 14.33-32 32v128c0 17.67 14.33 32 32 32h160c17.67 0 32-14.33 32-32V352c0-17.67-14.33-32-32-32h-56v-40h304v40h-56c-17.67 0-32 14.33-32 32v128c0 17.67 14.33 32 32 32h160c17.67 0 32-14.33 32-32V352c0-17.67-14.33-32-32-32h-56v-40h104c8.84 0 16-7.16 16-16zM256 128V64h128v64H256zm-64 320H96v-64h96v64zm352 0h-96v-64h96v64z","-fill":"currentColor"}}
    }
}
```

## 自定义 `login` `layout` `home` 页面

以自定义 `login` 页面为例

* 首先创建一个 app，比如 `applications/oui-app-login-x`，然后修改其 Makefile：

```makefile{9,10}
#
# Copyright (C) 2022 Jianhui Zhao <zhaojh329@gmail.com>
#
# This is free software, licensed under the MIT.
#

include $(TOPDIR)/rules.mk

APP_TITLE:=Login X
APP_NAME:=login-x

include ../../oui.mk

# call BuildPackage - OpenWrt buildroot signature
```

* 配置 `oui-ui-core`

```sh
Oui  --->
    (login-x) Customize the login view
```

* 开发/调试

创建文件: oui-ui-core/htdoc/.env.local

```
VITE_OUI_LOGIN_VIEW=login-x
```
