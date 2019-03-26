
#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=klish
PKG_VERSION:=2.1.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=http://libcode.org/attachments/download/70/
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENCE
PKG_MAINTAINER:=Takashi Umeno <umeno.takashi@gmail.com>
PKG_HASH:=a89dd1027dce713407b6d68e836c8fdead56406dcfc650da84da8e0b92c9b2e5

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/klish/default
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Shells
  TITLE:=Kommand Line Interface SHell ($(1))
  URL:=http://libcode.org/projects/klish/
endef

define Package/klish
$(call Package/klish/default,main tool)
  DEPENDS:=+libstdcpp +libxml2
endef

define Package/klish/description
 The klish is a framework for implementing a CISCO-like CLI on a UNIX
 systems. It is configurable by XML files. The KLISH stands for Kommand
 Line Interface Shell.
 The klish is a fork of clish 0.7.3 developed by Graeme McKerrell.
 It defines new features but it's compatible (as much as possible) with
 clish's XML configuration files.
 klish is able to run using clish XML configuration files although
 current clish users may expect some changes in behavior.
 Konf and konfd are klish utilities that are used to store configuration
 informations in a way which is similar to what's found on CISCO devices.
 More information about these tools is to be found on the klish web site.
endef

TARGET_LDFLAGS += -lxml2 -lz
TARGET_CFLAGS += -D_XOPEN_SOURCE=500

CONFIGURE_ARGS += --with-libxml2

define Package/klish/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/clish $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/konf $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/konfd $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/sigexec $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,klish))

define Package/klish-xml-files
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=klish
  TITLE:=klish sample XML files
  URL:=http://code.google.com/p/klish/
endef

define Package/klish-xml-files/description
  This is a set of sample XML files for klish. 
endef

define Package/klish-xml-files/install
	$(INSTALL_DIR) $(1)/etc/clish
	$(CP) $(PKG_BUILD_DIR)/xml-examples/clish $(1)/etc/clish/
	$(CP) $(PKG_BUILD_DIR)/xml-examples/klish $(1)/etc/clish/
	$(CP) $(PKG_BUILD_DIR)/xml-examples/lua $(1)/etc/clish/
	$(CP) $(PKG_BUILD_DIR)/xml-examples/test $(1)/etc/clish/
endef

$(eval $(call BuildPackage,klish-xml-files))
