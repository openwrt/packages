# $Id: Makefile 5624 2006-11-23 00:29:07Z nbd $

include $(TOPDIR)/rules.mk

PKG_NAME:=tayga
PKG_VERSION:=0.9.6
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/apalrd/tayga/tar.gz/$(PKG_VERSION)?
PKG_HASH:=64da04887e59207be0f62082e63dca98b1e770283fa37102ccb0a3e8d2acedc5
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/tayga
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+ip @IPV6 +kmod-tun
  TITLE:=Out-of-kernel stateless NAT64 implementation
  URL:=https://github.com/apalrd/tayga/
  MAINTAINER:=Goetz Goerisch <ggoerisch@gmail.com>
endef

define Package/tayga/description
  TAYGA is an out-of-kernel stateless NAT64 implementation for
  Linux.  It uses the TUN driver to exchange packets with the
  kernel, which is the same driver used by OpenVPN and QEMU/KVM.
endef

ifdef CONFIG_PACKAGE_netifd
  define Package/tayga/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/lib/netifd/proto
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tayga $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/tayga-proto.sh $(1)/lib/netifd/proto/tayga.sh
  endef
else
  define Package/tayga/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/lib/network $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tayga $(1)/usr/sbin/
	$(INSTALL_DATA) ./files/tayga.sh $(1)/lib/network/tayga.sh
	$(INSTALL_DATA) ./files/tayga.hotplug $(1)/etc/hotplug.d/iface/95-tayga
  endef
endif

$(eval $(call BuildPackage,tayga))
