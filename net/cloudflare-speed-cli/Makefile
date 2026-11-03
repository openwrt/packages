include $(TOPDIR)/rules.mk

PKG_NAME:=cloudflare-speed-cli
PKG_VERSION:=1.0.12
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-vendor.tar.zst
PKG_SOURCE_URL:=@OPENWRT
PKG_SOURCE_PROTO:=cargo-vendor-github
PKG_VENDOR_REPO:=kavehtehrani/cloudflare-speed-cli
PKG_VENDOR_TAG:=v$(PKG_VERSION)
PKG_VENDOR_HASH:=4a873aa6fe7fd66ac47df3b0a34038771b4a17b11e0894c69263138fc73208c7
PKG_HASH:=9a97cf09d1e931ac62cae1775732d6060f25bc7ea850fbdc1cf34d197982314a

PKG_MAINTAINER:=Dave Marquard <dave@marquard.org>
PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/rust-package.mk

# The speed test counts bytes in AtomicU64, which Rust lacks on 32-bit mips,
# powerpc and ARMv5; ring needs SSE2 on 32-bit x86.
define Package/cloudflare-speed-cli
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Cloudflare speed test client with TUI
  URL:=https://github.com/kavehtehrani/cloudflare-speed-cli
  DEPENDS:=$(RUST_PKG_DEPENDS) @HAS_ATOMIC64 @!i386
endef

define Package/cloudflare-speed-cli/description
  Command line client for speed.cloudflare.com. It measures download
  and upload throughput, idle and loaded latency, jitter and packet
  loss, and can also run DNS, TLS handshake and traceroute probes.
  Results can be shown in an interactive terminal UI or printed as
  plain text or JSON.
endef

# The clipboard feature pulls in arboard, which talks to X11 and is of
# no use on a router; keep the TUI but leave the clipboard out.
RUST_PKG_FEATURES:=tui
CARGO_PKG_ARGS+= --no-default-features

$(eval $(call RustBinPackage,cloudflare-speed-cli))
$(eval $(call BuildPackage,cloudflare-speed-cli))
