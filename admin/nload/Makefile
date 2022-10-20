#
# This is free software, licensed under the GNU General Public License v2.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=nload
PKG_VERSION:=0.7.4
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.roland-riegel.de/nload/
PKG_HASH:=c1c051e7155e26243d569be5d99c744d8620e65fa8a7e05efcf84d01d9d469e5

PKG_MAINTAINER:=Jacky Guo <leickwell@Hotmail.com>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/nload
  SECTION:=admin
  CATEGORY:=Administration
  TITLE:=Real time network traffic monitor for the text console
  DEPENDS:=+libncurses +libstdcpp
  URL:=https://github.com/rolandriegel/nload
endef

define Package/nload/description
  monitors network traffic and bandwidth usage
endef

define Package/nload/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/nload $(1)/usr/bin/
endef

$(eval $(call BuildPackage,nload))
