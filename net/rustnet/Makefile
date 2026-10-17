include $(TOPDIR)/rules.mk

PKG_NAME:=rustnet
PKG_VERSION:=1.6.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/domcyrus/rustnet/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=245fc7074d5f142fbf1c798233be86b715b4f2ce3b3cfec10fabdcbbc9345ddb

PKG_MAINTAINER:=Jonir Rings <i@jonirrings.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/bpf.mk
include $(INCLUDE_DIR)/nls.mk
include ../../lang/rust/rust-package.mk

define Package/rustnet
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Per-process network monitor with DPI
  URL:=https://github.com/domcyrus/rustnet
  DEPENDS:=@(aarch64||x86_64) $(BPF_DEPENDS) $(INTL_DEPENDS) \
   @KERNEL_DEBUG_INFO_BTF @KERNEL_BPF_EVENTS \
   +libpcap +libelf
endef

define Package/rustnet/description
  A terminal-based, per-process network monitoring tool with deep
  packet inspection. Maps TCP, UDP, and QUIC connections to owning
  processes using eBPF, with DPI for HTTP, TLS/SNI, DNS, SSH, QUIC,
  and many other protocols.
  Supports exporting annotated PCAPNG files with process metadata
  and GeoIP enrichment.
endef

# Fixes the main/target crate graph link only (reaches RUSTFLAGS). The
# separate build-script link (rustnet-host's build.rs, via libbpf-cargo ->
# libbpf-rs -> libbpf-sys -> -lelf, compiled for the host under cargo's
# resolver-v2 host/target feature+rustflags split) is fixed independently
# via patches/ - see that patch's header comment. See openwrt/packages#24375.
RUSTC_LDFLAGS+= $(if $(INTL_FULL),-L$(INTL_PREFIX)/lib -lintl)

define Package/rustnet/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/rustnet $(1)/usr/bin
endef

$(eval $(call RustBinPackage,rustnet))
$(eval $(call BuildPackage,rustnet))
