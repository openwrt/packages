include $(TOPDIR)/rules.mk

PKG_NAME:=prplmesh-stock
PKG_VERSION:=6.0.1
PKG_RELEASE:=1
PKG_SOURCE:=prplMesh-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://gitlab.com/prpl-foundation/prplmesh/prplMesh/-/archive/$(PKG_VERSION)/
PKG_HASH:=68602c7bdf521de1797c0e58e66bb45cf105726dfd5a75d8429038012e19a702
PKG_BUILD_DIR:=$(BUILD_DIR)/prplMesh-$(PKG_VERSION)

HOSTAPD_SOURCE_DATE:=2025.08.26
HOSTAPD_SOURCE_VERSION:=ca266cc24d8705eb1a2a0857ad326e48b1408b20
HOSTAPD_SOURCE:=hostapd-$(HOSTAPD_SOURCE_DATE)~$(call version_abbrev,$(HOSTAPD_SOURCE_VERSION)).tar.zst
HOSTAPD_SOURCE_URL:=https://w1.fi/hostap.git
HOSTAPD_SOURCE_PROTO:=git
HOSTAPD_MIRROR_HASH:=59ac677093f524ff98588abd9f33805a336a6e929d6814222f0d784c854f2343
HOSTAPD_BUILD_ROOT:=$(BUILD_DIR)/$(PKG_NAME)-hostapd-source
HOSTAPD_BUILD_DIR:=$(HOSTAPD_BUILD_ROOT)/hostapd-$(HOSTAPD_SOURCE_DATE)~$(call version_abbrev,$(HOSTAPD_SOURCE_VERSION))
HOSTAPD_OPENWRT_CTRL_PATCH:=$(CURDIR)/files/610-hostapd_cli_ujail_permission.patch
HOSTAPD_WPA_CTRL_HASHER:=$(STAGING_DIR_HOST)/bin/mkhash
HOSTAPD_WPA_CTRL_RAW_SHA256:=482839d354b9c53e19e6a766ff5be054980607dd94e53efee9762dbda40f0f26
HOSTAPD_WPA_CTRL_PATCHED_SHA256:=ad925b710901b3f2f2188afdab5a7f181913e48b159a824c30e0c19d2acd53fa

PKG_LICENSE:=BSD-2-Clause-Patent BSD-3-Clause ISC MIT
PKG_LICENSE_FILES:=LICENSE LICENSES/BSD-3-Clause.txt LICENSES/ISC.txt LICENSES/MIT.txt LICENSES/hostapd-COPYING
PKG_MAINTAINER:=Andrei Ovcharenko <a@krot.name>

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_BUILD_DEPENDS:=python-yaml/host
CMAKE_BINARY_SUBDIR:=build-openwrt-stock

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk
include ../../lang/python/python3-host.mk

EXTRA_CXXFLAGS += -Wno-error=deprecated-declarations

define Download/hostapd
  FILE:=$(HOSTAPD_SOURCE)
  URL:=$(HOSTAPD_SOURCE_URL)
  PROTO:=$(HOSTAPD_SOURCE_PROTO)
  SOURCE_VERSION:=$(HOSTAPD_SOURCE_VERSION)
  SUBDIR:=hostapd-$(HOSTAPD_SOURCE_DATE)~$(call version_abbrev,$(HOSTAPD_SOURCE_VERSION))
  MIRROR_HASH:=$(HOSTAPD_MIRROR_HASH)
endef
$(eval $(call Download,hostapd))

define Package/prplmesh-stock
  SECTION:=net
  CATEGORY:=Network
  TITLE:=prplMesh controller and agent for stock OpenWrt
  URL:=https://gitlab.com/prpl-foundation/prplmesh/prplMesh
  DEPENDS:=+libstdcpp +libpthread +librt +libjson-c +libopenssl +libnl-core +libnl-genl +libnl-route +libuci +libubus +libubox
endef

define Package/prplmesh-stock/description
  prplMesh controller and agent build for stock OpenWrt. It uses the existing
  hostapd control sockets and never replaces the installed wpad.
endef

define Package/prplmesh-stock/conffiles
/etc/config/prplmesh
endef

CMAKE_OPTIONS += \
	-DTARGET_PLATFORM=openwrt \
	-DTARGET_PLATFORM_TYPE=stock \
	-DBWL_TYPE=NL80211 \
	-DENABLE_NBAPI=OFF \
	-DUSE_PRPLMESH_WHM=OFF \
	-DPRPLMESH_STOCK_OPENWRT_UCI=ON \
	-DBUILD_AGENT=ON \
	-DBUILD_CONTROLLER=ON \
	-DBUILD_TESTS=OFF \
	-DPRPLMESH_VERSION=$(PKG_VERSION) \
	-DPRPLMESH_REVISION=openwrt-r$(PKG_RELEASE) \
	-DBUILD_DATE=$(SOURCE_DATE_EPOCH) \
	-DCMAKE_INSTALL_PREFIX=/opt/prplmesh \
	-DPLATFORM_BUILD_DIR=$(BUILD_DIR) \
	-DPLATFORM_STAGING_DIR=$(STAGING_DIR) \
	-DPLATFORM_INCLUDE_DIR=$(STAGING_DIR)/usr/include \
	-DPython3_EXECUTABLE=$(HOST_PYTHON3_BIN) \
	-DHOSTAPD_INCLUDE_DIR=$(HOSTAPD_BUILD_DIR)

define Build/Prepare
	$(call Build/Prepare/Default)
	test "$(HOSTAPD_BUILD_ROOT)" = "$(BUILD_DIR)/$(PKG_NAME)-hostapd-source"
	rm -rf -- "$(HOSTAPD_BUILD_ROOT)"
	mkdir -p "$(HOSTAPD_BUILD_ROOT)"
	$(STAGING_DIR_HOST)/bin/zstdcat $(DL_DIR)/$(HOSTAPD_SOURCE) | \
		$(TAR) -C "$(HOSTAPD_BUILD_ROOT)" -xf -
	test -f "$(HOSTAPD_BUILD_DIR)/src/common/wpa_ctrl.h"
	test -f "$(HOSTAPD_OPENWRT_CTRL_PATCH)"
	test -x "$(HOSTAPD_WPA_CTRL_HASHER)"
	$(HOSTAPD_WPA_CTRL_HASHER) sha256 "$(HOSTAPD_BUILD_DIR)/src/common/wpa_ctrl.c" | \
		grep -qxF "$(HOSTAPD_WPA_CTRL_RAW_SHA256)"
	$(PATCH) -d "$(HOSTAPD_BUILD_DIR)" -p1 --forward < "$(HOSTAPD_OPENWRT_CTRL_PATCH)"
	$(HOSTAPD_WPA_CTRL_HASHER) sha256 "$(HOSTAPD_BUILD_DIR)/src/common/wpa_ctrl.c" | \
		grep -qxF "$(HOSTAPD_WPA_CTRL_PATCHED_SHA256)"
	test -f "$(HOSTAPD_BUILD_DIR)/COPYING"
	$(INSTALL_DATA) "$(HOSTAPD_BUILD_DIR)/COPYING" "$(PKG_BUILD_DIR)/LICENSES/hostapd-COPYING"
	test -f "$(PKG_BUILD_DIR)/LICENSES/hostapd-COPYING"
endef

define Build/Clean
	test "$(HOSTAPD_BUILD_ROOT)" = "$(BUILD_DIR)/$(PKG_NAME)-hostapd-source"
	rm -rf -- "$(HOSTAPD_BUILD_ROOT)"
endef

define Package/prplmesh-stock/install
	$(INSTALL_DIR) $(1)/opt/prplmesh $(1)/usr/lib $(1)/etc/init.d $(1)/etc/config
	$(CP) $(PKG_INSTALL_DIR)/opt/prplmesh/bin $(1)/opt/prplmesh/
	$(CP) $(PKG_INSTALL_DIR)/opt/prplmesh/scripts $(1)/opt/prplmesh/
	$(CP) $(PKG_INSTALL_DIR)/opt/prplmesh/share $(1)/opt/prplmesh/
	$(CP) $(PKG_INSTALL_DIR)/opt/prplmesh/config $(1)/opt/prplmesh/
	$(CP) $(PKG_INSTALL_DIR)/opt/prplmesh/lib/*.so* $(1)/usr/lib/
	$(INSTALL_BIN) ./files/prplmesh.init $(1)/etc/init.d/prplmesh
	$(INSTALL_CONF) ./files/prplmesh.config $(1)/etc/config/prplmesh
endef

$(eval $(call BuildPackage,prplmesh-stock))
