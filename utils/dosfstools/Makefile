#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=dosfstools
PKG_VERSION:=3.0.28
PKG_RELEASE:=1

PKG_LICENSE:=GPL-3.0+
PKG_LICENSE_FILES:=COPYING

PKG_MAINTAINER:=David Bonnes <david.bonnes@gmail.com>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/dosfstools/dosfstools/releases/download/v$(PKG_VERSION)/ \
		http://fossies.org/linux/misc
PKG_MD5SUM:=64e3b3a59b51d2a97d7ac38b23a124bb

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/dosfstools/Default
  SECTION:=utils
  CATEGORY:=Utilities
  URL:=https://github.com/dosfstools
  SUBMENU:=Filesystem
  DEPENDS:=$(ICONV_DEPENDS)
endef

define Package/dosfsck
  $(call Package/dosfstools/Default)
  TITLE:=fsck (fsck.fat) utility from dosfstools
endef

define Package/dosfslabel
  $(call Package/dosfstools/Default)
  TITLE:=fslabel (fatlabel) utility from dosfstools
endef

define Package/mkdosfs
  $(call Package/dosfstools/Default)
  TITLE:=mkfs (mkfs.fat) utility from dosfstools
endef

define Package/dosfsck/description
	Utilities to create and check MS-DOS FAT filesystems.
	(fsck.vfat and fsck.fat for checking integrity of FAT volumes)
endef

define Package/dosfslabel/description
	Utilities to create and check MS-DOS FAT filesystems.
	(fatlabel for reading and writing labels of FAT volumes)
endef

define Package/mkdosfs/description
	Utilities to create and check MS-DOS FAT filesystems.
	(mkfs.vfat and mkfs.fat for creating FAT volumes)
endef

LDFLAGS+=$(ICONV_LDFLAGS)
LDLIBS+=-liconv

define Build/Configure
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		OPTFLAGS="$(TARGET_CFLAGS) -D_FILE_OFFSET_BITS=64 -D_GNU_SOURCE" \
		PREFIX="/usr" \
		SBINDIR="/usr/sbin" \
		LDFLAGS="$(LDFLAGS)" \
		LDLIBS="$(LDLIBS)" \
		all
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		OPTFLAGS="$(TARGET_CFLAGS) -D_FILE_OFFSET_BITS=64" \
		PREFIX="$(PKG_INSTALL_DIR)/usr" \
		SBINDIR="$(PKG_INSTALL_DIR)/usr/sbin" \
		install-bin
endef

define Package/dosfsck/install
	$(INSTALL_DIR) $(1)/lib/functions/fsck
	$(INSTALL_DATA) ./files/dosfsck.sh $(1)/lib/functions/fsck/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/fsck.fat $(1)/usr/sbin/
	(cd $(1)/usr/sbin; ln -sf fsck.fat fsck.msdos; ln -sf fsck.fat fsck.vfat; ln -sf fsck.fat dosfsck)
endef

define Package/dosfslabel/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/fatlabel $(1)/usr/sbin/
endef

define Package/mkdosfs/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/mkfs.fat $(1)/usr/sbin/
	(cd $(1)/usr/sbin; ln -sf mkfs.fat mkfs.msdos; ln -sf mkfs.fat mkfs.vfat)
endef

$(eval $(call BuildPackage,dosfsck))
$(eval $(call BuildPackage,dosfslabel))
$(eval $(call BuildPackage,mkdosfs))
