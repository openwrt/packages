#
# Copyright (C) 2020 Brian Norris <computersforpeace@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=cros-vboot
PKG_VERSION:=20200715
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://chromium.googlesource.com/chromiumos/platform/vboot_reference
PKG_SOURCE_DATE:=2020-07-15
PKG_SOURCE_VERSION:=ed23c08440dae6657d026a30b504578e03e0426f
PKG_MIRROR_HASH:=99829bce6dec127279ed774415e0747586cba7362e00f06c267da17a56ba0ef3

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
  TITLE:=Chrome OS verified boot utilities
  URL:=https://chromium.googlesource.com/chromiumos/platform/vboot_reference
  DEPENDS:=+libuuid +USE_MUSL:musl-fts +libopenssl
endef

define Build/Configure
	# Chromium OS builds with Clang and -Werror; our warnings may differ.
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
