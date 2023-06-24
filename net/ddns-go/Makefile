# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2021-2023  sirpdboy  <herboy2008@gmail.com> https://github.com/sirpdboy/luci-app-ddns-go 
# 
# This is free software, licensed under the Apache License, Version 2.0 .
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ddns-go
PKG_VERSION:=5.3.6
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/jeessy2/ddns-go.git
PKG_MIRROR_HASH:=7b865a8b9618147514c4bb6220f02d2404ab5f6586e27797b717b4d7b61b81b6
PKG_SOURCE_VERSION:=4d33865890bffebeebb1fe49f079d67c1d8c4625

PKG_LICENSE:=AGPL-3.0-only
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=herboy2008 <herboy2008@gmail.com>

PKG_CONFIG_DEPENDS:= \
	CONFIG_DDNS-GO_COMPRESS_GOPROXY \
	CONFIG_DDNS-GO_COMPRESS_UPX

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/jeessy2/ddns-go/v5
GO_PKG_LDFLAGS:=-s -w
GO_PKG_LDFLAGS_X:=m.version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/ddns-go
  TITLE:=A Linux web GUI client of ddns-go
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-bundle 
  URL:=https://github.com/jeessy2/ddns-go
endef

define Package/$(PKG_NAME)/description
  ddns-go is a automatically obtain your public IPv4 or IPv6 address and resolve it to the corresponding domain name service,
  support Alidns Dnspod Cloudflare Hicloud Callback Baiducloud porkbun GoDaddy Google Domains.
endef

define Package/$(PKG_NAME)/config
config DDNS-GO_COMPRESS_GOPROXY
	bool "Compiling with GOPROXY proxy"
	default n

config DDNS-GO_COMPRESS_UPX
	bool "Compress executable files with UPX"
	depends on !mips64
	default n
endef

ifeq ($(CONFIG_DDNS-GO_COMPRESS_GOPROXY),y)
	export GO111MODULE=on
	export GOPROXY=https://goproxy.baidu.com
endif

define Package/$(PKG_NAME)/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	[ -f /etc/uci-defaults/luci-ddns-go ] && /etc/uci-defaults/luci-ddns-go && rm -f /etc/uci-defaults/luci-ddns-go
fi
endef

define Build/Compile
	$(call GoPackage/Build/Compile)
ifneq ($(CONFIG_DDNS-GO_COMPRESS_UPX),)
	$(STAGING_DIR_HOST)/bin/upx --lzma --best $(GO_PKG_BUILD_BIN_DIR)/ddns-go
endif
endef

define Package/$(PKG_NAME)/install
	$(call GoPackage/Package/Install/Bin,$(1))

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./file/ddns-go.init $(1)/etc/init.d/ddns-go

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./file/luci-ddns-go.uci-default $(1)/etc/uci-defaults/luci-ddns-go
endef

$(eval $(call GoBinPackage,ddns-go))
$(eval $(call BuildPackage,ddns-go))
