#
# Copyright (C) 2006-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=suricata
PKG_VERSION:=5.0.3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.openinfosecfoundation.org/download/
PKG_HASH:=34413ecdad2ff2452526dbcd22f1279afd0935151916c0ff9cface4b0b5665db

PKG_FIXUP:=autoreconf
PKG_FIXUP:=patch-libtool
PKG_FIXUP:=gettext-version
PKG_INSTALL:=1

PKG_BUILD_DEPENDS:=rustup/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include $(TOPDIR)/feeds/packages/lang/rustup/rustc-triple.mk

define Package/suricata5
    SUBMENU:=Firewall
    SECTION:=net
    CATEGORY:=Network
    DEPENDS:=+libpcre +libpcre2 +libpcap +libnet-1.2.x +libyaml +zlib +libmagic \
       +jansson +libnfnetlink +lua +liblz4 +libnss +libopenssl \
	  +python3 +python3-yaml +libcap-ng $(ICONV_DEPENDS)
    TITLE:=OISF Suricata IDS
    URL:=https://www.openinfosecfoundation.org/
endef

CONFIGURE_VARS += \
	CARGO_HOME=$(HOST_CARGO_DIR) \
	RUSTUP_HOME=$(HOST_RUST_DIR) \
	ac_cv_path_CARGO="$(HOST_CARGO_DIR)/bin/cargo" \
	ac_cv_path_RUSTC="$(HOST_CARGO_DIR)/bin/rustc"

CONFIGURE_ARGS = \
   --prefix="/usr" \
   --sysconfdir="/etc" \
   --enable-nfqueue \
   --localstatedir="/var" \
   --enable-gccprotect \
   --enable-debug \
   --enable-pie \
   --host=$(RUSTC_TARGET_ARCH)

define Package/suricata5/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/suricata $(1)/usr/bin/suricata

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig

	$(INSTALL_DIR) $(1)/etc/suricata
	$(CP) \
	$(PKG_BUILD_DIR)/suricata.yaml \
	$(PKG_BUILD_DIR)/etc/classification.config \
	$(PKG_BUILD_DIR)/threshold.config \
	$(PKG_BUILD_DIR)/etc/reference.config \
	$(1)/etc/suricata/
	$(INSTALL_DIR) $(1)/etc/suricata/rules
	$(CP) $(PKG_BUILD_DIR)/rules/*.rules $(1)/etc/suricata/rules/
	$(INSTALL_DIR) $(1)/etc/init.d
#	$(INSTALL_BIN) ./files/suricata.init $(1)/etc/init.d/suricata
endef

$(eval $(call BuildPackage,suricata5))
