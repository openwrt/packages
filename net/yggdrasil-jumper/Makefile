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
  Yggdrasil-jumper enhances the performance of data-intensive applications over the Yggdrasil
  network by establishing direct peer-to-peer connections, bypassing intermediary nodes.
  It utilizes NAT traversal to create a direct bridge to potentially reduce latency.
endef

# define Package/yggdrasil-jumper/conffiles
#   /etc/yggdrasil-jumper/yggdrasil-jumper.conf
# endef

define Package/yggdrasil-jumper/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/yggdrasil-jumper $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/stun-tcp $(1)/usr/sbin

	# $(INSTALL_DIR) $(1)/etc/yggdrasil-jumper
	# $(INSTALL_CONF) ./files/etc/yggdrasil-jumper/yggdrasil-jumper.conf $(1)/etc/yggdrasil-jumper

endef

$(eval $(call RustBinPackage,yggdrasil-jumper))
$(eval $(call BuildPackage,yggdrasil-jumper))
