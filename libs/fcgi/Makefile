#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=fcgi
PKG_VERSION:=2.4.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)2-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/FastCGI-Archives/fcgi2/tar.gz/$(PKG_VERSION)?
PKG_HASH:=1fe83501edfc3a7ec96bb1e69db3fd5ea1730135bd73ab152186fd0b437013bc
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)2-$(PKG_VERSION)

PKG_MAINTAINER:=Jacob Siverskog <jacob@teenageengineering.com>
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
