# SPDX-Identifier-License: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=nload
PKG_VERSION:=0.7.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/rolandriegel/nload/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=a73b3a75356776860fc4c40daebce04c5022f73d39704a12fb0aeb88a751216a

PKG_MAINTAINER:=Jacky Guo <leickwell@hotmail.com>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/nload
  SECTION:=admin
  CATEGORY:=Administration
  TITLE:=A network traffic monitor
  DEPENDS:=+libncurses +libstdcpp
  URL:=https://github.com/rolandriegel/nload
endef

define Package/nload/description
  Monitors network traffic and bandwidth usage.
endef

define Package/nload/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/nload $(1)/usr/bin/
endef

$(eval $(call BuildPackage,nload))
