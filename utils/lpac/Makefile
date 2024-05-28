# SPDX-License-Identifier: AGPL-3.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=lpac
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/estkme-group/lpac.git
PKG_SOURCE_DATE:=2024-05-29
PKG_SOURCE_VERSION:=d41c2f84461f19f01fe0cebeadebacd0c3e009dc
PKG_MIRROR_HASH:=010f68ae93c07f279c71f80b819fa1003d93b768feb747125f29356970226961

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
