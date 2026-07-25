include $(TOPDIR)/rules.mk

PKG_NAME:=rustnet
PKG_VERSION:=1.5.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/domcyrus/rustnet/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=f6425992dc5a8a700323c1231d1833a135cd93424d86cfaa788eed6cb700fe33

PKG_MAINTAINER:=Jonir Rings <i@jonirrings.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=rust/host bpf-headers bpftool/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/bpf.mk
include ../../lang/rust/rust-package.mk

define Package/rustnet
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Per-process network monitor with DPI
  URL:=https://github.com/domcyrus/rustnet
  # You need enable KERNEL_DEBUG_INFO_BTF and KERNEL_BPF_EVENTS
  DEPENDS:=@(aarch64||x86_64||riscv64) $(BPF_DEPENDS) +libpcap +libcap +libelf
endef

define Package/rustnet/description
  A terminal-based, per-process network monitoring tool with deep
  packet inspection. Maps TCP, UDP, and QUIC connections to owning
  processes using eBPF (Linux), PKTAP (macOS), or native APIs,
  with DPI for HTTP, TLS/SNI, DNS, SSH, QUIC, and many other protocols.
  Supports exporting annotated PCAPNG files with process metadata
  and GeoIP enrichment.
endef

define Package/rustnet/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/rustnet $(1)/usr/bin
endef

$(eval $(call RustBinPackage,rustnet))
$(eval $(call BuildPackage,rustnet))
