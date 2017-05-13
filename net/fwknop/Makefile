#
# Copyright (C) 2011-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=fwknop
PKG_VERSION:=2.6.9
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://www.cipherdyne.org/fwknop/download
PKG_MD5SUM:=e2c49e9674888a028bd443a55c3aaa22
PKG_HASH:=5bf47fe1fd30e862d29464f762c0b8bf89b5e298665c37624d6707826da956d4
PKG_MAINTAINER:=Jonathan Bennett <JBennett@incomsystems.biz>
PKG_LICENSE:=GPLv2
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/fwknop/Default
  TITLE:=FireWall KNock OPerator
  URL:=http://www.cipherdyne.org/fwknop/
endef

define Package/fwknop/Default/description
  Fwknop implements an authorization scheme known as Single Packet Authorization
  (SPA) for Linux systems running iptables.  This mechanism requires only a
  single encrypted and non-replayed packet to communicate various pieces of
  information including desired access through an iptables policy. The main
  application of this program is to use iptables in a default-drop stance to
  protect services such as SSH with an additional layer of security in order to
  make the exploitation of vulnerabilities (both 0-day and unpatched code) much
  more difficult.
endef

define Package/fwknopd
  $(call Package/fwknop/Default)
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Firewall
  TITLE+= Daemon
  DEPENDS:=+iptables +libfko +!FWKNOPD_NFQ_CAPTURE:libpcap +FWKNOPD_NFQ_CAPTURE:iptables-mod-nfqueue +FWKNOP_GPG:gnupg \
	+FWKNOPD_NFQ_CAPTURE:libnetfilter-queue +FWKNOPD_NFQ_CAPTURE:libnfnetlink
endef

define Package/fwknopd/description
  $(call Package/fwknop/Default/description)
  This package contains the fwknop daemon.
endef

define Package/fwknopd/conffiles
/etc/fwknop/access.conf
/etc/fwknop/fwknopd.conf
/etc/config/fwknopd
endef

define Package/fwknopd/config
	source "$(SOURCE)/Config.in"
endef

define Package/fwknop
  $(call Package/fwknop/Default)
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Firewall
  TITLE+= Client
  DEPENDS:=+libfko
endef

define Package/fwknop/description
  $(call Package/fwknop/Default/description)
  This package contains the fwknop client.
endef

define Package/libfko
  $(call Package/fwknop/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Firewall
  TITLE+= Library
endef

define Package/libfko/description
  $(call Package/fwknop/Default/description)
  This package contains the libfko shared library.
endef


ifneq ($(CONFIG_FWKNOPD_GPG),y)
	CONFIGURE_ARGS += --without-gpgme 
endif

ifeq ($(CONFIG_FWKNOPD_NFQ_CAPTURE),y)
 	CONFIGURE_ARGS += --enable-nfq-capture 
endif

CONFIGURE_ARGS += \
	--with-iptables=/usr/sbin/iptables

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/fko.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libfko.{a,la,so*} $(1)/usr/lib/
endef

define Package/fwknopd/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/fwknopd $(1)/etc/config/fwknopd
	$(INSTALL_DIR) $(1)/etc/fwknop
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/etc/fwknop/{access,fwknopd}.conf \
		$(1)/etc/fwknop/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/fwknopd.init $(1)/etc/init.d/fwknopd
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/fwknopd $(1)/usr/sbin/
endef

define Package/fwknop/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/fwknop $(1)/usr/bin/
endef

define Package/libfko/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libfko.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,fwknopd))
$(eval $(call BuildPackage,fwknop))
$(eval $(call BuildPackage,libfko))
