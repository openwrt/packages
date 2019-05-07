#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=vnstat2
PKG_VERSION:=2.2
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE:=vnstat-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://humdi.net/vnstat/
PKG_HASH:=c60a7bc35e0247b0d2e628d8fc39427f2482e844c2c7b9cdbfc814463310e02c
PKG_BUILD_DIR:=$(BUILD_DIR)/vnstat-$(PKG_VERSION)
PKG_MAINTAINER:=

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/vnstat2
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libsqlite3
  TITLE:=Traffic monitor using SQLite as backend
  URL:=https://humdi.net/vnstat/
  CONFLICTS:=vnstat
endef

define Package/vnstat2/description
  vnStat is a console-based network traffic monitor for Linux
  and BSD that keeps a log of network traffic for the selected
  interface(s). It uses the network interface statistics
  provided by the kernel as information source. This means
  that vnStat won't actually be sniffing any traffic and also
  ensures light use of system resources regardless of network
  traffic rate. 
endef

define Package/vnstat2/conffiles
/etc/vnstat.conf
endef

TARGET_CFLAGS += -ffunction-sections -fdata-sections -flto
TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed -flto

CONFIGURE_ARGS += --disable-image-output --disable-extra-paths

define Package/vnstat2/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/vnstat $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/vnstatd $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/vnstat.init $(1)/etc/init.d/vnstat
	$(CP) ./files/vnstat.conf $(1)/etc
endef

$(eval $(call BuildPackage,vnstat2))
