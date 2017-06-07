include $(TOPDIR)/rules.mk

PKG_NAME:=http-parser
PKG_VERSION:=2.7.1
PKG_RELEASE:=1


PKG_SOURCE:=v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/nodejs/$(PKG_NAME)/archive/
PKG_MD5SUM:=31c6fefb6208b16d19b3f990e71cb04a

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/http-parser
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=HTTP parser library
endef

define Package/http-parser/description
	This is a parser for HTTP messages written in C. It parses both requests and
	responses. The parser is designed to be used in performance HTTP applications.
	It does not make any syscalls nor allocations, it does not buffer data, it can
	be interrupted at anytime. Depending on your architecture, it only requires
	about 40 bytes of data per message stream (in a web server that is per
	connection).
endef

CONFIGURE_ARGS+= LIBS="-Wl,-rpath-link=$(STAGING_DIR)/usr/lib"

TARGET_CFLAGS += $(FPIC)

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/{lib,include}
	$(CP) $(PKG_INSTALL_DIR)/usr/local/lib/libhttp_parser* $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/local/include/* $(1)/usr/include/
endef

define Package/http-parser/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/local/lib/libhttp_parser* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,http-parser))

