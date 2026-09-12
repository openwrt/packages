include $(TOPDIR)/rules.mk

PKG_NAME:=tcpoptimizer-edge
PKG_VERSION:=0.3.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/honvl/tcpoptimizer-edge/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=07d8a57cc09a23eded25c1978b61e41a3a98d9cd50de4f16c774f1498a0f3b45

PKG_MAINTAINER:=Honver Lam <hl337@cornell.edu>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-package.mk

# rustls-ring depends on ring, which supports these OpenWrt architectures.
# Its 32-bit x86 backend requires SSE/SSE2, and OpenWrt builds every i386
# subtarget for the i586 rustc target (lang/rust/rust-values.mk), which has
# neither.
define Package/tcpoptimizer-edge
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Paired TCP transport optimizer over WireGuard
  URL:=https://github.com/honvl/tcpoptimizer-edge
  DEPENDS:=$(RUST_ARCH_DEPENDS) @(aarch64||arm||x86_64)
endef

define Package/tcpoptimizer-edge/description
  Authenticated split-TCP edge that multiplexes proxied TCP connections over
  a persistent QUIC transport between WireGuard-connected networks.
endef

define Package/tcpoptimizer-edge/conffiles
/etc/config/tcpoptimizer
endef

define Package/tcpoptimizer-edge/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/tcpoptimizer-edge $(1)/usr/sbin/
	$(INSTALL_BIN) $(CURDIR)/files/tcpoptimizer-intercept $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(CURDIR)/files/tcpoptimizer-edge.init \
		$(1)/etc/init.d/tcpoptimizer-edge
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(CURDIR)/files/tcpoptimizer.config \
		$(1)/etc/config/tcpoptimizer
	$(INSTALL_DIR) $(1)/etc/tcpoptimizer
endef

$(eval $(call RustBinPackage,tcpoptimizer-edge))
$(eval $(call BuildPackage,tcpoptimizer-edge))
