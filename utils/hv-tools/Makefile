include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=hv-tools
PKG_RELEASE:=1.0.0
PKG_LICENSE:=GPL-2.0-only

PKG_MAINTAINER:=Evgeniy Nikulov <nikulov@live.ru>

include $(INCLUDE_DIR)/package.mk

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
	$(INSTALL_DIR) $(PKG_BUILD_DIR)
	wget -q -O $(PKG_BUILD_DIR)/hv_kvp_daemon.c \
		'https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/plain/tools/hv/hv_kvp_daemon.c?h=v$(LINUX_VERSION)'
	wget -q -O $(PKG_BUILD_DIR)/hv_vss_daemon.c \
		'https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/plain/tools/hv/hv_vss_daemon.c?h=v$(LINUX_VERSION)'
	wget -q -O $(PKG_BUILD_DIR)/hv_fcopy_uio_daemon.c \
		'https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/plain/tools/hv/hv_fcopy_uio_daemon.c?h=v$(LINUX_VERSION)'
	wget -q -O $(PKG_BUILD_DIR)/vmbus_bufring.h \
		'https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/plain/tools/hv/vmbus_bufring.h?h=v$(LINUX_VERSION)'
	wget -q -O $(PKG_BUILD_DIR)/vmbus_bufring.c \
		'https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/plain/tools/hv/vmbus_bufring.c?h=v$(LINUX_VERSION)'
	wget -q -O $(PKG_BUILD_DIR)/hv_get_dhcp_info.sh \
		'https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/plain/tools/hv/hv_get_dhcp_info.sh?h=v$(LINUX_VERSION)'
	wget -q -O $(PKG_BUILD_DIR)/hv_get_dns_info.sh \
		'https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/plain/tools/hv/hv_get_dns_info.sh?h=v$(LINUX_VERSION)'
endef

define Build/Compile
	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		-o $(PKG_BUILD_DIR)/hv_kvp_daemon \
		$(PKG_BUILD_DIR)/hv_kvp_daemon.c \
		-lpthread
	
	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		-o $(PKG_BUILD_DIR)/hv_vss_daemon \
		$(PKG_BUILD_DIR)/hv_vss_daemon.c
	
	$(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) \
		-D__always_inline=inline \
		-o $(PKG_BUILD_DIR)/hv_fcopy_daemon \
		$(PKG_BUILD_DIR)/hv_fcopy_uio_daemon.c \
		$(PKG_BUILD_DIR)/vmbus_bufring.c
endef

define Package/hv-tools/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/hv_kvp_daemon $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/hv_vss_daemon $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/hv_fcopy_daemon $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/usr/libexec/hypervkvpd
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/hv_get_dhcp_info.sh $(1)/usr/libexec/hypervkvpd/hv_get_dhcp_info
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/hv_get_dns_info.sh $(1)/usr/libexec/hypervkvpd/hv_get_dns_info
	$(INSTALL_BIN) ./files/usr/libexec/hypervkvpd/hv_set_ifconfig.sh $(1)/usr/libexec/hypervkvpd/hv_set_ifconfig

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/hv_fcopy_daemon $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/etc/init.d/hv_kvp_daemon $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/etc/init.d/hv_vss_daemon $(1)/etc/init.d/
endef

$(eval $(call BuildPackage,hv-tools))
