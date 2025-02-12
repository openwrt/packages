include $(TOPDIR)/rules.mk

PKG_NAME:=hv-tools
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/NikulovE/hv-tools/
PKG_SOURCE_VERSION:=089a8d7376404eb873860b6fcb85b409a5d385fe
PKG_MIRROR_HASH:=0e08eea3dbb00180eb738583f6c28f95921ffcbc3ba7f7217637777e62678493

PKG_MAINTAINER:=Evgeniy Nikulov <nikulov@live.ru>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

define Package/hv-tools
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Virtualization
  TITLE:=Hyper-V Guest Tools
  DEPENDS:=+procd +libpthread @(TARGET_x86||TARGET_x86_64)
endef

define Package/hv-tools/description
  This package contains Hyper-V Guest Tools for OpenWrt, including various utilities and daemons.
endef

define Build/Compile
	$(MAKE_VARS) $(MAKE) $(MAKE_FLAGS) all -C $(PKG_BUILD_DIR)/files/tools/hv
endef

define Package/hv-tools/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/tools/hv/hv_kvp_daemon $(1)/usr/sbin/hv_kvp_daemon
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/tools/hv/hv_vss_daemon $(1)/usr/sbin/hv_vss_daemon
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/tools/hv/hv_fcopy_daemon $(1)/usr/sbin/hv_fcopy_daemon
	
	$(INSTALL_DIR) $(1)/usr/libexec/hypervkvpd 
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/usr/libexec/hypervkvpd/hv_get_dhcp_info.sh $(1)/usr/libexec/hypervkvpd/hv_get_dhcp_info
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/usr/libexec/hypervkvpd/hv_get_dns_info.sh $(1)/usr/libexec/hypervkvpd/hv_get_dns_info
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/usr/libexec/hypervkvpd/hv_set_ifconfig.sh $(1)/usr/libexec/hypervkvpd/hv_set_ifconfig
	
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/etc/init.d/hv_fcopy_daemon $(1)/etc/init.d/hv_fcopy_daemon
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/etc/init.d/hv_kvp_daemon $(1)/etc/init.d/hv_kvp_daemon
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/etc/init.d/hv_vss_daemon $(1)/etc/init.d/hv_vss_daemon
endef

$(eval $(call BuildPackage,hv-tools))
