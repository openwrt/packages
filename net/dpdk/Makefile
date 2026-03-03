#
# Copyright (C) 2026 NEXCOM International Co., Ltd.
# Copyright (C) 2026 Wei-Ting Yang <williamatcg@gmail.com>
#
# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=dpdk
PKG_VERSION:=25.11
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://fast.dpdk.org/rel
PKG_HASH:=52e90d2a531ef3ded0283bd91abc94980698f1f6471fa09658a0217cf6609526

PKG_MAINTAINER:=Wei-Ting Yang <williamatcg@gmail.com>
PKG_LICENSE:=BSD-3-Clause MIT
PKG_LICENSE_FILES:= \
	license/README \
	license/bsd-3-clause.txt \
	license/exceptions.txt \
	license/mit.txt
PKG_CPE_ID:=cpe:/a:dpdk:data_plane_development_kit

PKG_BUILD_DEPENDS:= \
	python-pyelftools/host
PKG_CONFIG_DEPENDS:= \
	CONFIG_KERNEL_HUGETLBFS \
	CONFIG_KERNEL_PROC_PAGE_MONITOR

PKG_BUILD_PARALLEL:=1
MESON_USE_STAGING_PYTHON:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

define Package/dpdk
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Data Plane Development Kit
  URL:=https://core.dpdk.org/
  DEPENDS:= \
	+@KERNEL_HUGETLBFS \
	+@KERNEL_PROC_PAGE_MONITOR \
	+jansson \
	+libatomic \
	+libbsd \
	+libelf \
	+libopenssl \
	+libpcap \
	+zlib
endef

define Package/dpdk/description
DPDK is a set of libraries and drivers for fast packet processing.
endef

MESON_ARGS += \
	-Ddefault_library=shared \
	-Dstrip=true

define Package/dpdk/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/dpdk $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib
endef

$(eval $(call BuildPackage,dpdk))
