#
# Copyright 2023 Brian Norris <computersforpeace@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=cros-vboot
# Chromium project major release number, plus date.
PKG_VERSION:=115.20230606
PKG_RELEASE:=1
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://chromium.googlesource.com/chromiumos/platform/vboot_reference
PKG_SOURCE_DATE:=2023-06-06
PKG_SOURCE_VERSION:=77e9902e72f4499052d3cb9c2428beb97d8e0e3f
PKG_MIRROR_HASH:=2158756a9295f7be3f96f2ef13a8aa3b429dc9a16edfdff33b23d2c483296ead


PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILE:=LICENSE

PKG_MAINTAINER:=Brian Norris <computersforpeace@gmail.com>

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

MAKE_FLAGS += LD="$(TARGET_CC)" ARCH="$(ARCH)"
TARGET_LDFLAGS += $(if $(CONFIG_USE_MUSL),-lfts)

define Package/cros-vboot
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=ChromeOS verified boot utilities
  URL:=https://chromium.googlesource.com/chromiumos/platform/vboot_reference
  DEPENDS:=+libflashrom +libuuid +USE_MUSL:musl-fts +libopenssl
endef

define Build/Configure
	# ChromiumOS builds with Clang and -Werror; our warnings may differ.
	$(SED) 's/^WERROR :=.*/WERROR :=/' $(PKG_BUILD_DIR)/Makefile
	$(call Build/Configure/Default)
endef

define Package/cros-vboot/install
        $(INSTALL_DIR) $(1)/usr/bin

	$(INSTALL_BIN) $(PKG_BUILD_DIR)/build/cgpt/cgpt $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/build/utility/crossystem $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/build/futility/futility $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/build/utility/tpmc $(1)/usr/bin

	# Developer keys, useful for (re)signing payloads.
	$(INSTALL_DIR) $(1)/usr/share/vboot/devkeys
	$(INSTALL_DATA) \
		$(PKG_BUILD_DIR)/tests/devkeys/{kernel_data_key.vbprivk,kernel.keyblock} \
		$(1)/usr/share/vboot/devkeys
endef

$(eval $(call BuildPackage,cros-vboot))
