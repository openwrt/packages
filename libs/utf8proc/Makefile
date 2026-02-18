include $(TOPDIR)/rules.mk

PKG_NAME:=utf8proc
PKG_VERSION:=2.11.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/JuliaStrings/utf8proc/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=a9b8d8fd57fb3aeca2aede62fd58958036d3bd29871afc1b871e3916c48420a7

PKG_MAINTAINER:=Valeriy Kosikhin <vkosikhin@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.md

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libutf8proc
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Clean C library for processing UTF-8 Unicode data
  URL:=https://github.com/JuliaStrings/utf8proc/
endef

define Package/libutf8proc/description
  utf8proc is a small, clean C library that provides Unicode normalization,
  case-folding, and other operations for data in the UTF-8 encoding.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/local/include/utf8proc.h $(1)/usr/include
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/local/lib/pkgconfig/libutf8proc.pc $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/local/lib/libutf8proc.a $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/local/lib/libutf8proc.so* $(1)/usr/lib
endef

define Package/libutf8proc/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/local/lib/libutf8proc.so* $(1)/usr/lib
endef

$(eval $(call BuildPackage,libutf8proc))
