# SPDX-License-Identifier: AGPL-3.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=lpac
PKG_VERSION:=2.0.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/estkme-group/lpac/tar.gz/refs/tags/v$(PKG_VERSION)?
PKG_HASH:=6afa88ed7d38ba5973a540d818c800083368ac82b3b09ac6fd18f7929b830b0a

PKG_MAINTAINER:=David Bauer <mail@david-bauer.net>
PKG_LICENSE:=AGPL-3.0-only LGPL-2.0-only

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/lpac
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=eUICC eSIM LPA written in C
  DEPENDS:=+libpcsclite +pcscd +libcurl
  URL:=https://github.com/estkme-group/lpac
endef

define Package/lpac/description
  lpac is a eUICC eSIM LPA manager written in C. It allows to
  manage eSIM profiles on eUICC SIM cards or modules using multiple
  backends.
endef

define Package/lpac/conffiles
/etc/config/lpac
endef

TARGET_CFLAGS += $(FPIC)

define Package/lpac/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/lpac.sh $(1)/usr/bin/lpac

	$(INSTALL_DIR) $(1)/etc/config
	$(CP) ./files/lpac.uci $(1)/etc/config/lpac

	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/lpac $(1)/usr/lib/lpac
endef

$(eval $(call BuildPackage,lpac))
