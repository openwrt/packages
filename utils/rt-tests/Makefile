# SPDX-License-Identifier: GPL-2.0
#
# Copyright (C) 2026 Bootlin

include $(TOPDIR)/rules.mk

PKG_NAME:=rt-tests
PKG_VERSION:=2.9
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@KERNEL/linux/utils/rt-tests
PKG_HASH:=95acf47cd8cbea2f8acd616fe590031daed8156d6f753093f2931a6e9cbeed8f

PKG_MAINTAINER:=Thomas Richard <thomas.richard@bootlin.com>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk

define Package/rt-tests
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Real-Time preemption testcases
  URL:=https://git.kernel.org/pub/scm/utils/rt-tests/rt-tests.git
  DEPENDS:= @USE_GLIBC +libnuma +python3-light
endef

define Package/rt-tests/description
Test suite that contains programs to test various real time Linux features.
endef

define Package/hwlatdetect
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Hardware latency detector
  URL:=https://git.kernel.org/pub/scm/utils/rt-tests/rt-tests.git
  DEPENDS:= @KERNEL_HWLAT_TRACER +python3-light
endef

define Package/hwlatdetect/description
Python utility for controlling the kernel hardware latency detection module
(hwlat_detector.ko).
endef

define Package/rt-tests/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cyclicdeadline $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/cyclictest $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/deadline_test $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/hackbench $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/oslat $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/pip_stress $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/pi_stress $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/pmqtest $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ptsematest $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/queuelat $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/rt-migrate-test $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/signaltest $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sigwaittest $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ssdd $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/svsematest $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/cyclictest/get_cyclictest_snapshot.py \
		$(1)/usr/bin/get_cyclictest_snapshot
endef

define Package/hwlatdetect/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/hwlatdetect/hwlatdetect.py \
		$(1)/usr/bin/hwlatdetect
endef

$(eval $(call BuildPackage,rt-tests))
$(eval $(call BuildPackage,hwlatdetect))
