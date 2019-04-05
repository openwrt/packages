#
# Copyright (C) 2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=libhttp-parser
PKG_VERSION:=2.3.0
PKG_RELEASE=1
PKG_MAINTAINER:=Ramanathan Sivagurunathan <ramzthecoder@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE-MIT

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/joyent/http-parser.git
PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=56f7ad0e2e5a80f79d214015c91e1f17d11d109f


include $(INCLUDE_DIR)/package.mk

define Package/libhttp-parser
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=A library to parse http request and response
  URL:=https://github.com/joyent/http-parser
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
	( cd $(1)/usr/lib ; ln -s libhttp_parser.so.* libhttp_parser.so )
endef

define Package/libhttp-parser/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libhttp_parser.so.* $(1)/usr/lib/
	( cd $(1)/usr/lib ; ln -s libhttp_parser.so.* libhttp_parser.so )
endef

$(eval $(call BuildPackage,libhttp-parser))
