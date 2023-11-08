#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=efivar
PKG_VERSION:=38
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://github.com/rhboot/efivar/releases/download/$(PKG_VERSION)
PKG_HASH:=f018ed6e49c5f1c16d336d9fd7687ce87023276591921db1e49a314ad6515349

PKG_LICENSE:=LGPL-2.1-only
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/efivar
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Tools and libraries to work with EFI variables
  DEPENDS:=@(TARGET_x86_64||TARGET_armsr_armv8)
  URL:=https://github.com/rhboot/efibootmgr
endef

define Package/efivar/description
  Tools and libraries to work with EFI variables
endef

MAKE_VARS += \
	ERRORS= \
	HOSTCC="$(HOSTCC)" \
	HOST_CFLAGS="$(HOST_CFLAGS)" \
	HOST_LDFLAGS="$(HOST_LDFLAGS)" \
	LIBDIR="/usr/lib"

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libefiboot.so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libefisec.so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libefivar.so* $(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/include/efivar
	$(CP) $(PKG_INSTALL_DIR)/usr/include/efivar/*.h $(1)/usr/include/efivar/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/*.pc $(1)/usr/lib/pkgconfig/
endef

define Package/efivar/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/efisecdb $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/efivar $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libefiboot.so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libefisec.so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libefivar.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,efivar))
