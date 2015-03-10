#
# Copyright (C) 2008-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=tar
PKG_VERSION:=1.28
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=@GNU/$(PKG_NAME)
PKG_MD5SUM:=8f32b2bc1ed7ddf4cf4e4a39711341b0
PKG_MAINTAINER:=Álvaro Fernández Rojas <noltari@gmail.com>

PKG_LICENSE:=GPL-3.0
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/tar
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+bzip2 +libacl +libattr
  TITLE:=GNU tar
  URL:=http://www.gnu.org/software/tar/
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

MAKE_FLAGS += \
	CFLAGS="$(TARGET_CFLAGS)" \
	LDFLAGS="$(TARGET_LDLAGS)"

define Package/tar/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/$(PKG_NAME) $(1)/usr/bin/
endef

$(eval $(call BuildPackage,tar))
