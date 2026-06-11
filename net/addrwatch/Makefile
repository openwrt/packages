#
# Copyright (C) 2006-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=addrwatch
PKG_VERSION:=1.0.2
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/fln/addrwatch/releases/download/v$(PKG_VERSION)
PKG_HASH:=f04e143da881cd63c299125b592cfb85e4812abbd146f419a1894c00f2ae6208

PKG_MAINTAINER:=Ondrej Caletka <ondrej@caletka.cz>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_BUILD_DEPENDS:=USE_MUSL:argp-standalone
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/addrwatch/Default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=IPv4/IPv6 and ethernet address pairing tool
  URL:=https://github.com/fln/addrwatch
endef

define Package/addrwatch/Default/description
  This is a tool similar to arpwatch. It main purpose is to monitor network and
  log discovered ethernet/ip pairings. Addrwatch is extremely useful in networks
  with IPv6 autoconfiguration (RFC4862) enabled. It allows to track IPv6
  addresses of hosts using IPv6 privacy extensions (RFC4941).
endef

define Package/addrwatch
$(call Package/addrwatch/Default)
  DEPENDS:=+libpcap +libevent2
endef

define Package/addrwatch/description
$(call Package/addrwatch/Default/description)

  This contains the main addrwatch program.
endef

define Package/addrwatch-mysql
$(call Package/addrwatch/Default)
  TITLE+= (MySQL output module)
  DEPENDS:=+addrwatch +libmariadb
endef

define Package/addrwatch-mysql/description
$(call Package/addrwatch/Default/description)

  This contains the MySQL output module.
endef

define Package/addrwatch-stdout
$(call Package/addrwatch/Default)
  TITLE+= (stdout output module)
  DEPENDS:=+addrwatch
endef

define Package/addrwatch-stdout/description
$(call Package/addrwatch/Default/description)

  This contains the stdout output module.
endef

define Package/addrwatch-syslog
$(call Package/addrwatch/Default)
  TITLE+= (syslog output module)
  DEPENDS:=+addrwatch
endef

define Package/addrwatch-syslog/description
$(call Package/addrwatch/Default/description)

  This contains the syslog output module.
endef

define Package/addrwatch/conffiles
/etc/config/addrwatch
endef

CONFIGURE_ARGS+= \
	--enable-mysql

define Package/addrwatch/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/config $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/addrwatch $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/addrwatch.init $(1)/etc/init.d/addrwatch
	$(INSTALL_CONF) ./files/addrwatch.config $(1)/etc/config/addrwatch
endef

define Package/addrwatch-mysql/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/addrwatch_mysql $(1)/usr/sbin/
endef

define Package/addrwatch-stdout/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/addrwatch_stdout $(1)/usr/sbin/
endef

define Package/addrwatch-syslog/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/addrwatch_syslog $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,addrwatch))
$(eval $(call BuildPackage,addrwatch-mysql))
$(eval $(call BuildPackage,addrwatch-stdout))
$(eval $(call BuildPackage,addrwatch-syslog))
