#
# Copyright (C) 2008-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=htp
PKG_VERSION:=0.5.16
PKG_RELEASE:=1

PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Luka Perkov <luka@openwrt.org>

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/OISF/htp/releases/download/$(PKG_VERSION)/
PKG_MD5SUM:=24510e21f258674c4f08f677ae704f6f

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/htp
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libiconv
  TITLE:=LibHTP is a security-aware parser for the HTTP protocol
  URL:=https://github.com/OISF/htp
endef

define Package/htp/description
  LibHTP is a security-aware parser for the HTTP protocol 
endef

# CONFIGURE_VARS += \
# 	INCLUDES="" \
# 	CXXFLAGS="$$$$CXXFLAGS -fno-rtti" \
# 	LIBS="-lpthread" 

# CONFIGURE_ARGS += \
# 		--with-sysconfsubdir=e2guardian \
# 		--with-proxyuser=root \
# 		--with-proxygroup=root \
# 		--enable-pcre=yes 

define Build/Configure
	$(call Build/Configure/Default)
endef

define Build/InstallDev
	# $(INSTALL_DIR) $(1)/usr/include
	# $(INSTALL_DATA) $(PKG_BUILD_DIR)/htp.h $(1)/usr/include/
	# $(INSTALL_DIR) $(1)/usr/lib
	# $(INSTALL_DATA) $(PKG_BUILD_DIR)/htp.so.* $(1)/usr/lib/
	# ( cd $(1)/usr/lib ; ln -s htp.so.* htp.so )
endef

define Package/htp/install
	# $(INSTALL_DIR) $(1)/usr/lib
	# $(CP) $(PKG_BUILD_DIR)/htp.so.* $(1)/usr/lib/
	# $(CP) $(PKG_INSTALL_DIR)/usr/lib/htp.so.* $(1)/usr/lib/
	# # ( cd $(1)/usr/lib ; ln -s htp.so.* htp.so )
endef

$(eval $(call BuildPackage,htp))
