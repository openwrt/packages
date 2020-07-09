#
# Copyright (C) 2019 CZ.NIC z.s.p.o. (http://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
#
include $(TOPDIR)/rules.mk

PKG_NAME:=czmq
PKG_VERSION:=4.2.0
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/zeromq/czmq/releases/download/v$(PKG_VERSION)/
PKG_HASH:=cfab29c2b3cc8a845749758a51e1dd5f5160c1ef57e2a41ea96e4c2dcc8feceb

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec@nic.cz>
PKG_LICENSE:=MPL-2.0
PKG_LICENSE_FILES:=LICENSE

CMAKE_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/czmq
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=CZMQ High-level C binding for ZeroMQ
  URL:=http://czmq.zeromq.org
  ABI_VERSION:=4
  DEPENDS:=+libzmq +libuuid +libpcre +libmicrohttpd +liblz4 +libcurl
endef

define Package/czmq/description
  High-level C binding for ZeroMQ which is high-performance asynchronous messaging
  library, aimed at use in distributed or concurrent applications.
endef

CMAKE_OPTIONS += \
	-DBUILD_TESTING=OFF \
	-DCMAKECONFIG_INSTALL_DIR=lib/cmake/czmq \
	-DCMAKE_SKIP_INSTALL_RPATH=ON \
	-DENABLE_DRAFTS=OFF

define Package/czmq/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/zmakecert $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libczmq.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,czmq))
