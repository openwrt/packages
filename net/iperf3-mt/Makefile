# SPDX-License-Identifier: GPL-2.0-only
#
# Copyright (C) 2023 Jonas Jelonek

include $(TOPDIR)/rules.mk

PKG_NAME:=iperf
PKG_VERSION:=3.15-mt-beta1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/esnet/iperf/tar.gz/$(PKG_NAME)-$(PKG_VERSION)?
PKG_HASH:=4d5ad5bef9321adb832581a495c3cb1b5dec9d9678296f90bfc87166bbb7a43b

PKG_MAINTAINER:=Jonas Jelonek <jelonek.jonas@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_CPE_ID:=cpe:/a:es:iperf3

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

DISABLE_NLS:=

define Package/iperf3-mt/default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=iperf3 with multithreading
  URL:=https://github.com/esnet/iperf
  CONFLICTS:=iperf3 iperf3-ssl
endef

define Package/iperf3-mt
$(call Package/iperf3-mt/default)
  VARIANT:=nossl
  DEPENDS:=+libiperf3-mt
  CONFLICTS+=iperf3-mt-ssl
endef

define Package/iperf3-mt-ssl
$(call Package/iperf3-mt/default)
  TITLE+= and iperf_auth support
  VARIANT:=ssl
  DEPENDS:=+libopenssl +libatomic
endef

define Package/libiperf3-mt
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=libiperf3 with multithreading
  URL:=https://github.com/esnet/iperf
  CONFLICTS:=libiperf3
  DEPENDS+=+libatomic
endef

TARGET_CFLAGS += -D_GNU_SOURCE
TARGET_LDFLAGS += -latomic

ifeq ($(BUILD_VARIANT),ssl)
	CONFIGURE_ARGS += --with-openssl="$(STAGING_DIR)/usr" --disable-shared
else
	CONFIGURE_ARGS += --without-openssl
endif

MAKE_FLAGS += noinst_PROGRAMS=

define Package/iperf3-mt/description
 iPerf3 is a modern alternative for measuring TCP and UDP bandwidth
 performance, allowing the tuning of various parameters and
 characteristics.
 iperf3-mt has experimental multithreading support.
endef

define Package/libiperf3-mt/description
 Libiperf is a library providing an API for iperf3 functionality.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libiperf.* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
endef

define Package/iperf3-mt/install/Default
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/iperf3 $(1)/usr/bin/
endef

Package/iperf3-mt/install = $(Package/iperf3-mt/install/Default)
Package/iperf3-mt-ssl/install = $(Package/iperf3-mt/install/Default)

define Package/libiperf3-mt/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libiperf.so.* $(1)/usr/lib
endef

$(eval $(call BuildPackage,iperf3-mt))
$(eval $(call BuildPackage,iperf3-mt-ssl))
$(eval $(call BuildPackage,libiperf3-mt))
