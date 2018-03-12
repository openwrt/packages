# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gawk
PKG_VERSION:=4.2.0
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNU/gawk

PKG_HASH:=d4f3cd31c001fd0ed52832d4fbfbdfeaa38ad541c182f80ff8fdf87324a6a9f2

PKG_LICENSE:=GPL
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/gawk
  SECTION:=utils
  CATEGORY:=Utilities
  URL:=https://www.gnu.org/software/gawk/
  TITLE:=GNU awk
  DEPENDS:=+libncursesw +libreadline
endef

define Package/gawk/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/gawk $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib/gawk
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/gawk/* $(1)/usr/lib/gawk/
	$(INSTALL_DIR) $(1)/usr/lib/awk
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/awk/* $(1)/usr/lib/awk/
	$(INSTALL_DIR) $(1)/usr/share/awk
	$(CP) $(PKG_INSTALL_DIR)/usr/share/awk/* $(1)/usr/share/awk/
endef

$(eval $(call BuildPackage,gawk))

