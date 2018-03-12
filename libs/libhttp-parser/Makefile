#
# Copyright (C) 2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libhttp-parser
PKG_VERSION:=2.8.0
PKG_RELEASE=1
PKG_MAINTAINER:=Ramanathan Sivagurunathan <ramzthecoder@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE-MIT

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_MIRROR_HASH:=83acea397da4cdb9192c27abbd53a9eb8e5a9e1bcea2873b499f7ccc0d68f518
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=git://github.com/nodejs/http-parser.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)


include $(INCLUDE_DIR)/package.mk

define Package/libhttp-parser
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=A library to parse http request and response
  URL:=https://github.com/nodejs/http-parser
endef

define Package/libhttp-parser/description
  A parser for HTTP messages written in C. It parses both requests and responses. 
  The parser is designed to be used in performance HTTP applications. 
  It does not make any syscalls nor allocations, it does not buffer data, 
  it can be interrupted at anytime. Depending on your architecture, 
  it only requires about 40 bytes of data per message stream 
  (in a web server that is per connection).
endef

define Build/Compile
	$(call Build/Compile/Default, library) 
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/http_parser.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/libhttp_parser.so.* $(1)/usr/lib/
	(	cd $(1)/usr/lib ; \
		ln -s libhttp_parser.so.$(PKG_VERSION) libhttp_parser.so ; \
		ln -s libhttp_parser.so.$(PKG_VERSION) libhttp_parser.so.2.8 )
endef

define Package/libhttp-parser/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libhttp_parser.so.* $(1)/usr/lib/
	(	cd $(1)/usr/lib ; \
		ln -s libhttp_parser.so.$(PKG_VERSION) libhttp_parser.so ; \
		ln -s libhttp_parser.so.$(PKG_VERSION) libhttp_parser.so.2.8 )
endef

$(eval $(call BuildPackage,libhttp-parser))
