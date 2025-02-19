include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=hv-tools
PKG_VERSION:=1.0.0
PKG_RELEASE:=3

PKG_MAINTAINER:=Evgeniy Nikulov <nikulov@live.ru>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define prepare_source_directory
	$(CP) $(LINUX_DIR)/tools/hv $(PKG_BUILD_DIR)
endef

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
	$(MAKE) prepare
	$(MAKE_VARS) $(MAKE) $(MAKE_FLAGS) all -C $(LINUX_DIR)/tools/hv
endef

define Package/hv-tools/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(LINUX_DIR)/tools/hv/hv_kvp_daemon $(1)/usr/sbin/hv_kvp_daemon
	$(INSTALL_BIN) $(LINUX_DIR)/tools/hv/hv_vss_daemon $(1)/usr/sbin/hv_vss_daemon
	$(INSTALL_BIN) $(LINUX_DIR)/tools/hv/hv_fcopy_daemon $(1)/usr/sbin/hv_fcopy_daemon
	
	$(INSTALL_DIR) $(1)/usr/libexec/hypervkvpd 
	$(INSTALL_BIN) $(LINUX_DIR)/tools/hv/hv_get_dhcp_info.sh $(1)/usr/libexec/hypervkvpd/hv_get_dhcp_info
endef

$(eval $(call BuildPackage,hv-tools))
