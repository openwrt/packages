#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=btrfs-progs
PKG_VERSION:=4.20.1
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-v$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@KERNEL/linux/kernel/people/kdave/btrfs-progs
PKG_HASH:=562f5d1ff1d17867c4c2be2768c653b62f1f257c42f9bb3e1a36380c02ec4fcd
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-v$(PKG_VERSION)

PKG_MAINTAINER:=Rosen Penev <rosenp@gmail.com>
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_BUILD_DEPENDS:=acl

include $(INCLUDE_DIR)/package.mk

define Package/btrfs-progs
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Filesystem
  DEPENDS:=+libattr +libuuid +zlib +libblkid +liblzo +libpthread
  TITLE:=Btrfs filesystems utilities
  URL:=https://btrfs.wiki.kernel.org/
endef

define Package/btrfs-progs/description
 Btrfs is a new copy on write filesystem for Linux aimed at implementing
 advanced features while focusing on fault tolerance, repair and easy
 administration. Initially developed by Oracle, Btrfs is licensed under the
 GPL and open for contribution from anyone.
endef

progs = btrfs btrfs-find-root btrfs-image btrfs-map-logical \
	btrfs-select-super btrfstune mkfs.btrfs

TARGET_CFLAGS += -ffunction-sections -fdata-sections
TARGET_LDFLAGS += -Wl,--gc-sections -Wl,--as-needed

EXTRA_CFLAGS=$(TARGET_CPPFLAGS)

CONFIGURE_ARGS += \
	--disable-backtrace \
	--disable-convert \
	--disable-documentation \
	--disable-python \
	--disable-zstd

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libbtrfs* $(1)/usr/lib/
endef

define Package/btrfs-progs/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libbtrfs.so* $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libbtrfsutil.so* $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(addprefix $(PKG_INSTALL_DIR)/usr/bin/, $(progs)) $(1)/usr/bin/
	$(LN) btrfs $(1)/usr/bin/btrfsck
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/btrfs-scan.init $(1)/etc/init.d/btrfs-scan
endef

$(eval $(call BuildPackage,btrfs-progs))
