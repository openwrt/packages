#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=openocd
PKG_VERSION:=v0.9.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=git://git.code.sf.net/p/openocd/code
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_SOURCE_VERSION).tar.gz
PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING

PKG_MAINTAINER:=Paul Fertser <fercerpav@gmail.com>

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/openocd
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=OpenOCD Utility
  URL:=http://openocd.sf.net/
  DEPENDS:=+libusb-1.0 +libusb-compat +libftdi1 +hidapi
endef

define Package/openocd/description
OpenOCD provides on-chip programming and debugging support with a
layered architecture of JTAG interface and TAP support including:

- (X)SVF playback to faciliate automated boundary scan and FPGA/CPLD
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

CONFIGURE_ARGS += \
	--prefix="/usr" \
	--disable-werror \
	MAKEINFO=true \
	--enable-dummy \
	--enable-sysfsgpio \
	--enable-usb_blaster_libftdi \
        --enable-openjtag_ftdi \
        --enable-presto_libftdi

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
