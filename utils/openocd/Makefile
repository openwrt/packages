#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=openocd
PKG_VERSION:=0.12.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_SOURCE_URL:=https://git.code.sf.net/p/openocd/code
PKG_MIRROR_HASH:=7fa2476feff229e6c7674dc27f949f8a573335abfa0b19cf27b9acf3937678f6

PKG_MAINTAINER:=Paul Fertser <fercerpav@gmail.com>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:openocd:open_on-chip_debugger

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

PKG_CONFIG_DEPENDS:=CONFIG_PACKAGE_openocd_with_usb

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/openocd
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=OpenOCD Utility
  URL:=https://openocd.org/
  DEPENDS:=+libusb-1.0 \
	+libftdi1 \
	+hidapi \
	+libgpiod \
	+libjaylink
endef

define Package/openocd/description
OpenOCD provides on-chip programming and debugging support with a
layered architecture of JTAG interface and TAP support including:

- (X)SVF playback to facilitate automated boundary scan and FPGA/CPLD
  programming;
- debug target support (e.g. ARM, MIPS): single-stepping,
  breakpoints/watchpoints, gprof profiling, etc;
- flash chip drivers (e.g. CFI, NAND, internal flash);
- embedded TCL interpreter for easy scripting.

Several network interfaces are available for interacting with OpenOCD:
telnet, TCL, and GDB. The GDB server enables OpenOCD to function as a
"remote target" for source-level debugging of embedded systems using
the GNU GDB program (and the others who talk GDB protocol, e.g. IDA
Pro).
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	-$(RM) $(PKG_BUILD_DIR)/guess-rev.sh
	-$(RM) $(PKG_BUILD_DIR)/jimtcl/configure.ac
endef

CONFIGURE_ARGS += \
	--prefix="/usr" \
	--disable-werror \
	MAKEINFO=true \
	--enable-dummy \
	--enable-sysfsgpio \
	--enable-linuxgpiod

ifeq ($(CONFIG_TARGET_bcm27xx),y)
	CONFIGURE_ARGS += --enable-bcm2835gpio
endif

TARGET_CFLAGS += -DRELSTR=\\\"-$(PKG_VERSION)-$(PKG_RELEASE)-OpenWrt\\\"

define Build/Compile
        +$(MAKE_VARS) \
        $(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR)/$(MAKE_PATH)
endef

define Package/openocd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/share/openocd
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/openocd $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/openocd/scripts $(1)/usr/share/openocd
endef

$(eval $(call BuildPackage,openocd))
