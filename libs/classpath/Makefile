#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=classpath
PKG_VERSION:=0.99
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Dana H. Myers <k6jq@comcast.net>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@GNU/classpath
PKG_MD5SUM:=0ae1571249172acd82488724a3b8acb4

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/classpath
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=GNU Classpath
  URL:=http://www.gnu.org/software/classpath/
  DEPENDS:=+alsa-lib +libgmp +libmagic
endef

define Package/classpath/Description
	GNU Classpath, Essential Libraries for Java, is a GNU project
	to create free core class libraries for use with virtual
	machines and compilers for the java programming language.
endef

define Package/classpath-tools
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=GNU Classpath tools
  URL:=http://www.gnu.org/software/classpath/
endef

define Download/antlr
  URL:=http://www.antlr.org/download
  FILE:=antlr-3.4-complete.jar
  MD5SUM:=1b91dea1c7d480b3223f7c8a9aa0e172
endef
$(eval $(call Download,antlr))

CONFIGURE_ARGS += \
	--with-gmp="$(STAGING_DIR)/usr" \
	--without-x \
	--disable-gtk-peer \
	--disable-qt-peer \
	--disable-dssi \
	--disable-plugin \
	--disable-gconf-peer \
	--disable-gjdoc \
	--disable-examples \
	--with-antlr-jar=$(DL_DIR)/antlr-3.4-complete.jar

define Package/classpath/install
	$(INSTALL_DIR) \
		$(1)/usr/lib/classpath \
		$(1)/usr/share/classpath
	$(CP) \
		$(PKG_INSTALL_DIR)/usr/lib/security \
		$(PKG_INSTALL_DIR)/usr/lib/logging.properties \
		$(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/classpath/*.so* $(1)/usr/lib/classpath/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/classpath/glibj.zip $(1)/usr/share/classpath/
endef

define Package/classpath-tools/install
	$(INSTALL_DIR) \
		$(1)/usr/bin \
		$(1)/usr/share/classpath
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/classpath/tools.zip $(1)/usr/share/classpath/
endef

define Build/InstallDev
	$(CP) $(PKG_INSTALL_DIR)/* $(1)/
endef

$(eval $(call BuildPackage,classpath))
$(eval $(call BuildPackage,classpath-tools))
