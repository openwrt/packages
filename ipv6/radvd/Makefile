#
# Copyright (C) 2006-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=radvd
PKG_VERSION:=1.9.1
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://v6web.litech.org/radvd/dist \
		http://download.sourcemage.org/mirror
PKG_MD5SUM:=e807ad7e9a76d46b6133df391385cd31

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/radvd/Default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=IPv6 Routing Advertisement
  URL:=http://v6web.litech.org/radvd/
  DEPENDS:=+kmod-ipv6 +libdaemon
endef

define Package/radvd
  $(call Package/radvd/Default)
  TITLE+= Daemon
endef

define Package/radvd/description
radvd is the router advertisement daemon for IPv6. It listens to router
solicitations and sends router advertisements as described in "Neighbor
Discovery for IP Version 6 (IPv6)" (RFC 4861).  With these advertisements hosts
can automatically configure their addresses and some other parameters. They also
can choose a default router based on these advertisements.
endef

define Package/radvdump
  $(call Package/radvd/Default)
  TITLE+= Dumper
endef

define Package/radvdump/description
radvdump prints out the contents of incoming router advertisements sent by radvd
or some other software implementing (parts of) "Neighbor Discovery for IP
Version 6 (IPv6)" (RFC 4861).
endef

CONFIGURE_ARGS += \
	--with-configfile=/etc/radvd.conf \
	--with-logfile=/var/log/radvd.log \
	--with-pidfile=/var/run/radvd.pid

define Package/radvd/conffiles
/etc/config/radvd
endef

define Package/radvd/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/radvd.config $(1)/etc/config/radvd
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/radvd.init $(1)/etc/init.d/radvd
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/radvd $(1)/usr/sbin/
endef

define Package/radvdump/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/radvdump $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,radvd))
$(eval $(call BuildPackage,radvdump))
