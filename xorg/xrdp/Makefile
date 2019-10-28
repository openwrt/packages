# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=xrdp
PKG_VERSION:=0.9.9
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://github.com/neutrinolabs/xrdp/releases/download/v$(PKG_VERSION)/
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=8edf33346a8b3718a828d2c998ac1a036ea707e7f02b47092c8ae20dd71a9362

PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/xrdp
  SECTION:=xorg
  CATEGORY:=Xorg
  DEPENDS:=+libx11 +libxfixes +libxrandr +libopenssl +libjpeg-turbo +libice \
	+libsm
  TITLE:=An open source RDP server
  URL:=http://www.xrdp.org/
endef


CONFIGURE_ARGS += \
  --prefix=/usr \
  --disable-pam \
  TURBOJPEG_PATH=$(STAGING_DIR)/usr \
  --enable-tjpeg

define Build/InstallDev
	$(INSTALL_DIR) \
	 $(1)/usr/include \
	 $(1)/usr/lib

	$(CP) \
	 $(PKG_INSTALL_DIR)/usr/include/* \
	 $(1)/usr/include/

	$(CP) \
	 $(PKG_INSTALL_DIR)/usr/lib/{pkgconfig,*.so*} \
	 $(1)/usr/lib/
endef

define Package/xrdp/install
$(INSTALL_DIR) \
	  $(1)/usr/bin \
	  $(1)/etc/xrdp \
	  $(1)/usr/sbin \
	  $(1)/usr/lib/xrdp

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/bin/* \
	  $(1)/usr/bin/
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/sbin/* \
	  $(1)/usr/sbin/
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/*.so* \
	  $(1)/usr/lib/
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/xrdp/*.so* \
	  $(1)/usr/lib/xrdp/
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/share \
	  $(1)/usr/
	$(CP) \
	  $(PKG_INSTALL_DIR)/etc/xrdp \
	  $(1)/etc/
endef

$(eval $(call BuildPackage,xrdp))
