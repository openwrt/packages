#
# Copyright (C) 2010-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ortp
PKG_VERSION:=0.23.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SAVANNAH/linphone/ortp/sources
PKG_MD5SUM:=fb833cc7a66ec1a0c1b75016130e7e6d

PKG_LICENSE:=LGPL-2.1
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Nicolas Thill <nico@openwrt.org>

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libortp
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Real-time Transport Protocol (RTP) library
  URL:=http://www.linphone.org/technical-corner/ortp/overview
  DEPENDS:= +libpthread +librt
endef

ifneq ($(CONFIG_avr32),)
  TARGET_CFLAGS += -fsigned-char
endif

CONFIGURE_ARGS += \
	--enable-shared \
	--enable-static \
	--disable-debug \
	--enable-ipv6 \
	--enable-perf \
	--disable-ssl-hmac \
	--disable-tests \
	--without-srtp \

CONFIGURE_VARS += \
	ac_cv_header_srtp_srtp_h=no \
	ac_cv_lib_srtp_srtp_init=no \
	ac_cv_path_DOXYGEN= \

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	( cd $(PKG_INSTALL_DIR); $(CP) \
		./usr/include/ortp \
		$(1)/usr/include/ \
	)
	$(INSTALL_DIR) $(1)/usr/lib
	( cd $(PKG_INSTALL_DIR); $(CP) \
		./usr/lib/libortp.{a,so*} \
		$(1)/usr/lib/ \
	)
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	( cd $(PKG_INSTALL_DIR); $(CP) \
		./usr/lib/pkgconfig/ortp.pc \
		$(1)/usr/lib/pkgconfig/ \
	)
endef

define Package/libortp/install
	$(INSTALL_DIR) $(1)/usr/lib
	( cd $(PKG_INSTALL_DIR); $(CP) \
		./usr/lib/libortp.so.* \
		$(1)/usr/lib/ \
	)
endef

$(eval $(call BuildPackage,libortp))
