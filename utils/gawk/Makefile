# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gawk
PKG_VERSION:=5.2.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNU/gawk
PKG_HASH:=e4ddbad1c2ef10e8e815ca80208d0162d4c983e6cca16f925e8418632d639018

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

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

