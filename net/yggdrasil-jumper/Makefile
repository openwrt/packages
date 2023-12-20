include $(TOPDIR)/rules.mk

PKG_NAME:=yggdrasil-jumper
PKG_VERSION:=0.2.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/one-d-wide/yggdrasil-jumper/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=1660eca235f3f7f21a632355fa3ed9961d7c180c3d2d3d486ddd76642905d450

PKG_MAINTAINER:=William Fleurant <meshnet@protonmail.com>
PKG_LICENSE:=LGPL-3.0-only

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-package.mk


define Package/yggdrasil-jumper
	SECTION:=net
	CATEGORY:=Network
	SUBMENU:=Routing and Redirection
	TITLE:=Yggdrasil peer-to-peer firewall stun
	URL:=https://github.com/one-d-wide/yggdrasil-jumper
	DEPENDS:=$(RUST_ARCH_DEPENDS) @!arc @IPV6 +kmod-tun
endef


define Package/yggdrasil-jumper/description
  Yggdrasil-Jumper utilizes NAT traversal for latency reduction within the Yggdrasil network by
  creating direct peer-to-peer connections. It offers self-activating NAT/Firewall traversal,
  eliminating the necessity for firewall or port configuration. It probles for Yggdrasil-Jumper
  of routers found in active sessions to leverage NAT traversal for constructing direct internet
  bridges.
endef


define Package/yggdrasil-jumper/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/uci-defaults $(1)/etc/init.d

	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/yggdrasil-jumper $(1)/usr/sbin

	$(INSTALL_BIN) ./files/yggdrasil-jumper.defaults $(1)/etc/uci-defaults/yggdrasil-jumper

	$(INSTALL_BIN) ./files/yggdrasil-jumper.init $(1)/etc/init.d/yggdrasil-jumper
endef


define Package/cjdns/postinst
#!/bin/sh
if [ -z $${IPKG_INSTROOT} ] ; then
	( . /etc/uci-defaults/yggdrasil-jumper ) && rm -f /etc/uci-defaults/yggdrasil-jumper
	/etc/init.d/yggdrasil-jumper enabled || /etc/init.d/yggdrasil-jumper enable
	exit 0
fi
endef


$(eval $(call RustBinPackage,yggdrasil-jumper))
$(eval $(call BuildPackage,yggdrasil-jumper))
