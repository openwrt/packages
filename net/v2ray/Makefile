#
# Copyright (C) 2019 Xingwang Liao
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=v2ray-core
PKG_VERSION:=4.20.0
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/v2ray/v2ray-core/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=579a7098b8f6cc68c3f94c5453fa274299f8b072736f364654298bd4cf57d24e

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Xingwang Liao <kuoruan@gmail.com>

PKG_CONFIG_DEPENDS := \
	CONFIG_V2RAY_JSON_V2CTL \
	CONFIG_V2RAY_JSON_INTERNAL \
	CONFIG_V2RAY_JSON_NONE \
	CONFIG_V2RAY_EXCLUDE_V2CTL \
	CONFIG_V2RAY_EXCLUDE_ASSETS \
	CONFIG_V2RAY_COMPRESS_UPX \
	CONFIG_V2RAY_DISABLE_NONE \
	CONFIG_V2RAY_DISABLE_CUSTOM \
	CONFIG_V2RAY_DISABLE_DNS \
	CONFIG_V2RAY_DISABLE_LOG \
	CONFIG_V2RAY_DISABLE_POLICY \
	CONFIG_V2RAY_DISABLE_REVERSE \
	CONFIG_V2RAY_DISABLE_ROUTING \
	CONFIG_V2RAY_DISABLE_STATISTICS \
	CONFIG_V2RAY_DISABLE_BLACKHOLE_PROTO \
	CONFIG_V2RAY_DISABLE_DNS_PROXY \
	CONFIG_V2RAY_DISABLE_DOKODEMO_PROTO \
	CONFIG_V2RAY_DISABLE_FREEDOM_PROTO \
	CONFIG_V2RAY_DISABLE_MTPROTO_PROXY \
	CONFIG_V2RAY_DISABLE_HTTP_PROTO \
	CONFIG_V2RAY_DISABLE_SHADOWSOCKS_PROTO \
	CONFIG_V2RAY_DISABLE_SOCKS_PROTO \
	CONFIG_V2RAY_DISABLE_VMESS_PROTO \
	CONFIG_V2RAY_DISABLE_TCP_TRANS \
	CONFIG_V2RAY_DISABLE_MKCP_TRANS \
	CONFIG_V2RAY_DISABLE_WEBSOCKET_TRANS \
	CONFIG_V2RAY_DISABLE_HTTP2_TRANS \
	CONFIG_V2RAY_DISABLE_DOMAIN_SOCKET_TRANS \
	CONFIG_V2RAY_DISABLE_QUIC_TRANS

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=v2ray.com/core

include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/golang/golang-package.mk

define Package/v2ray-core/Default
  TITLE:=A platform for building proxies
  URL:=https://www.v2ray.com
endef

define Package/v2ray-core/Default/description
Project V is a set of network tools that help you to build your own computer network.
It secures your network connections and thus protects your privacy.
endef

define project-v/SubMenu
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Project V
endef

define Package/v2ray-core
  $(call Package/v2ray-core/Default)
  $(call project-v/SubMenu)
  TITLE+= (full)
  USERID:=v2ray=10800:v2ray=10800
  DEPENDS:=$(GO_ARCH_DEPENDS) +ca-certificates
endef

define Package/v2ray-core/config
	source "$(SOURCE)/files/Config.in"
endef

define Package/v2ray-core/description
$(call Package/v2ray-core/Default/description)

  This package contains v2ray, v2ctl and v2ray-assets.
endef

V2RAY_SED_ARGS:=

ifeq ($(CONFIG_V2RAY_JSON_INTERNAL),y)
V2RAY_SED_ARGS += \
	s/_ "v2ray.com\/core\/main\/json"/\/\/ &/; \
	/\/\/ _ "v2ray.com\/core\/main\/jsonem"/s/\/\/ //;
else ifeq ($(CONFIG_V2RAY_JSON_NONE),y)
V2RAY_SED_ARGS += \
	s/_ "v2ray.com\/core\/main\/json"/\/\/ &/;
endif

ifeq ($(CONFIG_V2RAY_DISABLE_CUSTOM),y)

ifeq ($(CONFIG_V2RAY_DISABLE_DNS),y)
V2RAY_SED_ARGS += \
	s/_ "v2ray.com\/core\/app\/dns"/\/\/ &/;
endif

ifeq ($(CONFIG_V2RAY_DISABLE_LOG),y)
V2RAY_SED_ARGS += \
	s/_ "v2ray.com\/core\/app\/log"/\/\/ &/;
endif

ifeq ($(CONFIG_V2RAY_DISABLE_POLICY),y)
V2RAY_SED_ARGS += \
	s/_ "v2ray.com\/core\/app\/policy"/\/\/ &/;
endif

ifeq ($(CONFIG_V2RAY_DISABLE_REVERSE),y)
V2RAY_SED_ARGS += \
	s/_ "v2ray.com\/core\/app\/reverse"/\/\/ &/;
endif

ifeq ($(CONFIG_V2RAY_DISABLE_ROUTING),y)
V2RAY_SED_ARGS += \
	s/_ "v2ray.com\/core\/app\/router"/\/\/ &/;
endif

ifeq ($(CONFIG_V2RAY_DISABLE_STATISTICS),y)
V2RAY_SED_ARGS += \
	s/_ "v2ray.com\/core\/app\/stats"/\/\/ &/;
endif

ifeq ($(CONFIG_V2RAY_DISABLE_BLACKHOLE_PROTO),y)
V2RAY_SED_ARGS += \
	s/_ "v2ray.com\/core\/proxy\/blackhole"/\/\/ &/;
endif

ifeq ($(CONFIG_V2RAY_DISABLE_DNS_PROXY),y)
V2RAY_SED_ARGS += \
	s/_ "v2ray.com\/core\/proxy\/dns"/\/\/ &/;
endif

ifeq ($(CONFIG_V2RAY_DISABLE_DOKODEMO_PROTO),y)
V2RAY_SED_ARGS += \
	s/_ "v2ray.com\/core\/proxy\/dokodemo"/\/\/ &/;
endif

ifeq ($(CONFIG_V2RAY_DISABLE_FREEDOM_PROTO),y)
V2RAY_SED_ARGS += \
	s/_ "v2ray.com\/core\/proxy\/freedom"/\/\/ &/;
endif

ifeq ($(CONFIG_V2RAY_DISABLE_MTPROTO_PROXY),y)
V2RAY_SED_ARGS += \
	s/_ "v2ray.com\/core\/proxy\/mtproto"/\/\/ &/;
endif

ifeq ($(CONFIG_V2RAY_DISABLE_HTTP_PROTO),y)
V2RAY_SED_ARGS += \
	s/_ "v2ray.com\/core\/proxy\/http"/\/\/ &/;
endif

ifeq ($(CONFIG_V2RAY_DISABLE_SHADOWSOCKS_PROTO),y)
V2RAY_SED_ARGS += \
	s/_ "v2ray.com\/core\/proxy\/shadowsocks"/\/\/ &/;
endif

ifeq ($(CONFIG_V2RAY_DISABLE_SOCKS_PROTO),y)
V2RAY_SED_ARGS += \
	s/_ "v2ray.com\/core\/proxy\/socks"/\/\/ &/;
endif

ifeq ($(CONFIG_V2RAY_DISABLE_VMESS_PROTO),y)
V2RAY_SED_ARGS += \
	s/_ "v2ray.com\/core\/proxy\/vmess\/inbound"/\/\/ &/; \
	s/_ "v2ray.com\/core\/proxy\/vmess\/outbound"/\/\/ &/;
endif

ifeq ($(CONFIG_V2RAY_DISABLE_TCP_TRANS),y)
V2RAY_SED_ARGS += \
	s/_ "v2ray.com\/core\/transport\/internet\/tcp"/\/\/ &/;
endif

ifeq ($(CONFIG_V2RAY_DISABLE_MKCP_TRANS),y)
V2RAY_SED_ARGS += \
	s/_ "v2ray.com\/core\/transport\/internet\/kcp"/\/\/ &/;
endif

ifeq ($(CONFIG_V2RAY_DISABLE_WEBSOCKET_TRANS),y)
V2RAY_SED_ARGS += \
	s/_ "v2ray.com\/core\/transport\/internet\/websocket"/\/\/ &/;
endif

ifeq ($(CONFIG_V2RAY_DISABLE_HTTP2_TRANS),y)
V2RAY_SED_ARGS += \
	s/_ "v2ray.com\/core\/transport\/internet\/http"/\/\/ &/;
endif

ifeq ($(CONFIG_V2RAY_DISABLE_DOMAIN_SOCKET_TRANS),y)
V2RAY_SED_ARGS += \
	s/_ "v2ray.com\/core\/transport\/internet\/domainsocket"/\/\/ &/;
endif

ifeq ($(CONFIG_V2RAY_DISABLE_QUIC_TRANS),y)
V2RAY_SED_ARGS += \
	s/_ "v2ray.com\/core\/transport\/internet\/quic"/\/\/ &/;
endif

endif

define Build/Prepare
	$(Build/Prepare/Default)
	( \
		sed -i \
			's/\(version[[:space:]]*=[[:space:]]*"\).*\("\)/\1$(PKG_VERSION)\2/; \
			s/\(build[[:space:]]*=[[:space:]]*"\).*\("\)/\1OpenWrt - Release $(PKG_RELEASE)\2/' \
			$(PKG_BUILD_DIR)/core.go ; \
	)
ifneq ($(V2RAY_SED_ARGS),)
	( \
		sed -i \
			'$(V2RAY_SED_ARGS)' \
			$(PKG_BUILD_DIR)/main/distro/all/all.go ; \
	)
endif
ifneq ($(CONFIG_V2RAY_EXCLUDE_ASSETS),y)
	wget -O $(PKG_BUILD_DIR)/release/config/geoip.dat \
		https://github.com/v2ray/geoip/releases/latest/download/geoip.dat

	wget -O $(PKG_BUILD_DIR)/release/config/geosite.dat \
		https://github.com/v2ray/domain-list-community/releases/latest/download/dlc.dat
endif
endef

define Build/Compile
	$(eval GO_PKG_BUILD_PKG:=v2ray.com/core/main)
	$(call GoPackage/Build/Compile,-ldflags "-s -w")
	mv -f $(GO_PKG_BUILD_BIN_DIR)/main $(GO_PKG_BUILD_BIN_DIR)/v2ray

ifeq ($(CONFIG_V2RAY_COMPRESS_UPX),y)
	upx --ultra-brute $(GO_PKG_BUILD_BIN_DIR)/v2ray
endif

ifneq ($(CONFIG_V2RAY_EXCLUDE_V2CTL),y)
	$(eval GO_PKG_BUILD_PKG:=v2ray.com/core/infra/control/main)
	$(call GoPackage/Build/Compile,-ldflags "-s -w")
	mv -f $(GO_PKG_BUILD_BIN_DIR)/main $(GO_PKG_BUILD_BIN_DIR)/v2ctl

ifeq ($(CONFIG_V2RAY_COMPRESS_UPX),y)
	upx --ultra-brute $(GO_PKG_BUILD_BIN_DIR)/v2ctl
endif
endif
endef

define Package/v2ray-core/install
	$(INSTALL_DIR) $(1)/usr/bin

	$(INSTALL_BIN) \
		$(GO_PKG_BUILD_BIN_DIR)/v2ray \
		$(1)/usr/bin

ifneq ($(CONFIG_V2RAY_EXCLUDE_V2CTL),y)
	$(INSTALL_BIN) \
		$(GO_PKG_BUILD_BIN_DIR)/v2ctl \
		$(1)/usr/bin
endif

ifneq ($(CONFIG_V2RAY_EXCLUDE_ASSETS),y)
	$(INSTALL_DATA) \
		$(PKG_BUILD_DIR)/release/config/{geoip,geosite}.dat \
		$(1)/usr/bin
endif
endef

define Package/golang-v2ray-core-dev
$(call Package/v2ray-core/Default)
$(call GoPackage/GoSubMenu)
  TITLE+= (source files)
  PKGARCH:=all
endef

define Package/golang-v2ray-core-dev/description
$(call Package/v2ray-core/Default/description)

This package provides the source files for v2ray-core.
endef

$(eval $(call GoBinPackage,v2ray-core))
$(eval $(call BuildPackage,v2ray-core))
$(eval $(call GoSrcPackage,golang-v2ray-core-dev))
$(eval $(call BuildPackage,golang-v2ray-core-dev))
