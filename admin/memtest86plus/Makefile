include $(TOPDIR)/rules.mk

PKG_NAME:=memtest86plus
PKG_VERSION:=8.00
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/memtest86plus/memtest86plus/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=ec7edde55f60d12d9e7bc1cc560837cdbaa14cf00020cebb4a1d7fe4afeddb4a

PKG_MAINTAINER:=John Audia <therealgraysky@proton.me>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/memtest86plus/Default
  SECTION:=admin
  CATEGORY:=Administration
  URL:=https://www.memtest.org
endef

define Package/memtest86plus
  $(call Package/memtest86plus/Default)
  TITLE:=Advanced memory diagnostic tool (legacy BIOS version)
  DEPENDS:=@(TARGET_x86||TARGET_x86_64) +grub2
endef

define Package/memtest86plus/description
  Memtest86+ is a free, open-source, stand-alone memory tester for x86
  architecture computers. It provides a much more thorough memory check
  than that provided by BIOS memory tests. It is also able to access
  almost all the computer's memory, not being restricted by the memory
  used by the operating system. It should work on most x86 CPUs
  (Pentium class or later 32-bit).

  This package adds approx 153 kB to the kernel partition.
endef

define Package/memtest86plus-efi
  $(call Package/memtest86plus/Default)
  TITLE:=Advanced memory diagnostic tool (EFI version)
  DEPENDS:=@(TARGET_x86||TARGET_x86_64||TARGET_loongarch64) +grub2-efi
endef

define Package/memtest86plus-efi/description
  Memtest86+ is a free, open-source, stand-alone memory tester for x86-64
  and LoongArch64 architecture computers. It provides a much more thorough
  memory check than that provided by BIOS memory tests. It is also able to
  access almost all the computer's memory, not being restricted by the memory
  used by the operating system and not depending on any underlying software
  like UEFI libraries. It should work on most x86-64 CPUs and most LoongArch64
  CPUs (Loongson 3 and Loongson 2 family).

  This package adds approx 154 kB to the kernel partition.
endef

define Build/Compile
	$(MAKE) -C "$(PKG_BUILD_DIR)/build/x86_64" all iso
endef

define Package/memtest86plus/install
	$(INSTALL_DIR) $(1)/boot/memtest86+
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/build/x86_64/memtest_shared.bin $(1)/boot/memtest86+/memtest.bin
	
	$(INSTALL_DIR) $(1)/etc/grub.d
	$(INSTALL_BIN) ./files/memtestplus.bios $(1)/etc/grub.d/60_memtest86

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/grubsetup.sh $(1)/etc/uci-defaults/memtest86plus
endef

define Package/memtest86plus-efi/install
	$(INSTALL_DIR) $(1)/boot/memtest86+
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/build/x86_64/iso/EFI/BOOT/bootx64.efi $(1)/boot/memtest86+/memtest.efi
	
	$(INSTALL_DIR) $(1)/etc/grub.d
	$(INSTALL_BIN) ./files/memtestplus.efi $(1)/etc/grub.d/60_memtest86-efi

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/grubsetup-efi.sh $(1)/etc/uci-defaults/memtest86plus-efi
endef

define Package/memtest86plus/postrm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	sed -i '/Memory Tester (memtest86+)/,/}/d' /boot/grub/grub.cfg || true
}
exit 0
endef

define Package/memtest86plus-efi/postrm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	sed -i '/Memory Tester (memtest86+) for EFI/,/}/d' /boot/grub/grub.cfg || true
}
exit 0
endef

$(eval $(call BuildPackage,memtest86plus))
$(eval $(call BuildPackage,memtest86plus-efi))
