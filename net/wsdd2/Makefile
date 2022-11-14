include $(TOPDIR)/rules.mk

PKG_NAME:=wsdd2
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/Netgear/wsdd2.git
PKG_SOURCE_DATE:=2022-04-25
PKG_SOURCE_VERSION:=e37443ac4c757dbf14167ec3f754ebe88244ad4b
PKG_MIRROR_HASH:=45e0c37b8e275c8d088506f953aa25b30a31600ce67ccb4f60b1eda6688a5a8b

PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/wsdd2
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=Web Services for Devices (WSD) daemon
  URL:=https://github.com/Netgear/wsdd2
endef

define Package/wsdd2/description
  Web Services for Devices or Web Services on Devices (WSD),
  is a Microsoft API to simplify programming connections to web service
  enabled devices, such as printers, scanners and file shares.

  This daemon advertises and responds to probe requests from Windows clients looking for file shares.
  It also implements LLMNR multicast name lookup services.
endef

define Build/Compile
  $(TARGET_CC) $(TARGET_CFLAGS) $(TARGET_LDFLAGS) $(PKG_BUILD_DIR)/{wsdd2.c,wsd.c,llmnr.c} -o $(PKG_BUILD_DIR)/wsdd2
endef

define Package/wsdd2/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/wsdd2 $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/wsdd2.init $(1)/etc/init.d/wsdd2
endef

$(eval $(call BuildPackage,wsdd2))
