include $(TOPDIR)/rules.mk

PKG_NAME:=prplmesh
PKG_VERSION:=6.0.1
PKG_RELEASE:=1

PKG_SOURCE:=prplMesh-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://gitlab.com/prpl-foundation/prplmesh/prplMesh/-/archive/$(PKG_VERSION)/
PKG_HASH:=68602c7bdf521de1797c0e58e66bb45cf105726dfd5a75d8429038012e19a702
PKG_BUILD_DIR:=$(BUILD_DIR)/prplMesh-$(PKG_VERSION)

PKG_LICENSE:=BSD-2-Clause-Patent BSD-3-Clause ISC MIT
PKG_LICENSE_FILES:=LICENSE LICENSES/BSD-3-Clause.txt LICENSES/ISC.txt LICENSES/MIT.txt
PKG_MAINTAINER:=Andrei Ovcharenko <a@krot.name>

# The tlvf code generator (framework/tlvf/tlvf.py) runs at build time and
# needs a host Python with PyYAML
PKG_BUILD_DEPENDS:=python3/host python-yaml/host
CMAKE_BINARY_SUBDIR:=build-openwrt-stock

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk
include ../../lang/python/python3-host.mk

define Package/prplmesh
  SECTION:=net
  CATEGORY:=Network
  TITLE:=prplMesh controller and agent for stock OpenWrt
  URL:=https://gitlab.com/prpl-foundation/prplmesh/prplMesh
  DEPENDS:=+libstdcpp +libpthread +librt +libjson-c +libopenssl +libnl-core +libnl-genl +libnl-route +libuci +libubus +libubox +getopt
endef

define Package/prplmesh/description
  prplMesh EasyMesh controller and agent built for stock OpenWrt. It talks
  to the hostapd instances of the installed wpad over their UNIX control
  sockets through a small bundled control-interface client; it does not
  bundle, build or replace hostapd.
endef

define Package/prplmesh/conffiles
/etc/config/prplmesh
endef

CMAKE_OPTIONS += \
	-DTARGET_PLATFORM=openwrt \
	-DTARGET_PLATFORM_TYPE=stock \
	-DBWL_TYPE=NL80211 \
	-DBWL_BUNDLED_WPA_CTRL=ON \
	-DENABLE_NBAPI=OFF \
	-DUSE_PRPLMESH_WHM=OFF \
	-DPRPLMESH_STOCK_OPENWRT_UCI=ON \
	-DBUILD_AGENT=ON \
	-DBUILD_CONTROLLER=ON \
	-DBUILD_TESTS=OFF \
	-DPRPLMESH_VERSION=$(PKG_VERSION) \
	-DPRPLMESH_REVISION=openwrt-r$(PKG_RELEASE) \
	-DBUILD_DATE=$(SOURCE_DATE_EPOCH) \
	-DCMAKE_INSTALL_PREFIX=/usr/libexec/prplmesh \
	-DPLATFORM_STAGING_DIR=$(STAGING_DIR) \
	-DPLATFORM_INCLUDE_DIR=$(STAGING_DIR)/usr/include \
	-DPython3_EXECUTABLE=$(HOST_PYTHON3_BIN)

define Package/prplmesh/install
	$(INSTALL_DIR) $(1)/usr/libexec/prplmesh/bin $(1)/usr/libexec/prplmesh/scripts $(1)/usr/share/prplmesh/config $(1)/usr/lib $(1)/etc/init.d $(1)/etc/config
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/libexec/prplmesh/bin/* $(1)/usr/libexec/prplmesh/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/libexec/prplmesh/scripts/prplmesh_utils.sh $(1)/usr/libexec/prplmesh/scripts/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/libexec/prplmesh/share/* $(1)/usr/share/prplmesh/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/libexec/prplmesh/config/* $(1)/usr/share/prplmesh/config/
	$(LN) ../../share/prplmesh $(1)/usr/libexec/prplmesh/share
	$(LN) ../../share/prplmesh/config $(1)/usr/libexec/prplmesh/config
	$(CP) $(PKG_INSTALL_DIR)/usr/libexec/prplmesh/lib/*.so* $(1)/usr/lib/
	$(INSTALL_BIN) ./files/prplmesh.init $(1)/etc/init.d/prplmesh
	$(INSTALL_CONF) ./files/prplmesh.config $(1)/etc/config/prplmesh
endef

$(eval $(call BuildPackage,prplmesh))
