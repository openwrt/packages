#
# Copyright (C) 2008-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=pthsem
PKG_VERSION:=2.0.8
PKG_RELEASE:=5

PKG_MAINTAINER:=Othmar Truniger <github@truniger.ch>
PKG_LICENSE:=LGPL-2.1+
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE:=$(PKG_NAME)_$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.auto.tuwien.ac.at/~mkoegler/pth/
PKG_MD5SUM:=9144b26dcc27e67498d63dd5456f934c

PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
PKG_FORTIFY_SOURCE:=0
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/pthsem
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=GNU pth extended with semaphore support
  URL:=http://www.auto.tuwien.ac.at/~mkoegler/index.php/pth
endef

define Package/pthsem/description
  GNU pth is a user mode multi threading library.
  pthsem is an extend version, with support for semaphores added. It can be installed parallel to a normal pth.
endef

# The musl libc provides a proper implementation of sigaltstack() so
# prevent configure from wrongly assuming a broken Linux platform
ifeq ($(CONFIG_USE_MUSL),y)
  CONFIGURE_VARS += \
	ac_cv_check_sjlj=ssjlj
endif

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/pthsem-config $(1)/usr/bin/
	$(SED) 's,^\(prefix\|exec_prefix\)=.*,\1=$(STAGING_DIR)/usr,g' $(1)/usr/bin/pthsem-config

	$(INSTALL_DIR) $(1)/usr/include
	$(CP)   $(PKG_INSTALL_DIR)/usr/include/*.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP)   $(PKG_INSTALL_DIR)/usr/lib/libpthsem.{a,la,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/pthsem.pc $(1)/usr/lib/pkgconfig/
	$(INSTALL_DIR) $(2)/bin
	$(LN) ../../usr/bin/pthsem-config $(2)/bin/
endef

define Package/pthsem/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpthsem.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,pthsem))
