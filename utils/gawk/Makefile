# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gawk
PKG_VERSION:=4.1.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNU/gawk

PKG_MD5SUM:=53e184e2d0f90def9207860531802456322be091c7b48f23fdc79cda65adc266

PKG_LICENSE:=GPL
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/gawk
  SECTION:=utils
  CATEGORY:=Utilities
  URL:=http://tukaani.org/xz
  TITLE:=GNU awk
  DEPENDS:=+libncursesw +libreadline
endef

define Package/gawk/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/{gawk,igawk} $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib/gawk
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/gawk/* $(1)/usr/lib/gawk/
	$(INSTALL_DIR) $(1)/usr/lib/awk
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/awk/* $(1)/usr/lib/awk/
	$(INSTALL_DIR) $(1)/usr/share/awk
	$(CP) $(PKG_INSTALL_DIR)/usr/share/awk/* $(1)/usr/share/awk/
endef

$(eval $(call BuildPackage,gawk))

