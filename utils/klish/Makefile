#
# Copyright (C) 2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=klish
PKG_VERSION:=1.5.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://klish.googlecode.com/files/
PKG_MD5SUM:=c98a1c65f7538c3f4687c6f8039295df

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/klish/default
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Kommand Line Interface SHell ($(1))
  URL:=http://code.google.com/p/klish/
endef

define Package/klish
$(call Package/klish/default,main tool)
  DEPENDS:=+libstdcpp
endef

define Package/konf
$(call Package/klish/default,konf tool)
  DEPENDS:=klish
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
endef

define Package/konf/description
 The klish is a framework for implementing a CISCO-like CLI on a UNIX
 systems. It is configurable by XML files. The KLISH stands for Kommand
 Line Interface Shell.
 Konf and konfd are klish utilities that are used to store configuration
 informations in a way which is similar to what's found on CISCO devices.
 More information about these tools is to be found on the klish web site.
endef

define Package/klish/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/clish $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
endef

define Package/konf/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/konf $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/konfd $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libkonf.so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/liblub.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,klish))
$(eval $(call BuildPackage,konf))

define Package/klish-xml-files
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=klish
  TITLE:=klish sample XML files
  URL:=http://code.google.com/p/klish/
endef

define Package/klish-xml-files/description
  This is a set of sample XML files for klish. This specific sample set
  is compatible with the original clish.
endef

define Package/klish-xml-files/install
	$(INSTALL_DIR) $(1)/etc/clish
	$(CP) $(PKG_BUILD_DIR)/xml-examples/clish $(1)/etc/clish/
endef

$(eval $(call BuildPackage,klish-xml-files))
