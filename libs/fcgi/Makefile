#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=fcgi
PKG_VERSION:=2.4.2
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/FastCGI-Archives/fcgi2
PKG_MIRROR_HASH:=e4a6cf23b4c9b00b111aaed817a8beb33191b10581e005f794a9f801bb4abc43

PKG_MAINTAINER:=Petr Štetiar <ynezz@true.cz>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.TERMS

PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk

define Package/fcgi/Default
  SECTION:=libs
  CATEGORY:=Libraries
  URL:=https://fastcgi-archives.github.io/
endef

define Package/fcgi
  $(call Package/fcgi/Default)
  MENU:=1
  DEPENDS:=+libpthread
  TITLE:=Shared library of FastCGI
endef

define Package/fcgixx
  $(call Package/fcgi/Default)
  DEPENDS:=fcgi $(CXX_DEPENDS)
  TITLE:=Shared library of FastCGI++
endef

define Package/fcgi/description
 FastCGI is a language independent, scalable, open extension to
 CGI that provides high performance without the limitations of
 server specific APIs.
endef

TARGET_CXXFLAGS += -fno-rtti -flto
TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/fastcgi.h $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/fcgi{app,_config,misc,o,os,_stdio}.h $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libfcgi{,++}.{a,so*} $(1)/usr/lib/
endef

define Package/fcgi/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/cgi-fcgi $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libfcgi.so.* $(1)/usr/lib/
endef

define Package/fcgixx/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libfcgi++.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,fcgi))
$(eval $(call BuildPackage,fcgixx))
