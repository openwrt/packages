#
# Copyright (C) 2008-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=tar
PKG_VERSION:=1.30
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=@GNU/$(PKG_NAME)
PKG_HASH:=f1bf92dbb1e1ab27911a861ea8dde8208ee774866c46c0bb6ead41f4d1f4d2d3
PKG_MAINTAINER:=Álvaro Fernández Rojas <noltari@gmail.com>

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1

PKG_BUILD_DEPENDS:=xz

include $(INCLUDE_DIR)/package.mk

define Package/tar
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+PACKAGE_TAR_POSIX_ACL:libacl +PACKAGE_TAR_XATTR:libattr +PACKAGE_TAR_BZIP2:bzip2
  EXTRA_DEPENDS:=$(if $(CONFIG_PACKAGE_TAR_XZ),xz)
  TITLE:=GNU tar
  URL:=http://www.gnu.org/software/tar/
  MENU:=1
endef

define Package/tar/config
	if PACKAGE_tar
		config PACKAGE_TAR_POSIX_ACL
			bool "tar: Enable POSIX ACL support"
			default y if USE_FS_ACL_ATTR
			default n

		config PACKAGE_TAR_XATTR
			bool "tar: Enable extended attribute (xattr) support"
			default y if USE_FS_ACL_ATTR
			default n

		config PACKAGE_TAR_GZIP
			bool "tar: Enable seamless gzip support"
			default y

		config PACKAGE_TAR_BZIP2
			bool "tar: Enable seamless bzip2 support"
			default y

		config PACKAGE_TAR_XZ
			bool "tar: Enable seamless xz support"
			select PACKAGE_xz-utils
			select PACKAGE_xz
			default y
	endif
endef

define Package/tar/description
	Tar is a program for packaging a set of files as a
	single archive in tar format.
endef

define Package/tar/postinst
#!/bin/sh
if [ -e $${IPKG_INSTROOT}/bin/tar ]; then
  rm -r $${IPKG_INSTROOT}/bin/tar;
fi
ln -sf /usr/bin/tar $${IPKG_INSTROOT}/bin/tar
endef

define Package/tar/postrm
#!/bin/sh
rm $${IPKG_INSTROOT}/bin/tar
ln -s busybox $${IPKG_INSTROOT}/bin/tar
$${IPKG_INSTROOT}/bin/tar 2>&1 | grep 'applet not found' > /dev/null 2>&1 && rm $${IPKG_INSTROOT}/bin/tar
exit 0
endef

CONFIGURE_ARGS += \
	$(if $(CONFIG_PACKAGE_TAR_POSIX_ACL),--with,--without)-posix-acls \
	$(if $(CONFIG_PACKAGE_TAR_XATTR),--with,--without)-xattrs \
	$(if $(CONFIG_PACKAGE_TAR_GZIP),--with-gzip=gzip,--without-gzip) \
	$(if $(CONFIG_PACKAGE_TAR_BZIP2),--with-bzip2=bzip2,--without-bzip2) \
	$(if $(CONFIG_PACKAGE_TAR_XZ),--with-xz=xz,--without-xz) \
	--without-compress \
	--without-lzip \
	--without-lzma \
	--without-lzop \
	--without-selinux

MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDLAGS)"

define Package/tar/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/$(PKG_NAME) $(1)/usr/bin/
endef

$(eval $(call BuildPackage,tar))
