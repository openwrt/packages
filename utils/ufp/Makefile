include $(TOPDIR)/rules.mk

PKG_NAME:=ufp
PKG_RELEASE:=1

PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Felix Fietkau <nbd@nbd.name>

PKG_SOURCE_URL=https://git.openwrt.org/project/ufp.git
PKG_MIRROR_HASH:=fcd87491f3a1bbfc3545e7c418355e1e7d30bf08b51370507b761b33907a6e84
PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2025-06-21
PKG_SOURCE_VERSION:=0b867c8cf579389bcb7d0eb89aa9668a0ad9b6c5

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
