#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the
# GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=jq
PKG_VERSION:=1.8.1
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/jqlang/jq/releases/download/$(PKG_NAME)-$(PKG_VERSION)/
PKG_HASH:=2be64e7129cecb11d5906290eba10af694fb9e3e7f9fc208a311dc33ca837eb0

PKG_MAINTAINER:=
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:jqlang:jq

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

define Package/jq/Default
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Lightweight and flexible command-line JSON processor
  URL:=https://jqlang.github.io/jq/
endef

define Package/jq
  $(call Package/jq/Default)
  TITLE+= (noregex)
  VARIANT:=noregex
  DEFAULT_VARIANT:=1
endef

define Package/jq/description
  Lightweight and flexible command-line JSON processor.
  This package was compiled without ONIGURUMA regex library.
  match/test/sub and related functions are not available.
endef

define Package/jq-full
  $(call Package/jq/Default)
  TITLE+= (full)
  DEPENDS+=+oniguruma
  VARIANT:=full
  PROVIDES:=jq
endef

define Package/jq-full/description
  Lightweight and flexible command-line JSON processor.
  This package was compiled with ONIGURUMA regex library and has full regex support.
endef

CONFIGURE_ARGS+= \
	--disable-docs \
	--disable-valgrind

HOST_CONFIGURE_ARGS+= \
	--disable-docs \
	--disable-valgrind \
	--without-oniguruma

ifeq ($(BUILD_VARIANT),full)
  CONFIGURE_ARGS += --with-oniguruma
else
  CONFIGURE_ARGS += --without-oniguruma
endif

define Host/Configure
	cd $(HOST_BUILD_DIR) && \
	autoreconf -fiv && \
	$(call Host/Configure/Default)
endef

define Package/jq/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/* $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libjq.so* $(1)/usr/lib/
endef

Package/jq-full/install = $(Package/jq/install)

$(eval $(call HostBuild))
$(eval $(call BuildPackage,jq))
$(eval $(call BuildPackage,jq-full))
