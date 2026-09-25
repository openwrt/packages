# SPDX-License-Identifier: GPL-2.0-or-later
include $(TOPDIR)/rules.mk

PKG_NAME:=ifwatchdog
PKG_VERSION:=0.2.4
PKG_RELEASE:=1

# Pulled from the tagged GitHub release, not the repo's live HEAD (openwrt/packages
# CONTRIBUTING.md: "DO NOT use an archive which changes over time"). GitHub's
# archive/refs/tags/<tag>.tar.gz endpoint is deterministic for a given tag -
# verified reproducible (identical sha256 across repeated downloads). The
# extracted top-level directory is "ifwatchdog-<version>" (GitHub's
# <repo>-<tag-without-v> convention), which matches the default
# PKG_BUILD_DIR ($(PKG_NAME)-$(PKG_VERSION)) exactly, so no PKG_BUILD_DIR
# override is needed.
#
# On every version bump: update PKG_VERSION, push+tag the matching vX.Y.Z
# release first, THEN recompute PKG_HASH against that tag's real archive
# (e.g. `curl -sL https://github.com/one7two99/ifwatchdog/archive/refs/tags/vX.Y.Z.tar.gz | sha256sum`)
# - the build fails closed (hash mismatch) if this drifts, so there is no
# silent-wrong-source failure mode, only a loud one.
PKG_SOURCE:=v$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/one7two99/ifwatchdog/archive/refs/tags/
PKG_HASH:=af2c9f07b7bf9f9d24a4ba570e57187129defc344439afb54ba21a04be2b24a5

PKG_MAINTAINER:=one7two99
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

define Package/ifwatchdog
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Interface health watchdog (ping + WireGuard handshake)
  URL:=https://github.com/one7two99/ifwatchdog
  PKGARCH:=all
endef

define Package/ifwatchdog/description
  Monitors a network interface and restarts it when it silently stalls,
  using an interface-bound ping and/or WireGuard handshake age. Safety-first:
  monitor by default, interface denylist, input validation, debounce and a
  circuit breaker. Configurable via UCI (/etc/config/ifwatchdog).
endef

define Package/ifwatchdog/conffiles
/etc/config/ifwatchdog
endef

define Build/Compile
endef

define Package/ifwatchdog/install
	$(INSTALL_DIR) $(1)/usr/libexec
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ifwatchdog/files/ifwatchdog.sh $(1)/usr/libexec/ifwatchdog.sh
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ifwatchdog/files/ifwatchdog.init $(1)/etc/init.d/ifwatchdog
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/ifwatchdog/files/ifwatchdog.config $(1)/etc/config/ifwatchdog
	# action=script is confined to this package-owned directory (validate_config).
	$(INSTALL_DIR) $(1)/usr/libexec/ifwatchdog.d
endef

$(eval $(call BuildPackage,ifwatchdog))
