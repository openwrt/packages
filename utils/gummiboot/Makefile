#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gummiboot
PKG_VERSION:=48.1
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://dev.alpinelinux.org/archive/gummiboot/
PKG_HASH:=2b649a6eb22007cd34bb355ba4ca6c1a8058e115c13048985f09a0f11f3d5295

PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=LICENSE
PKG_BUILD_DEPENDS:=gnu-efi
PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/gummiboot
  SECTION:=boot
  CATEGORY:=Boot Loaders
  TITLE:=Simple UEFI boot manager
  DEPENDS:=@TARGET_x86_64 +libblkid
  URL:=https://github.com/rzr/gummiboot
endef

define Package/gummiboot/description
  gummiboot Simple UEFI boot manager

  gummiboot executes EFI images. The default entry is selected by a configured
  pattern (glob) or an on-screen menu.
endef

CONFIGURE_ARGS += \
	--with-efi-libdir=$(STAGING_DIR)/usr/lib \
	--with-efi-ldsdir=$(STAGING_DIR)/usr/lib \
	--with-efi-includedir=$(STAGING_DIR)/usr/include \
	--disable-manpages

define Build/Compile
	+$(MAKE_VARS) EFI_CFLAGS="$(patsubst %,-I%,$(TOOLCHAIN_INC_DIRS)) $(TARGET_CFLAGS)" \
	$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR)/$(MAKE_PATH) \
		$(MAKE_FLAGS) \
		$(1);
endef

define Build/Install
	$(MAKE_VARS) EFI_CFLAGS="$(patsubst %,-I%,$(TOOLCHAIN_INC_DIRS)) $(TARGET_CFLAGS)" \
	$(MAKE) -C $(PKG_BUILD_DIR)/$(MAKE_PATH) \
		$(MAKE_INSTALL_FLAGS) install
endef

define Package/gummiboot/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/usr/lib/gummiboot
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/gummiboot/gummibootx64.efi $(1)/usr/lib/gummiboot/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gummiboot $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,gummiboot))
