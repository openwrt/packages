# Page

Typically, one page corresponds to an oui-app-xx

The directory structure of a basic page looks like this

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
To create a new page, copy the `oui-app-demo` directory and rename it.
:::

## Makefile

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

* `APP_TITLE` - Corresponds to the `TITLE` in the OpenWrt software package
* `APP_NAME` - During compilation, menu configuration file and packaged JS file will be named `APP_NAME`

:::warning
`APP NAME` cannot be repeated
:::

## Menu Configuration

For the `login`, `layout`, and `home` pages, no menu configuration file are required.

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

* `view` - Same as `APP NAME` in Makefile
* `index` - For menu sorting
* `locales` - Menu Title Translation
* `svg` - The menu icon

:::tip
How to configure menu icon: Copy the SVG code for the icon you want from [xicons](https://www.xicons.org/#/),
and then go to the [xml2json](https://jsonformatter.org/xml-to-json) site to convert the SVG code to JSON format.
:::

The menu is divided into primary menu and secondary menu. Oui-ui-core provides some common primary menus by default

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

## Customize the `login` `layout` `home` page

Take the custom `login` page as an example

* First create an app, such as `applications/oui-app-login-x`, and then modify its Makefile

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

* Configure `oui-ui-core`

```sh
Oui  --->
    (login-x) Customize the login view
```

* Development/Debugging

Create a file: oui-ui-core/htdoc/.env.local

```
VITE_OUI_LOGIN_VIEW=login-x
```
