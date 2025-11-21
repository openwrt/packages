include $(TOPDIR)/rules.mk

PKG_NAME:=ufp
PKG_RELEASE:=1

PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Felix Fietkau <nbd@nbd.name>

PKG_SOURCE_URL=https://git.openwrt.org/project/ufp.git
PKG_MIRROR_HASH:=eb813ee728106a383291506559f9bb0ba3293775867a81c0b11e214b638db16a
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2025-09-23
PKG_SOURCE_VERSION:=7d9f3beeac9fe7f4bbc339ea1f41cc485e5d6b97

HOST_BUILD_DEPENDS:=ucode/host libubox/host
PKG_BUILD_DEPENDS:=ufp/host
UCODE:=LD_LIBRARY_PATH=$(LD_LIBRARY_PATH):$(STAGING_DIR_HOSTPKG)/lib/:$(STAGING_DIR_HOST)/lib/ $(STAGING_DIR_HOSTPKG)/bin/ucode

CMAKE_SOURCE_SUBDIR:=src

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/ufp
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Device fingerprinting daemon
  DEPENDS:=+ucode +ucode-mod-fs +ucode-mod-struct +libubox +udhcpsnoop +unetmsg
endef

define Package/ufp-neigh
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Device fingerprinting daemon (OUI plugin)
  DEPENDS:=+ufp
endef

define Package/ufp/conffiles
/etc/config/ufp
endef

CMAKE_HOST_OPTIONS += \
	-DCMAKE_SKIP_RPATH=FALSE \
	-DCMAKE_INSTALL_RPATH="${STAGING_DIR_HOST}/lib"

define Package/ufp/install
	$(INSTALL_DIR) $(1)/usr/lib/ucode $(1)/usr/share/ufp $(1)/usr/sbin/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/ucode/uht.so $(1)/usr/lib/ucode/
	$(UCODE) $(PKG_BUILD_DIR)/scripts/convert-devices.uc $(1)/usr/share/ufp/devices.bin $(PKG_BUILD_DIR)/data/*.json
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ufpd $(1)/usr/sbin
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/plugins/* $(1)/usr/share/ufp
	$(CP) ./files/* $(1)/
endef

define Package/ufp-neigh/install
	$(INSTALL_DIR) $(1)/usr/share/ufp/db/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/modules/plugin_neigh.uc $(1)/usr/share/ufp
	$(UCODE) $(PKG_BUILD_DIR)/scripts/convert-devices.uc $(1)/usr/share/ufp/db/oui.bin $(PKG_BUILD_DIR)/modules/oui.json
endef

$(eval $(call BuildPackage,ufp))
$(eval $(call BuildPackage,ufp-neigh))
$(eval $(call HostBuild))
