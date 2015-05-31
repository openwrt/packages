#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gnurl
PKG_VERSION:=7.40.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://gnunet.org/sites/default/files

PKG_MD5SUM:=f816deb0c1401c841780ec6b91985a14

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/gnurl/Default
  SECTION:=net
  CATEGORY:=Network
  URL:=https://gnunet.org/gnurl
  MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
endef

define Package/gnurl
  $(call Package/gnurl/Default)
  SUBMENU:=File Transfer
  DEPENDS:=+libgnurl
  TITLE:=A client-side HTTP/HTTPS transfer utility
endef

define Package/libgnurl
  $(call Package/gnurl/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libgnutls +libidn
  TITLE:=A client-side HTTP/HTTPS transfer library
endef

TARGET_CFLAGS += $(FPIC)

CONFIGURE_ARGS += \
	--disable-debug \
	--disable-ares \
	$(call autoconf_bool,CONFIG_IPV6,ipv6) \
	--enable-shared \
	--enable-static \
	--disable-manual \
	--disable-ldap \
	--disable-ldaps \
	--with-gnutls="$(STAGING_DIR)/usr" \
	--with-ipv6 \
	--with-libidn="$(STAGING_DIR)/usr" \
	--without-axtls \
	--without-ca-bundle \
	--without-ca-path \
	--without-cyassl \
	--without-libmetalink \
	--without-librtmp \
	--without-nss \
	--without-polarssl \
	--without-ssl \
	--without-zlib

define Build/Compile
	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		CC="$(TARGET_CC)" \
		install
endef

define Build/InstallDev
	$(INSTALL_DIR) $(2)/bin $(1)/usr/bin $(1)/usr/include/gnurl $(1)/usr/lib $(1)/usr/lib/pkgconfig
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gnurl-config $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/curl/*.h $(1)/usr/include/gnurl
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgnurl.{a,so*} $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/libgnurl.pc $(1)/usr/lib/pkgconfig/
	$(SED) 's,-L$$$${exec_prefix}/lib,,g' $(1)/usr/bin/gnurl-config
	[ -n "$(TARGET_LDFLAGS)" ] && $(SED) 's#$(TARGET_LDFLAGS)##g' $(1)/usr/lib/pkgconfig/libgnurl.pc || true
	$(LN) $(STAGING_DIR)/usr/bin/gnurl-config $(2)/bin/
endef

define Package/gnurl/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/gnurl $(1)/usr/bin/
endef

define Package/libgnurl/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libgnurl.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,gnurl))
$(eval $(call BuildPackage,libgnurl))
