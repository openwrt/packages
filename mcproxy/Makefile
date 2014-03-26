#
# Copyright (C) 2014 Alvaro Fernandez Rojas <noltari@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mcproxy
PKG_VERSION:=1.1.0

PKG_RELEASE=$(PKG_SOURCE_VERSION)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=git://github.com/mcproxy/mcproxy.git
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=df2d117dd67a7948f86d7effc5b9ea8f372466d8
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz

include $(INCLUDE_DIR)/package.mk

define Package/mcproxy
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  TITLE:=Multicast Proxy for IGMP/MLD
  URL:=http://mcproxy.realmv6.org/
  DEPENDS:=+libpthread +libstdcpp @(!GCC_VERSION_4_4&&!GCC_VERSION_4_6)
endef

define Package/mcproxy/description
  mcproxy is a free & open source implementation of the IGMP/MLD proxy
  function (see RFC4605) for Linux systems. It operates on the kernel
  tables for multicast routing and allows for multiple instantiations,
  as well as dynamically changing downstream interfaces.

  The current design was motivated by research and IETF standardization
  activities in the MULTIMOB group (see RFC6224 and
  draft-ietf-multimob-pmipv6-source) and shall serve as a test and
  experimentation tool for the research community.
endef

define Build/Configure
	$(CP) ./src/Makefile $(PKG_BUILD_DIR)/mcproxy/
endef

TARGET_CXXFLAGS += -pipe -std=c++11 -O2 -Wall -W -fPIE
TARGET_LFLAGS += -Wl,-O1
TARGET_INCPATH += -I.
TARGET_LIBS += -lpthread

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/mcproxy \
		CXX="$(TARGET_CXX)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CXXFLAGS="$(TARGET_CXXFLAGS)" \
		LFLAGS="$(TARGET_LFLAGS)" \
		INCPATH="$(TARGET_INCPATH)" \
		LIBS="$(TARGET_LIBS)"
endef

define Package/mcproxy/install
	$(INSTALL_DIR) $(1)/etc $(1)/etc/init.d $(1)/usr/sbin
	$(INSTALL_CONF) ./files/mcproxy.conf $(1)/etc/mcproxy.conf
	$(INSTALL_BIN) ./files/mcproxy.init $(1)/etc/init.d/mcproxy
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/mcproxy/mcproxy $(1)/usr/sbin
endef

$(eval $(call BuildPackage,mcproxy))
