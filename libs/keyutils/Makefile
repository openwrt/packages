# 
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=keyutils
PKG_VERSION:=1.5.11
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://people.redhat.com/dhowells/keyutils/
PKG_HASH:=11584488206edc30736263eb855bf7793f16e661987241d333d3cb5ea479b1b5

PKG_FIXUP:=libtool

include $(INCLUDE_DIR)/package.mk

define Package/libkeyutils
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Key utilities library
  DEPENDS:=+krb5
  URL:=http://people.redhat.com/dhowells/keyutils/
endef

define Package/keyutils/description
  Key utilities library
endef

define Build/Install
	make -C $(PKG_BUILD_DIR) DESTDIR=$(PKG_INSTALL_DIR) LIBDIR=/usr/lib install
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libkeyutils.{a,so*} $(1)/usr/lib/
endef

define Package/libkeyutils/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libkeyutils.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libkeyutils))
