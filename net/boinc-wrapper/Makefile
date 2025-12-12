# SPDX-Identifier-License: GPL-3.0-or-later
#
# Copyright (C) 2023 by Vitalii Koshura <lestat.de.lionkur@gmail.com>
#

include $(TOPDIR)/rules.mk

PKG_NAME:=boinc-wrapper
PKG_VERSION:=26018
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/BOINC/boinc/tar.gz/refs/tags/wrapper/$(PKG_VERSION)?
PKG_HASH:=a93ae0a9e640a893e78f523c6d93f31b1d5812092f85af4e9ce964846373f55d

PKG_MAINTAINER:=Vitalii Koshura <lestat.de.lionkur@gmail.com>
PKG_LICENSE:=GPL-3.0-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:boinc-wrapper:boinc-wrapper

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=0
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/target.mk

define Package/boinc-wrapper
  SECTION:=net
  CATEGORY:=Network
  TITLE:=BOINC wrapper
  DEPENDS:=+libstdcpp
  URL:=https://github.com/BOINC/boinc/
endef

define Package/boinc-wrapper/description
  The Berkeley Open Infrastructure for Network Computing (BOINC) is a
  software platform for distributed computing: several initiatives of
  various scientific disciplines all compete for the idle time of
  desktop computers. The developers' web site at the University of
  Berkeley serves as a common portal to the otherwise independently run
  projects.

  This package provides the BOINC wrapper that runs the Project applications as
  subprocesses, and handles all communication with the BOINC client
  (e.g., to report CPU time and fraction done).
endef

CONFIGURE_ARGS += \
	--disable-server --disable-manager --disable-client --enable-libraries \
	--enable-boinczip \
	--with-boinc-platform=$(REAL_GNU_TARGET_NAME) \
	--with-boinc-alt-platform=$(ARCH)-$(BOARD)-$(DEVICE_TYPE)-openwrt-$(TARGET_SUFFIX)

TARGET_CFLAGS += -Wno-format -Wno-format-security
TARGET_CPPFLAGS += -Wno-format -Wno-format-security

define Build/Compile
	$(call Build/Compile/Default)
	$(MAKE_VARS) $(MAKE) \
		-C $(PKG_BUILD_DIR)/samples/wrapper \
		$(MAKE_FLAGS)
endef

define Package/boinc-wrapper/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/samples/wrapper/wrapper $(1)/usr/bin/boinc-wrapper
endef

$(eval $(call BuildPackage,boinc-wrapper))
