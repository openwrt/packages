# SPDX-License-Identifier: AGPL-3.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=lpac
PKG_VERSION:=2.0.0
PKG_RELEASE:=1

PKG_SOURCE:=lpac-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/estkme-group/lpac/tar.gz/refs/tags/v$(PKG_VERSION)?
PKG_HASH:=686faad1cac49649aaa749be41b44f6ec303833d4f8ef586245de4ad545d4886

PKG_MAINTAINER:=David Bauer <mail@david-bauer.net>
PKG_LICENSE:=AGPL-3.0-only

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


TARGET_CFLAGS += $(FPIC)

define Package/lpac/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/usr/lib $(1)/etc/config

	$(CP) ./files/lpac.uci $(1)/etc/config/lpac
	$(INSTALL_BIN) ./files/lpac.sh $(1)/usr/bin/lpac

	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/lpac $(1)/usr/lib/lpac
endef

$(eval $(call BuildPackage,lpac))
