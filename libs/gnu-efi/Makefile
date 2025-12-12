#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gnu-efi
PKG_VERSION:=3.0.17
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/vathpela/gnu-efi.git
PKG_SOURCE_DATE:=2023-06-11
PKG_SOURCE_VERSION:=64027ee9864d8a8685ae187eb91ddc519d18cedb
PKG_MIRROR_HASH:=db730ab78f501b2f324edc9a91307eab1f1c5027f9c8fe63bd72364eddaf4553
PKG_BUILD_PARALLEL:=1

PKG_MAINTAINER:=Oskari Rauta <oskari.rauta@gmail.com>
PKG_LICENSE_FILES:=README.efilib

include $(INCLUDE_DIR)/package.mk

define Package/gnu-efi
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=GNU's EFI library
  URL:=https://github.com/vathpela/gnu-efi
  HIDDEN:=1
  DEPENDS:=@TARGET_x86_64
endef

define Package/gnu-efi-programs
  SECTION:=boot
  CATEGORY:=Boot Loaders
  TITLE:=Various EFI programs
  URL:=https://github.com/vathpela/gnu-efi
  DEPENDS:=@TARGET_x86_64 +gnu-efi
endef

define Package/gnu-efi/description
  GNU's EFI library
endef

define Package/gnu-efi-programs/description
  Various EFI programs from GNU's EFI library
endef

TARGET_CFLAGS += -Wno-error=incompatible-pointer-types

define Build/Install
	$(MAKE_VARS) \
	$(MAKE) -C $(PKG_BUILD_DIR)/$(MAKE_PATH) \
		$(MAKE_INSTALL_FLAGS) \
		INSTALLROOT=$(PKG_INSTALL_DIR) \
		install
endef

define Package/gnu-efi/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/local/lib/{crt0-efi-*.o,elf_*.lds,libefi.a,libgnuefi.a} $(1)/usr/lib/
endef

define gnu-efi-programs/install
	$(INSTALL_DIR) $(1)/usr/share/gnuefi/apps
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/local/lib/gnuefi/apps/*.efi $(1)/usr/share/gnuefi/apps/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib $(1)/usr/include/efi
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/local/lib/{crt0-efi-*.o,elf_*.lds,libefi.a,libgnuefi.a} $(1)/usr/lib/
	cp -aR $(PKG_INSTALL_DIR)/usr/local/include/efi/** $(1)/usr/include/efi/
endef

$(eval $(call BuildPackage,gnu-efi))
$(eval $(call BuildPackage,gnu-efi-programs))
