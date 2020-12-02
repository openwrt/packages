#
# Copyright (C) 2008-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=wavemon
PKG_VERSION:=0.9.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/uoaerg/wavemon/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=13334ff17720ba4d17f4658dd2b93a50a6b5bc0583dedd72b88fd0cb90db686a

PKG_MAINTAINER:=Jonathan McCrohan <jmccrohan@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/wavemon
  SECTION:=net
  CATEGORY:=Network
  TITLE:=N-curses based wireless network devices monitor
  DEPENDS:=+libncurses +libpthread +libnl-genl
  SUBMENU:=Wireless
  URL:=https://github.com/uoaerg/wavemon/releases
endef

define Package/wavemon/description
  wavemon is a ncurses-based monitoring application for wireless network
  devices. It currently works under Linux with devices that are supported
  by the wireless extensions by Jean Tourrilhes (included in Kernel 2.4
  and higher), e.g. the Lucent Orinoco cards.
endef

CONFIGURE_ARGS += --without-libcap

TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include/libnl3
TARGET_LDFLAGS += $(if $(CONFIG_USE_GLIBC),-lpthread)

define Package/wavemon/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/wavemon $(1)/usr/bin/
endef

$(eval $(call BuildPackage,wavemon))
