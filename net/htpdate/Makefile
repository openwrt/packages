#
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=htpdate
PKG_VERSION:=1.1.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=http://www.vervest.org/htp/archive/c/
PKG_MD5SUM:=c612f63282e3f23b709f37a5c81d4739

PKG_LICENSE:=GPL-2.0+
PKG_LICENSE_FILES:=

include $(INCLUDE_DIR)/package.mk

define Package/htpdate
  SUBMENU:=Time Synchronization
  SECTION:=net
  CATEGORY:=Network
  TITLE:=an HTP (Hypertext Time Protocol) implementation
  URL:=http://www.vervest.com/htp/
  MAINTAINER:=Tijs Van Buggenhout <tvbuggen@netzerk.be>
endef

define Package/htpdate/description
	The HTTP Time Protocol (HTP) is used to synchronize a computer's time
	with web servers as reference time source. Htpdate will synchronize your
	computer's time by extracting timestamps from HTTP headers found
	in web server responses. Htpdate can be used as a daemon, to keep your
	computer synchronized.
endef

define Package/htpdate/conffiles
/etc/default/htpdate
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)"
endef

define Package/htpdate/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/htpdate $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/default/
	$(INSTALL_CONF) ./files/htpdate.default $(1)/etc/default/htpdate
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/htpdate.init $(1)/etc/init.d/htpdate
endef

$(eval $(call BuildPackage,htpdate))

