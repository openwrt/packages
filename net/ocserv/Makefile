#
# Copyright (C) 2007-2026 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ocserv
PKG_VERSION:=1.5.0
PKG_RELEASE:=1
PKG_BUILD_FLAGS:=no-mips16

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://www.infradead.org/ocserv/download/
PKG_HASH:=42ced08958b9576ab134fcb7bdc7f8df5e13214fd147855f99021fedcf0eedbe

PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_CONFIG_DEPENDS:= \
	CONFIG_OCSERV_PAM \
	CONFIG_OCSERV_SECCOMP \
	CONFIG_OCSERV_PROTOBUF \
	CONFIG_OCSERV_RADIUS \
	CONFIG_OCSERV_LIBOATH

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

define Package/ocserv/config
	source "$(SOURCE)/Config.in"
endef

define Package/ocserv
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=VPN
  TITLE:=OpenConnect VPN server
  URL:=https://ocserv.openconnect-vpn.net/
  MAINTAINER:=Nikos Mavrogiannopoulos <n.mavrogiannopoulos@gmail.com>
  DEPENDS:= +USE_GLIBC:libcrypt-compat +OCSERV_RADIUS:libradcli +OCSERV_SECCOMP:libseccomp +libgnutls +certtool +libncurses +libreadline +OCSERV_PAM:libpam +OCSERV_PROTOBUF:libprotobuf-c +OCSERV_LIBOATH:liboath +libev +kmod-tun
  USERID:=ocserv=72:ocserv=72
endef

define Package/ocserv/description
 OpenConnect server (ocserv) is an SSL VPN server. Its purpose is to be
 a secure, small, fast and configurable VPN server. It implements the
 OpenConnect SSL VPN protocol, and has also (currently experimental)
 compatibility with clients using the AnyConnect SSL VPN protocol. The
 OpenConnect VPN protocol uses the standard IETF security protocols such
 as TLS 1.2, and Datagram TLS to provide the secure VPN service.
endef

MESON_ARGS += \
	-Dpager='' \
	-Dlibnl=disabled \
	-Dgssapi=disabled \
	-Dmaxmind=disabled \
	-Dlz4=disabled \
	-Dfirewall-script=nftables \
	-Dlocal-talloc=true \
	-Dsock-diag=disabled

# Conditional features derived from Config.in
MESON_ARGS += -Dpam=$(if $(CONFIG_OCSERV_PAM),enabled,disabled)
MESON_ARGS += -Dradius=$(if $(CONFIG_OCSERV_RADIUS),enabled,disabled)
MESON_ARGS += -Dseccomp=$(if $(CONFIG_OCSERV_SECCOMP),enabled,disabled)
MESON_ARGS += -Dlocal-protobuf=$(if $(CONFIG_OCSERV_PROTOBUF),false,true)
MESON_ARGS += -Dliboath=$(if $(CONFIG_OCSERV_LIBOATH),enabled,disabled)

define Package/ocserv/conffiles
/etc/config/ocserv
endef

define Package/ocserv/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ocserv $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ocserv-worker $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ocpasswd $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/occtl $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/usr/libexec
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/libexec/ocserv-fw $(1)/usr/libexec/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/ocserv.init $(1)/etc/init.d/ocserv

	$(INSTALL_DIR) $(1)/etc/ocserv
	$(INSTALL_CONF) ./files/ocserv.conf.template $(1)/etc/ocserv/ocserv.conf.template

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/config $(1)/etc/config/ocserv

	$(INSTALL_DIR) $(1)/lib/upgrade/keep.d
	$(INSTALL_DATA) ./files/ocserv.upgrade $(1)/lib/upgrade/keep.d/ocserv
endef

$(eval $(call BuildPackage,ocserv))
