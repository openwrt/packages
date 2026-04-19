#
# Copyright (C) 2026 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=klish3
PKG_VERSION:=3.2.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/pkun/klish.git
PKG_SOURCE_DATE:=2026-01-15
PKG_SOURCE_VERSION:=8046c594cc14e4a28f37b885d0af20a7c875e7a1
PKG_MIRROR_HASH:=3c691c3a1215263f8ef092e48dc45cc942f112cbbf7bf77d8c820d90451d33ca

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

PKG_MAINTAINER:=Dharmik Parmar <dharmikparmar2004@yahoo.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENCE

include $(INCLUDE_DIR)/package.mk

define Package/libklish3
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Klish v3 core shared library
  URL:=https://github.com/pkun/klish
  DEPENDS:=+libfaux +libxml2 +libpthread
endef

define Package/libklish3/description
 Core shared library for Klish v3.
endef

define Package/libtinyrl3
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Klish v3 tiny readline shared library
  URL:=https://github.com/pkun/klish
  DEPENDS:=+libfaux +libxml2 +libpthread
endef

define Package/libtinyrl3/description
 Tiny readline-style shared library used by Klish v3.
endef

define Package/klish3-db-libxml2
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Klish v3 XML database backend plugin
  URL:=https://github.com/pkun/klish
  DEPENDS:=+libklish3 +libxml2
endef

define Package/klish3-db-libxml2/description
 XML-backed database plugin for Klish v3.
endef

define Package/klish3-db-ischeme
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Klish v3 in-memory schema database backend plugin
  URL:=https://github.com/pkun/klish
  DEPENDS:=+libklish3
endef

define Package/klish3-db-ischeme/description
 In-memory schema database backend plugin for Klish v3.
endef

define Package/klish3-plugin-klish
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Shells
  TITLE:=Klish v3 built-in command plugin
  URL:=https://github.com/pkun/klish
  DEPENDS:=+libklish3
endef

define Package/klish3-plugin-klish/description
 Built-in command plugin for Klish v3.
endef

define Package/klish3-plugin-script
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Shells
  TITLE:=Klish v3 script plugin
  URL:=https://github.com/pkun/klish
  DEPENDS:=+libklish3
endef

define Package/klish3-plugin-script/description
 Script execution plugin for Klish v3.
endef

define Package/klish3
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Shells
  TITLE:=Kommand Line Interface Shell v3
  URL:=https://github.com/pkun/klish
  DEPENDS:=+libklish3 +libtinyrl3 +klish3-db-libxml2 +klish3-db-ischeme +klish3-plugin-klish +klish3-plugin-script
  CONFLICTS:=klish klish-xml-files
endef

define Package/klish3/description
 Klish v3 is a framework for implementing Cisco-like or Juniper-like
 command line interfaces.
 This package ships the klish and klishd binaries along with default
 runtime configuration.
endef

CONFIGURE_ARGS += \
	--with-libxml2=yes \
	--with-roxml=no \
	--with-expat=no \
	--with-lua=no

define Package/klish3/conffiles
/etc/klish/klish.conf
/etc/klish/klishd.conf
/etc/klish/xml/example.xml
endef

define Package/libklish3/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libklish.so* $(1)/usr/lib/
endef

define Package/libtinyrl3/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtinyrl.so* $(1)/usr/lib/
endef

define Package/klish3-db-libxml2/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libklish-db-libxml2.so* $(1)/usr/lib/
endef

define Package/klish3-db-ischeme/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libklish-db-ischeme.so* $(1)/usr/lib/
endef

define Package/klish3-plugin-klish/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libklish-plugin-klish.so* $(1)/usr/lib/
endef

define Package/klish3-plugin-script/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libklish-plugin-script.so* $(1)/usr/lib/
endef

define Package/klish3/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/klish $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/klishd $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/klish/xml
	$(INSTALL_CONF) ./files/etc/klish/klish.conf $(1)/etc/klish/
	$(INSTALL_CONF) ./files/etc/klish/klishd.conf $(1)/etc/klish/
	$(INSTALL_CONF) ./files/etc/klish/xml/example.xml $(1)/etc/klish/xml/

	$(INSTALL_DIR) $(1)/usr/share/klish
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/klish.xsd $(1)/usr/share/klish/
endef

$(eval $(call BuildPackage,libklish3))
$(eval $(call BuildPackage,libtinyrl3))
$(eval $(call BuildPackage,klish3-db-libxml2))
$(eval $(call BuildPackage,klish3-db-ischeme))
$(eval $(call BuildPackage,klish3-plugin-klish))
$(eval $(call BuildPackage,klish3-plugin-script))
$(eval $(call BuildPackage,klish3))
