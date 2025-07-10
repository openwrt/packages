#
# Copyright (C) 2025 The Atsign Foundation

include $(TOPDIR)/rules.mk

PKG_NAME:=csshnpd
PKG_VERSION:=1.0.14
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-c$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/atsign-foundation/noports/releases/download/c$(PKG_VERSION)
PKG_HASH:=86c9f3e5d3b149df9a32ef7b3ae52e78623c1beed4bedcfe90c852ea8504b40f

PKG_MAINTAINER:=Chris Swan <chris@atsign.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-c$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS += \
	-S . \
	-DATSDK_BUILD_TESTS="OFF" \
	-DATSDK_MEMCHECK="OFF" \
	-DBUILD_SHARED_AND_STATIC_LIBS="OFF" \
	-DCMAKE_EXPORT_COMPILE_COMMANDS="OFF" \
	-DCMAKE_INSTALL_PREFIX="${PKG_BUILD_DIR}/build/release-static/tmp-install-dir" \
	-DENABLE_PROGRAMS="OFF" \
	-DENABLE_TARGET_EXPORT="OFF" \
	-DENABLE_TESTING="OFF" \
	-DNOPORTS_ATSDK_PATH="deps/atsdk-src" \
	-DNOPORTS_BUILD_TESTS="OFF" \
	-DNOPORTS_USE_SHARED_LIBS="ON"

define Package/csshnpd
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=SSH
  DEPENDS:=+libmbedtls +cJSON
  TITLE:=NoPorts Daemon
  URL:=https://noports.com
endef

define Package/csshnpd/description
  A small and portable daemon for NoPorts.
endef

define Package/csshnpd/conffiles
/etc/config/sshnpd
/root/.atsign/
endef

define Package/csshnpd/install	
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sshnpd/sshnpd $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sshnpd/at_activate $(1)/usr/bin/
	$(INSTALL_BIN) ./files/at_enroll.sh $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/csshnpd.config $(1)/etc/config/sshnpd
	
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/csshnpd.init $(1)/etc/init.d/sshnpd
endef

$(eval $(call BuildPackage,csshnpd))
