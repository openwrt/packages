#
# Copyright (C) 2019-2021 CZ.NIC z.s.p.o. (http://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
#
include $(TOPDIR)/rules.mk

PKG_NAME:=czmq
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=f22f6572fdf63d344e022b956a137ce084fa5d8b
PKG_SOURCE_URL:=https://github.com/zeromq/czmq.git
PKG_MIRROR_HASH:=bd1dbfd4431b53671557a10cc13765dfe388a38fd04c2d53638d34c76be2c9fb

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec1@gmail.com>
PKG_LICENSE:=MPL-2.0
PKG_LICENSE_FILES:=LICENSE

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/czmq
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=CZMQ High-level C binding for ZeroMQ
  URL:=http://czmq.zeromq.org
  ABI_VERSION:=4
  DEPENDS:=+libzmq +libuuid +libmicrohttpd +liblz4 +libcurl +libpthread
endef

define Package/czmq/description
  High-level C binding for ZeroMQ which is high-performance asynchronous messaging
  library, aimed at use in distributed or concurrent applications.
endef

CMAKE_OPTIONS += \
	-DBUILD_TESTING=OFF \
	-DCMAKECONFIG_INSTALL_DIR=lib/cmake/czmq \
	-DENABLE_DRAFTS=OFF

TARGET_CFLAGS += -D_GNU_SOURCE

define Package/czmq/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/zmakecert $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libczmq.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,czmq))
