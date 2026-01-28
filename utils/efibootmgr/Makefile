include $(TOPDIR)/rules.mk

PKG_NAME:=efibootmgr
PKG_VERSION:=18
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/rhboot/efibootmgr.git
PKG_SOURCE_DATE:=2022-11-12
PKG_SOURCE_VERSION:=1904f9cd5a48207d49e393ac8de824f54ccfb697
PKG_MIRROR_HASH:=24053efe63aa62c711cdc770aaeb7079b95f5bf807f1725d1b2193f2e2683962

PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=OSkari Rauta <oskari.rauta@gmail.com>

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/efibootmgr
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Application to modify the EFI Boot Manager
  DEPENDS:=@(TARGET_x86_64||TARGET_armsr_armv8) +efivar +libpopt
  URL:=https://github.com/rhboot/efibootmgr
endef

define Package/efibootmgr/description
  This is efibootmgr, a Linux user-space application to modify the
  Intel Extensible Firmware Interface (EFI) Boot Manager.
  This application can create and destroy boot entries, change
  the boot order, change the next running boot option, and more.

  Details on the EFI Boot Manager are available from the
  EFI Specification, v1.02 or above, available from:
  https://uefi.org

  Note: efibootmgr requires either the efivarfs or the legacy
  efivars kernel module to be loaded prior to use.
endef

MAKE_VARS += \
	EFIDIR="/boot/EFI" \
	PCDIR="$(STAGING_DIR)/usr/lib/pkgconfig" \
	EXTRAINCDIR="-I$(STAGING_DIR)/usr/include -I$(STAGING_DIR)/usr/include/efivar" \
	EXTRALIBDIR="-L$(STAGING_DIR)/usr/lib"

define Package/efibootmgr/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/{efibootdump,efibootmgr} $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,efibootmgr))
