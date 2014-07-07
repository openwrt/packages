#
# Copyright (C) 2008-2014 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=wavemon
PKG_VERSION:=0.7.6
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://eden-feed.erg.abdn.ac.uk/wavemon/stable-releases
PKG_MD5SUM:=c60e25feb8b1785cf14371556f0613f4

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/wavemon
  SECTION:=net
  CATEGORY:=Network
  MAINTAINER:=Jonathan McCrohan <jmccrohan@gmail.com>
  TITLE:=N-curses based wireless network devices monitor
  DEPENDS:=+libncurses +libpthread
  SUBMENU:=wireless
  URL:=http://eden-feed.erg.abdn.ac.uk/wavemon/
endef

define Package/wavemon/description
  wavemon is a ncurses-based monitoring application for wireless network
  devices. It currently works under Linux with devices that are supported
  by the wireless extensions by Jean Tourrilhes (included in Kernel 2.4
  and higher), e.g. the Lucent Orinoco cards.
endef

CONFIGURE_VARS += \
	ac_cv_lib_cap_cap_get_flag=no

TARGET_CFLAGS += -pthread

MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS) -L$(STAGING_DIR)/usr/lib -I$(STAGING_DIR)/usr/include"

define Package/wavemon/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/wavemon $(1)/usr/bin/
endef

$(eval $(call BuildPackage,wavemon))
