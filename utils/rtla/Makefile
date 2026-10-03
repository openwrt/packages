# SPDX-License-Identifier: GPL-2.0
#
# Copyright (C) 2026 Bootlin

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=rtla
PKG_VERSION:=$(LINUX_VERSION)

PKG_MAINTAINER:=Benjamin Robin <benjamin.robin@bootlin.com>
PKG_LICENSE:=GPL-2.0-only

include $(INCLUDE_DIR)/package.mk

define Package/rtla
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Real-Time Linux Analysis tools
  URL:=https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git
  DEPENDS:= @USE_GLIBC @(KERNEL_OSNOISE_TRACER||KERNEL_TIMERLAT_TRACER) +libtracefs +libtraceevent
endef

define Package/rtla/description
The rtla meta-tool includes a set of commands that aims to analyze
the real-time properties of Linux. Instead of testing Linux as a black box,
rtla leverages kernel tracing capabilities to provide precise information
about the properties and root causes of unexpected results.

Available commands are:
- osnoise (requires osnoise tracer)
- hwnoise (requires osnoise tracer)
- timerlat (requires timerlat tracer)
endef

MAKE_FLAGS = \
	CROSS_COMPILE="$(TARGET_CROSS)" \
	CC="$(TARGET_CC)" \
	CFLAGS='$(TARGET_CFLAGS) $(TARGET_CPPFLAGS) -DVERSION="\"$(PKG_VERSION)\"" -I$(STAGING_DIR)/usr/include/traceevent' \
	LDFLAGS="$(TARGET_LDFLAGS)"

define Build/Compile
	$(MAKE) -C $(LINUX_DIR)/tools/tracing/rtla $(MAKE_FLAGS)
endef

define Package/rtla/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(LINUX_DIR)/tools/tracing/rtla/rtla $(1)/usr/bin
endef

$(eval $(call BuildPackage,rtla))
