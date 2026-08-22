# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=zfs
PKG_VERSION:=2.4.3
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/openzfs/zfs/releases/download/$(PKG_NAME)-$(PKG_VERSION)/
PKG_HASH:=1f08f2d154f5189b5f1382848a32667b3d34066145b474c49cd3d41a5fba59a7

PKG_LICENSE:=CDDL
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:openzfs:openzfs

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/kernel.mk
include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += \
	--disable-static \
	--disable-asan \
	--disable-ubsan \
	--disable-pyzfs \
	--disable-sysvinit \
	--disable-systemd \
	--disable-pam \
	--without-dracutdir \
	--without-libunwind \
	--with-linux="$(LINUX_DIR)" \
	--with-vendor="openwrt"

CONFIGURE_VARS += \
	KERNEL_ARCH=$(LINUX_KARCH) \
	KERNEL_CROSS_COMPILE=$(KERNEL_CROSS)

# gcc < 15 being funny
KERNEL_MAKE_FLAGS+=CFLAGS_MODULE=-Wno-error=infinite-recursion

# missing configure switches to disable cruft
define Build/Configure
	$(SED) 's|libudev|libudev-nothankyouverymuch|g' $(PKG_BUILD_DIR)/configure
	$(SED) 's|libfetch|libfetch-nothankyouverymuch|g' $(PKG_BUILD_DIR)/configure
	$(SED) 's|libcurl|libcurl-nothankyouverymuch|g' $(PKG_BUILD_DIR)/configure
	$(SED) 's|curl-config|curl-config-nothankyouverymuch|g' $(PKG_BUILD_DIR)/configure
	$(SED) 's|@KERNEL_MAKE@|@KERNEL_MAKE@ $(KERNEL_MAKE_FLAGS)|g' $(PKG_BUILD_DIR)/module/Makefile.in
	$(Build/Configure/Default)
endef

define KernelPackage/fs-zfs
  TITLE:=OpenZFS ZFS filesystem support
  URL:=https://github.com/openzfs/zfs
  SECTION:=sys
  SUBMENU:=Filesystems
  DEPENDS:=\
	@(aarch64||loongarch64||mips64||mips64el||riscv64||x86_64) \
	+kmod-crypto-deflate
  FILES:=\
	$(PKG_BUILD_DIR)/module/spl.ko \
	$(PKG_BUILD_DIR)/module/zfs.ko
  AUTOLOAD:=$(call AutoLoad,30,zfs)
endef

define KernelPackage/fs-zfs/description
  OpenZFS kernel modules for ZFS support
endef

$(eval $(call KernelPackage,fs-zfs))

define Package/zfsutils
  TITLE:=Utilities for OpenZFS filesystems
  URL:=https://github.com/openzfs/zfs
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Filesystem
  DEPENDS:= \
	+kmod-fs-zfs \
	+zlib \
	+libuuid \
	+libblkid \
	+libtirpc \
	+libopenssl
endef

define Package/zfsutils/description
  This package provides the zfs and zpool commands to create and administer
  OpenZFS filesystems.
endef

define Package/zfsutils/conffiles
/etc/zfs/zpool.cache
endef

define Package/zfsutils/install
	$(INSTALL_DIR) $(1)/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/sbin/mount.zfs $(1)/sbin/
	$(INSTALL_DIR) $(1)/usr/lib/zfs
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib*.so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/zfs/* $(1)/usr/lib/zfs/
	$(RM) -r $(1)/usr/lib/zfs/zed.d/
	$(INSTALL_DIR) $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	$(RM) $(1)/usr/bin/raidz_test
	$(INSTALL_DIR) $(1)/usr/sbin/
	$(CP) $(PKG_INSTALL_DIR)/usr/sbin/* $(1)/usr/sbin/
	$(RM) $(1)/usr/sbin/zed $(1)/usr/sbin/ztest
	$(INSTALL_DIR) $(1)/etc/zfs
	$(CP) $(PKG_INSTALL_DIR)/etc/zfs/* $(1)/etc/zfs/
	$(RM) -r $(1)/etc/zfs/zed.d
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/zfs.init $(1)/etc/init.d/zfs
endef

$(eval $(call BuildPackage,zfsutils))
