include $(TOPDIR)/rules.mk

PKG_NAME:=reaction
PKG_VERSION:=2.0.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://framagit.org/ppom/reaction.git
PKG_SOURCE_DATE=2025-05-28
PKG_SOURCE_VERSION:=ebad317a9770744a832823b3aa96954f33900caf
PKG_MIRROR_HASH:=8bbd6325e3687f9daab554a3f9e78947019571490c0131e8174a93519564ac26

PKG_MAINTAINER:=Vladimir Ermakov <vooon341@gmail.com>
PKG_LICENSE:=AGPL-3.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-package.mk

define Package/reaction
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=$(RUST_ARCH_DEPENDS)
  TITLE:=Scan logs and take action (e.g. ban)
  URL:=https://framagit.org/ppom/reaction
endef

define Package/reaction/description
  A daemon that scans program outputs for repeated patterns, and takes action.
  A common usage is to scan ssh and webserver logs, and to ban hosts that cause multiple authentication errors.
endef

define Package/reaction/conffiles
/etc/reaction.jsonnet
endef

define Build/Compile
	$(call Build/Compile/Cargo)
	(cd $(PKG_BUILD_DIR); $(TARGET_CC) $(TARGET_CFLAGS) $(EXTRA_CFLAGS) -o $(PKG_INSTALL_DIR)/bin/nft46 helpers_c/nft46.c)
endef

define Package/reaction/install
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) $(CURDIR)/files/reaction.jsonnet $(1)/etc/reaction.jsonnet
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) $(CURDIR)/files/reaction.init $(1)/etc/init.d/reaction
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/reaction $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/nft46 $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib/reaction
endef

$(eval $(call RustBinPackage,reaction))
$(eval $(call BuildPackage,reaction))
