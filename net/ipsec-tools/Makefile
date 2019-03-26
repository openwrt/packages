#
# Copyright (C) 2006-2015 OpenWrt.org
#               2014 Noah Meyerhans <frodo@morgul.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=ipsec-tools
PKG_VERSION:=0.8.2
PKG_RELEASE:=9
PKG_MAINTAINER:=Noah Meyerhans <frodo@morgul.net>, \
	Vitaly Protsko <villy@sft.ru>
PKG_LICENSE := BSD-3-Clause

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=@SF/ipsec-tools
PKG_HASH:=8eb6b38716e2f3a8a72f1f549c9444c2bc28d52c9536792690564c74fe722f2d

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/ipsec-tools
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=VPN
  DEPENDS:=+libopenssl +kmod-ipsec
  TITLE:=IPsec management tools
  URL:=http://ipsec-tools.sourceforge.net/
  MAINTAINER:=Noah Meyerhans <frodo@morgul.net>
endef

CONFIGURE_ARGS += \
	--enable-shared \
	--enable-static \
	--with-kernel-headers="$(LINUX_DIR)/include" \
	--without-readline \
	--with-openssl="$(STAGING_DIR)/usr" \
	--without-libradius \
	--without-libpam \
	--enable-dpd \
	--enable-hybrid \
	--enable-security-context=no \
	--enable-natt \
	--enable-adminport \
	--enable-frag \
	 $(call autoconf_bool,CONFIG_IPV6,ipv6)

# override CFLAGS holding "-Werror" that break builds on compile warnings
MAKE_FLAGS+=\
	CFLAGS="$(TARGET_CFLAGS) $(EXTRA_CFLAGS) $(TARGET_CPPFLAGS) $(EXTRA_CPPFLAGS)"

define Build/Prepare
	$(call Build/Prepare/Default)
	chmod -R u+w $(PKG_BUILD_DIR)
endef

define Build/Configure
	(cd $(PKG_BUILD_DIR); touch \
		configure.ac \
		aclocal.m4 \
		Makefile.in \
		config.h.in \
		configure \
	);
	$(call Build/Configure/Default)
ifndef CONFIG_SHADOW_PASSWORDS
	echo "#undef HAVE_SHADOW_H" >> $(PKG_BUILD_DIR)/config.h
endif
endef

define Package/ipsec-tools/install
	$(INSTALL_DIR) $(1)/etc/racoon
	$(INSTALL_CONF) ./files/functions.sh $(1)/etc/racoon/
	$(INSTALL_BIN) ./files/p1client-up $(1)/etc/racoon/
	$(INSTALL_BIN) ./files/p1client-down $(1)/etc/racoon/
	$(INSTALL_BIN) ./files/vpnctl $(1)/etc/racoon/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/racoon.init $(1)/etc/init.d/racoon
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/racoon $(1)/etc/config/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libipsec.so.* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libracoon.so.* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/plainrsa-gen $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/racoon $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/racoonctl $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/setkey $(1)/usr/sbin/
endef

define Package/ipsec-tools/conffiles
/etc/config/racoon
endef

$(eval $(call BuildPackage,ipsec-tools))
