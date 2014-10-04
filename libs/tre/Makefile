#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=tre
PKG_VERSION:=0.8.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=http://laurikari.net/tre
PKG_MD5SUM:=b4d3232593dadf6746f4727bdda20b41

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/tre
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=The free and portable approximate regex matching library
  URL:=http://laurikari.net/tre/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/tre
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/include/tre/* \
		$(1)/usr/include/tre

	$(INSTALL_DIR) $(1)/usr/lib $(1)/usr/lib/pkgconfig
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libtre.{la,so*} \
		$(1)/usr/lib
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/pkgconfig/tre.pc \
		$(1)/usr/lib/pkgconfig
endef

define Package/tre/install
	$(INSTALL_DIR) $(1)/usr/lib $(1)/usr/bin
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/libtre.so* \
		$(1)/usr/lib
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/agrep \
		$(1)/usr/bin
endef

$(eval $(call BuildPackage,tre))
