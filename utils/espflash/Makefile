# SPDX-License-Identifier: GPL-2.0-only

include $(TOPDIR)/rules.mk

PKG_NAME:=espflash
PKG_VERSION:=4.6.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/esp-rs/espflash/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=4d6fd3b57e7fc33480df9e4db403352632a3d8af486ed2721a8f5ab3c666195e

PKG_MAINTAINER:=Victor Irzak <victor@irzak.com>
PKG_LICENSE:=Apache-2.0 OR MIT
PKG_LICENSE_FILES:=LICENSE-APACHE LICENSE-MIT

PKG_BUILD_DEPENDS:=rust/host
PKG_BUILD_PARALLEL:=1

## Leave out the update-check feature, which contacts crates.io on every run
RUST_PKG_FEATURES:=cli

include $(INCLUDE_DIR)/package.mk
include ../../lang/rust/rust-package.mk

define Package/espflash
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Serial flasher for Espressif SoCs
  DEPENDS:=$(RUST_ARCH_DEPENDS)
  URL:=https://github.com/esp-rs/espflash
endef

define Package/espflash/description
  espflash is a command-line tool for flashing Espressif SoCs (ESP32 and
  the ESP32-C, -H, -P and -S series) over a serial port or USB
  Serial/JTAG. It can also read and erase flash, print board information
  and open a serial monitor.
endef

## The source is a cargo workspace; build only the espflash member
Build/Compile=$(call Build/Compile/Cargo,espflash,--no-default-features)

$(eval $(call RustBinPackage,espflash))
$(eval $(call BuildPackage,espflash))
