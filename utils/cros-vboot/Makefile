#
# Copyright 2025 Brian Norris <computersforpeace@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=cros-vboot
PKG_SOURCE_DATE:=2025-01-23
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://chromium.googlesource.com/chromiumos/platform/vboot_reference
PKG_SOURCE_VERSION:=e3731b76ae14d6779d7e1e60ce1f9c14a826de68
PKG_MIRROR_HASH:=259d259811383666200fbfcf7ceb3ecb69355b74293d9c5a673414d386d0280f

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILE:=LICENSE
PKG_MAINTAINER:=Brian Norris <computersforpeace@gmail.com>

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

MAKE_FLAGS += LD="$(TARGET_CC)" ARCH="$(ARCH)" CROSSYSTEM_LOCK_DIR="/var/run" WERROR=
TARGET_LDFLAGS += $(if $(CONFIG_USE_MUSL),-lfts)

define Package/cros-vboot
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=ChromeOS verified boot utilities
  URL:=https://chromium.googlesource.com/chromiumos/platform/vboot_reference
  DEPENDS:=+libflashrom +libuuid +USE_MUSL:musl-fts +libopenssl
endef

define Package/cros-vboot/install
	$(INSTALL_DIR) $(1)/usr/bin

	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/cgpt $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/crossystem $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/futility $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/tpmc $(1)/usr/bin

	# Developer keys, useful for (re)signing payloads. Not installed by
	# 'make install'.
	$(INSTALL_DIR) $(1)/usr/share/vboot/devkeys
	$(INSTALL_DATA) \
		$(PKG_BUILD_DIR)/tests/devkeys/{kernel_data_key.vbprivk,kernel.keyblock} \
		$(1)/usr/share/vboot/devkeys
endef

$(eval $(call BuildPackage,cros-vboot))
