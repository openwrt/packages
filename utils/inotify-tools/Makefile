include $(TOPDIR)/rules.mk

PKG_NAME:=inotify-tools
PKG_VERSION:=3.14
PKG_HASH:=222bcca8893d7bf8a1ce207fb39ceead5233b5015623d099392e95197676c92f
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/downloads/rvoicilas/inotify-tools/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz

PKG_MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/inotify-tools/Default
  URL:=https://github.com/rvoicilas/inotify-tools/wiki
endef

define Package/libinotifytools
  $(call Package/inotify-tools/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE=libinotifytools
endef

define Package/inotifywait
  $(call Package/inotify-tools/Default)
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libinotifytools
  TITLE=inotifywait tool
endef

define Package/inotifywatch
  $(call Package/inotify-tools/Default)
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libinotifytools
  TITLE=inotifywatch tool
endef

define Package/inotify-tools/description
inotify-tools is a C library and a set of command-line programs for
Linux providing a simple interface to inotify. These programs can be
used to monitor and act upon filesystem events. A more detailed
description of the programs is further down the page. The programs are
written in C and have no dependencies other than a Linux kernel
supporting inotify.
endef

define Package/inotifywait/description
  $(call Package/inotify-tools/description)

  This package provides the inotifywait tool.
endef

define Package/inotifywatch/description
  $(call Package/inotify-tools/description)

  This package provides the inotifywatch tool.
endef

define Package/libinotifytools/description
  $(call Package/inotify-tools/description)

  This package provides the libinotifytools shared library.
endef

define Package/inotifywait/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/inotifywait $(1)/usr/bin/
endef

define Package/inotifywatch/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/inotifywatch $(1)/usr/bin/
endef

define Package/libinotifytools/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
endef


define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/inotifytools
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/inotifytools/* $(1)/usr/include/inotifytools/
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.{so*,a,la} $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libinotifytools))
$(eval $(call BuildPackage,inotifywait))
$(eval $(call BuildPackage,inotifywatch))
