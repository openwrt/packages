#
# Copyright (C) 2019 Xingwang Liao
# Copyright (C) 2019 Alonzo Liu <unl89@protonmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=v2ray-core
PKG_VERSION:=4.20.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/v2ray/v2ray-core/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=579a7098b8f6cc68c3f94c5453fa274299f8b072736f364654298bd4cf57d24e

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Alonzo Liu <unl89@protonmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=v2ray.com/core

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/v2ray-core/Default
  TITLE:=A platform for building proxies
  URL:=https://www.v2ray.com
endef

define Package/v2ray-core/Default/description
  Project V is a set of network tools that help you to build your own computer network.
  It secures your network connections and thus protects your privacy.
endef

define Package/v2ray-core
  $(call Package/v2ray-core/Default)
  TITLE+= (full)
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-certificates
endef

define Package/v2ray-core/description
$(call Package/v2ray-core/Default/description)

  This package contains v2ray, v2ctl and v2ray-assets.
endef

GEOIP_VER:=20190516.1
GEOIP_MD5:=b6f6b19e4028b8b7d569b424dadfc737
GEOIP_FILE:=geoip.dat.$(GEOIP_VER)

define Download/geoip
  URL:=https://github.com/v2ray/geoip/releases/download/$(GEOIP_VER)/
  URL_FILE:=geoip.dat
  MD5SUM:=$(GEOIP_MD5)
  FILE:=$(GEOIP_FILE)
endef
$(eval $(call Download,geoip))

GEOSITE_VER:=20190829.1
GEOSITE_MD5:=628ccce62cc0633a3cf8e39717faa7d0
GEOSITE_FILE:=dlc.dat.$(GEOSITE_VER)

define Download/geosite
  URL:=https://github.com/v2ray/domain-list-community/releases/download/$(GEOSITE_VER)/
  URL_FILE:=dlc.dat
  MD5SUM:=$(GEOSITE_MD5)
  FILE:=$(GEOSITE_FILE)
endef
$(eval $(call Download,geosite))

define Build/Prepare
	$(Build/Prepare/Default)
	( \
		sed -i \
			's/\(version[[:space:]]*=[[:space:]]*"\).*\("\)/\1$(PKG_VERSION)\2/; \
			s/\(build[[:space:]]*=[[:space:]]*"\).*\("\)/\1OpenWrt - Release $(PKG_RELEASE)\2/' \
			$(PKG_BUILD_DIR)/core.go ; \
	)
	cp $(DL_DIR)/$(GEOIP_FILE) $(PKG_BUILD_DIR)/release/config/geoip.dat
	cp $(DL_DIR)/$(GEOSITE_FILE) $(PKG_BUILD_DIR)/release/config/geosite.dat
endef

GO_PKG_LDFLAGS:=-s -w

define Build/Compile
	$(eval GO_PKG_BUILD_PKG:=v2ray.com/core/main)
	$(call GoPackage/Build/Compile,)
	mv -f $(GO_PKG_BUILD_BIN_DIR)/main $(GO_PKG_BUILD_BIN_DIR)/v2ray

	$(eval GO_PKG_BUILD_PKG:=v2ray.com/core/infra/control/main)
	$(call GoPackage/Build/Compile,)
	mv -f $(GO_PKG_BUILD_BIN_DIR)/main $(GO_PKG_BUILD_BIN_DIR)/v2ctl
endef

define Package/v2ray-core/install
	$(INSTALL_DIR) $(1)/usr/bin

	$(INSTALL_BIN) \
		$(GO_PKG_BUILD_BIN_DIR)/v2ray \
		$(1)/usr/bin

	$(INSTALL_BIN) \
		$(GO_PKG_BUILD_BIN_DIR)/v2ctl \
		$(1)/usr/bin

	$(INSTALL_DATA) \
		$(PKG_BUILD_DIR)/release/config/{geoip,geosite}.dat \
		$(1)/usr/bin

endef

$(eval $(call GoBinPackage,v2ray-core))
$(eval $(call BuildPackage,v2ray-core))
