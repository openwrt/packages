# Introduction

[1]: https://github.com/openresty/lua-nginx-module
[2]: https://github.com/openresty/openresty
[3]: https://github.com/vuejs/core
[4]: https://github.com/vitejs/vite

Oui is a `framework` for developing `OpenWrt` Web interfaces.

Oui uses Nginx as its static file server and uses the [lua-nginx][1] module to process the API. The [lua-nginx][1] module comes from the famous [OpenResty][2] project and is the core module.

The Oui front-end is written in [Vue3][3], and the front-end code is build with [Vite][4].

Unlike traditional front-end projects, all pages are packaged as a whole. Oui implements the same modularity as Luci, with each page packaged independently of the other. This is done by packaging each page as a library.

::: tip
Oui uses the [Naive UI](https://www.naiveui.com/) component library by default. You can choose your own library or develop your own components according to your needs.
:::
