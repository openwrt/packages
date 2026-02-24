include $(TOPDIR)/rules.mk

PKG_NAME:=nordvpnlite
PKG_VERSION:=0.1.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/NordSecurity/libtelio.git
PKG_SOURCE_VERSION:=nordvpnlite/v$(PKG_VERSION)
PKG_MIRROR_HASH:=f1bb174bc87248981f5852ed500f016689177a9987813505d10b1677bffb0572

MAKE_PATH:=clis/nordvpnlite

PKG_MAINTAINER:=Lukas Pukenis <lukas.pukenis@nordsec.com>, \
	Oleksandr Oliinyk <oleksandr.oliinyk@nordsec.com>, \
	Tomasz Grzegowski <tomasz.grzegowski@nordsec.com>
PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE clis/nordvpnlite/openwrt/feed/net/nordvpnlite/THIRD-PARTY-NOTICES
PKG_BUILD_DEPENDS:=rust/host protobuf/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-package.mk

# Upstream build.rs checks for git hooks which don't exist in the build directory
CARGO_PKG_VARS += BYPASS_LLT_SECRETS=1
# Short commit hash for the nordvpnlite/v0.1.0 tag
CARGO_PKG_VARS += LIBTELIO_COMMIT_SHA=8dabaf3

define Package/nordvpnlite
  SECTION:=net
  CATEGORY:=Network
  TITLE:=NordVPN Lite
  URL:=https://www.nordsecurity.com
  DEPENDS:=$(RUST_ARCH_DEPENDS) @!i386 +kmod-tun +kmod-wireguard
endef

define Package/nordvpnlite/description
  NordVPN Lite is the gateway to a secure and private access to the internet.
endef

define Package/nordvpnlite/conffiles
/etc/nordvpnlite/config.json
endef

define Package/nordvpnlite/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/nordvpnlite $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/clis/nordvpnlite/openwrt/feed/net/nordvpnlite/files/nordvpnlite.init \
		$(1)/etc/init.d/nordvpnlite

	$(INSTALL_DIR) $(1)/etc/nordvpnlite
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/clis/nordvpnlite/openwrt/feed/net/nordvpnlite/files/config.json \
		$(1)/etc/nordvpnlite/config.json

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/clis/nordvpnlite/openwrt/feed/net/nordvpnlite/files/nordvpnlite.conf \
		$(1)/etc/config/nordvpnlite
endef

define Package/nordvpnlite/postinst
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	echo "Enabling nordvpnlite service"
	/etc/init.d/nordvpnlite enable
fi
exit 0
endef

define Package/nordvpnlite/prerm
#!/bin/sh
if [ -z "$${IPKG_INSTROOT}" ]; then
	echo "Disabling nordvpnlite service"
	/etc/init.d/nordvpnlite disable
fi
exit 0
endef

$(eval $(call RustBinPackage,nordvpnlite))
$(eval $(call BuildPackage,nordvpnlite))
