include $(TOPDIR)/rules.mk

PKG_NAME:=hv-tools
PKG_VERSION:=1.0.0
PKG_RELEASE:=3

PKG_MAINTAINER:=Evgeniy Nikulov <nikulov@live.ru>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

define Package/hv-tools
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Virtualization
  TITLE:=Hyper-V guest tools
  URL:=https://www.kernel.org
  DEPENDS:=@(TARGET_x86||TARGET_x86_64) +kmod-hv-balloon +kmod-hv-kvp +kmod-hv-utils +kmod-hv-vmbus +libpthread
endef

define Package/hv-tools/description
  Hyper-V Integration Services userspace daemons for OpenWrt.
  Includes KVP (Key-Value Pair), VSS (Volume Shadow Copy Service),
  and FCOPY (File Copy) daemons for better integration with Hyper-V host.
endef

define Build/Prepare
	$(MAKE) -C $(LINUX_DIR) M=$(LINUX_DIR)/tools/hv prepare
endef

define Build/Compile
	$(MAKE_VARS) $(MAKE) $(MAKE_FLAGS) \
		CFLAGS="$(TARGET_CFLAGS) -I$(LINUX_DIR)/tools/include" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		-C $(LINUX_DIR)/tools/hv \
		hv_kvp_daemon hv_vss_daemon hv_fcopy_daemon
endef

define Package/hv-tools/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(LINUX_DIR)/tools/hv/hv_kvp_daemon $(1)/usr/sbin/
	$(INSTALL_BIN) $(LINUX_DIR)/tools/hv/hv_vss_daemon $(1)/usr/sbin/
	$(INSTALL_BIN) $(LINUX_DIR)/tools/hv/hv_fcopy_daemon $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/usr/libexec/hypervkvpd
	$(INSTALL_BIN) $(LINUX_DIR)/tools/hv/hv_get_dhcp_info.sh $(1)/usr/libexec/hypervkvpd/hv_get_dhcp_info
	$(INSTALL_BIN) $(LINUX_DIR)/tools/hv/hv_get_dns_info.sh $(1)/usr/libexec/hypervkvpd/hv_get_dns_info
	$(INSTALL_BIN) ./files/usr/libexec/hypervkvpd/hv_set_ifconfig.sh $(1)/usr/libexec/hypervkvpd/hv_set_ifconfig

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/hv_fcopy_daemon $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/etc/init.d/hv_kvp_daemon $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/etc/init.d/hv_vss_daemon $(1)/etc/init.d/
endef

$(eval $(call BuildPackage,hv-tools))
