include $(TOPDIR)/rules.mk

PKG_NAME:=memtest86plus
PKG_VERSION:=8.10
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/memtest86plus/memtest86plus/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=5617bc42ae4572158988efd466954d08f25cbb78f1714164280064784c484f4d

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
  DEPENDS:=@(TARGET_x86_64||TARGET_loongarch64) +grub2-efi
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

ifeq ($(CONFIG_TARGET_x86_64),y)
  MEMTEST_ARCH:=x86_64
  MEMTEST_EFI:=bootx64.efi
else ifeq ($(CONFIG_TARGET_loongarch64),y)
  MEMTEST_ARCH:=loongarch64
  MEMTEST_EFI:=BOOTLOONGARCH64.EFI
else
  MEMTEST_ARCH:=i586
endif

define Build/Compile
	$(MAKE) -C "$(PKG_BUILD_DIR)/build/$(MEMTEST_ARCH)" all
endef

define Package/memtest86plus/install
	$(INSTALL_DIR) $(1)/boot/memtest86+
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/build/$(MEMTEST_ARCH)/memtest_shared.bin $(1)/boot/memtest86+/memtest.bin

	$(INSTALL_DIR) $(1)/etc/grub.d
	$(INSTALL_BIN) ./files/memtestplus.bios $(1)/etc/grub.d/60_memtest86

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/grubsetup.sh $(1)/etc/uci-defaults/memtest86plus
endef

define Package/memtest86plus-efi/install
	$(INSTALL_DIR) $(1)/boot/memtest86+
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/build/$(MEMTEST_ARCH)/mt86plus $(1)/boot/memtest86+/memtest.efi

	$(INSTALL_DIR) $(1)/etc/grub.d
	$(INSTALL_BIN) ./files/memtestplus.efi $(1)/etc/grub.d/60_memtest86-efi

	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/grubsetup-efi.sh $(1)/etc/uci-defaults/memtest86plus-efi
endef

define Package/memtest86plus/postrm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	sed -i "/^menuentry 'Memory Tester (memtest86+)' {/,/^}/d" /boot/grub/grub.cfg || true
}
exit 0
endef

define Package/memtest86plus-efi/postrm
#!/bin/sh
[ -n "$${IPKG_INSTROOT}" ] || {
	sed -i "/^menuentry 'Memory Tester (memtest86+) for EFI' {/,/^}/d" /boot/grub/grub.cfg || true
}
exit 0
endef

$(eval $(call BuildPackage,memtest86plus))
$(eval $(call BuildPackage,memtest86plus-efi))
