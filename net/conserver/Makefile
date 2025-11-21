#
# Copyright (C) 2017 Bjørn Mork <bjorn@mork.no>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=conserver
PKG_VERSION:=8.2.7
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/conserver/conserver/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=b88f1880f4090b42370e075ca9c8a6062fb553ee33f155b204714c43dc71cef3

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/conserver
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Connect multiple user to a serial console with logging
  URL:=http://www.conserver.com/
  DEPENDS:=+libopenssl
  MAINTAINER:=Bjørn Mork <bjorn@mork.no>
  VARIANT:=default
  CONFLICTS:=conserver-ipmi
endef

define Package/conserver-ipmi
  $(call Package/conserver)
  TITLE:=Conserver with IPMI support
  PROVIDES:=conserver
  DEPENDS+=+libipmiconsole
  VARIANT:=ipmi
  CONFLICTS:=
endef

define Package/conserver/description
 Conserver is an application that allows multiple users to watch a
 serial console at the same time.  It can log the data, allows users
 to take write-access of a console (one at a time), and has a
 variety of bells and whistles to accentuate that basic
 functionality.  The idea is that conserver will log all your serial
 traffic so you can go back and review why something crashed, look
 at changes (if done on the console), or tie the console logs into a
 monitoring system (just watch the logfiles it creates).  With
 multi-user capabilities you can work on equipment with others,
 mentor, train, etc.  It also does all that client-server stuff so
 that, assuming you have a network connection, you can interact with
 any of the equipment from home or wherever.
endef

define Package/conserver-ipmi/description
 $(call Package/conserver/description)
 .
 This variant is built with support for IPMI serial-over-LAN consoles,
 adding a large dependency on FreeIPMI
endef


define Package/conserver/conffiles
/etc/conserver/conserver.cf
/etc/conserver/conserver.passwd
/etc/conserver/console.cf
endef

Package/conserver-ipmi/conffiles=$(Package/conserver/conffiles)

CONFIGURE_ARGS += \
	--with-openssl \
	$(if $(CONFIG_IPV6),--with-ipv6) \
	--sysconfdir=/etc/conserver \
	--with-port=3109 \
	--with-logfile=/var/log/conserver/server.log

ifeq ($(BUILD_VARIANT),ipmi)
	CONFIGURE_ARGS += --with-freeipmi
endif

define Build/Prepare
	$(call Build/Prepare/Default)
	$(CP) ./files/config.sub $(PKG_BUILD_DIR)/
	$(CP) ./files/config.guess $(PKG_BUILD_DIR)/
endef

define Package/conserver/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/conserver $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/console $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/conserver
	$(INSTALL_CONF) ./files/conserver.cf $(1)/etc/conserver/
	$(INSTALL_CONF) ./files/console.cf $(1)/etc/conserver/
	touch $(1)/etc/conserver/conserver.passwd
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/conserver.init $(1)/etc/init.d/conserver
endef

Package/conserver-ipmi/install=$(Package/conserver/install)

$(eval $(call BuildPackage,conserver))
$(eval $(call BuildPackage,conserver-ipmi))
