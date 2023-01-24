# SPDX-Identifier-License: GPL-2.0-or-later
#
# Copyright (C) 2023 Vincent Tremblay <vincent@vtremblay.dev>

include $(TOPDIR)/rules.mk

PKG_NAME:=bccmd
PKG_VERSION:=6.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/bccmd/bccmd.git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=2cd7e6eb755785101a60e1da70de2d7788ba7bd2459b576e82b5851ed422588e

PKG_MAINTAINER=Vincent Tremblay <vincent@vtremblay.dev>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_PARALLEL:=1

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/bccmd
  TITLE:=CSR BlueCore command interface
  SECTION:=utils
  CATEGORY:=Utilities
  URL:=https://github.com/bccmd/bccmd.git
  DEPENDS:=+bluez-libs
endef

define Package/bccmd/description
  BBCMD is used to send BlueCore commands to Cambridge Silicon Radio devices.
endef

CONFIGURE_ARGS += --disable-manpages

define Package/bccmd/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bccmd $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,bccmd))
