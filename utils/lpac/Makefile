# SPDX-License-Identifier: AGPL-3.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=lpac
PKG_VERSION:=2.1.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/estkme-group/lpac/tar.gz/refs/tags/v$(PKG_VERSION)?
PKG_HASH:=532c5daef6888fe91b0838e8e23bf23ea2f5f39cbb755c008676b9cdfbd833fb

PKG_MAINTAINER:=David Bauer <david.bauer@uniberg.com>
PKG_LICENSE:=AGPL-3.0-only LGPL-2.0-only

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/lpac
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=eUICC eSIM LPA written in C
  DEPENDS:= \
    +LPAC_WITH_PCSC:libpcsclite \
    +LPAC_WITH_PCSC:pcscd \
    +libcurl
  URL:=https://github.com/estkme-group/lpac
endef

define Package/lpac/description
  lpac is a eUICC eSIM LPA manager written in C. It allows to
  manage eSIM profiles on eUICC SIM cards or modules using multiple
  backends.
endef

define Package/lpac/config
  source "$(SOURCE)/Config.in"
endef

define Package/lpac/conffiles
/etc/config/lpac
endef

TARGET_CFLAGS += $(FPIC)

# libqmi 1.35.4 or newer is required for QMI over QRTR
CMAKE_OPTIONS += \
  -DLPAC_WITH_APDU_PCSC=$(if $(CONFIG_LPAC_WITH_PCSC),ON,OFF) \
  -DLPAC_WITH_APDU_AT=$(if $(CONFIG_LPAC_WITH_AT),ON,OFF) \
  -DLPAC_WITH_APDU_UQMI=$(if $(CONFIG_LPAC_WITH_UQMI),ON,OFF) \
  -DLPAC_WITH_APDU_QMI_QRTR=OFF

define Package/lpac/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/lpac.sh $(1)/usr/bin/lpac

	$(INSTALL_DIR) $(1)/etc/config
	$(CP) ./files/lpac.uci $(1)/etc/config/lpac

	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/lpac $(1)/usr/lib/lpac
endef

$(eval $(call BuildPackage,lpac))
