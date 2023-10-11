# SPDX-License-Identifier: GPL-3.0-only
#
# Copyright (C) 2023 Facundo Acevedo

include $(TOPDIR)/rules.mk

PKG_NAME:=arp-whisper
PKG_VERSION:=0.1.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/FacundoAcevedo/arp-whisper/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=13b393c64505d62b5abf7ace244eed0ce62f4b1562a688ddb5651bd42cc7c305

PKG_MAINTAINER:=Facundo Acevedo <facevedo@disroot.org>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=LICENCE

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-package.mk

define Package/arp-whisper
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=ARP responses based on MAC-IP pairs
  DEPENDS:=$(RUST_ARCH_DEPENDS) 
  URL:=https://github.com/FacundoAcevedo/arp-whisper
endef

define Package/arp-whisper/description
  arp-whisper listens to ARP requests on a network interface and responds
  to them based on a list of IP-MAC address mappings defined in a 
  configuration file.
endef

define Package/arp-whisper/conffiles
/etc/arp-whisper/arp-whisper
endef

define Package/arp-whisper/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/bin/arp-whisper $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DIR) $(1)/etc/arp-whisper
	$(INSTALL_CONF) ./files/etc/arp-whisper/arp-whisper $(1)/etc/arp-whisper
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/arp-whisper.init $(1)/etc/init.d/arp-whisper
endef

$(eval $(call RustBinPackage,arp-whisper))
$(eval $(call BuildPackage,arp-whisper))
