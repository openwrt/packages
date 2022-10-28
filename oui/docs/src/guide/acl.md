# ACL

## Introduction

Oui divides permissions into permission groups, and each permission group is divided into permission classes.
Each permission class consists of multiple matching items. Each user needs to be assigned a permission group.

By default, Oui has a permission group named `admin`, whose configuration file is: /usr/share/oui/acl/admin.json

```json
{
    "rpc": {
        "matchs": [".+"]
    },
    "menu": {
        "matchs": [".+"]
    },
    "ubus": {
        "matchs": [".+"]
    },
    "uci": {
        "matchs": [".+"]
    }
}
```

Currently, there are four permission classes:

* rpc - `rpc` interface call permission
* menu - Hidden or show menu
* ubus - `ubus` call permission
* uci - `uci` operating permission

The matching items are an array, and all the matching items in the `admin` permission group are `.+ `, indicating any matching, that is, each category has all permissions.

:::tip
The match here is actually a regular expression. Can be any `Lua` regular expression.
:::

## Reverse matching

```json
{
    "rpc": {
        "matchs": ["^uci.get$"],
        "reverse": true
    }
}
```
Set the `reverse` attribute of the permission class to `true` to reverse the matching.

## Examples of matches

### rpc

```json
{
    "rpc": {
        "matchs": [".+"]
    }
}
```
Matches all `rpc` interfaces

```json
{
    "rpc": {
        "matchs": ["^uci%..+"]
    }
}
```
Matches all methods in the `uci` module

```json
{
    "rpc": {
        "matchs": ["^uci%..+", "^system%..+"]
    }
}
```
Matches all methods in the `uci` and `system` modules

```json
{
    "rpc": {
        "matchs": ["^uci%.get$"]
    }
}
```
Matches the `get` method in the `uci` module

```json
{
    "rpc": {
        "matchs": ["^uci%.get$"],
        "reverse": true
    }
}
```
Does not match the `get` method of the `uci` module, that is, except the `get` method of the `uci` module cannot be called, all other interfaces can be called.

### menu

```json
{
    "menu": {
        "matchs": ["^/system/"]
    }
}
```
Matches menus starting with `/system/`

```json
{
    "menu": {
        "matchs": ["^/system/upgrade$"]
    }
}
```
Match `/system/upgrade` menu

```json
{
    "menu": {
        "matchs": ["^/system/upgrade$"],
        "reverse": true
    }
}
```
Hide the `/system/upgrade` menu

### uci

```json
{
    "uci": {
        "matchs": ["^system$"]
    }
}
```
Only `/etc/config/system` is allowed
