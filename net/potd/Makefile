include $(TOPDIR)/rules.mk

PKG_NAME:=potd
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/lnslbrty/potd.git
PKG_SOURCE_VERSION:=f8497db5d14eb139820173dccba58989c4f9ca5c
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_SOURCE_VERSION).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_MIRROR_HASH:=ca26c057cb3de0ddd25a5b91c3daeffcfb692e603d22c4c70c3681db0e5f7f33
PKG_MAINTAINER:=Toni Uhlig <matzeton@googlemail.com>

PKG_INSTALL:=1
PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/potd
	SECTION:=net
	CATEGORY:=Network
	DEPENDS:=+libseccomp +libssh @KERNEL_NAMESPACES @KERNEL_UTS_NS @KERNEL_IPC_NS \
	         @KERNEL_PID_NS @KERNEL_NET_NS @KERNEL_CGROUPS @KERNEL_CGROUP_PIDS
	TITLE:=low to medium interactive SSH/TCP honeypot
endef

define Package/potd/description
	A high scalable low to medium interactive SSH/TCP honeypot using Linux
	Namespaces, capabilities, seccomp, cgroups designed for OpenWrt and IoT devices.
endef

define Package/potd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/potd $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,potd))
