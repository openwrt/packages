#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=suricata
PKG_VERSION:=2.0.6
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.openinfosecfoundation.org/download/
PKG_MD5SUM:=14bfb3adc184d4da321c93ed9abae500

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/suricata
  SECTION:=net
  # DEPENDS:=+libpthread $(CXX_DEPENDS) +zlib
  DEPENDS:=+libmagic +libpcre +libyaml +libiconv
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=Suricata
  URL:=http://suricata-ids.org
endef

define Package/suricata/conffiles
/etc/suricata/suricata.yaml
/etc/config/suricata
endef

# CONFIGURE_VARS += \
# 	INCLUDES="" \
# 	CXXFLAGS="$$$$CXXFLAGS -fno-rtti" \
# 	LIBS="-lpthread" \

#define Build/Configure
#	$(call Build/Configure/Default,\
#		--disable-clamav \
#		--with-sysconfsubdir=suricata \
#		--with-proxyuser=root \
#		--with-proxygroup=root \
#		--disable-pcre \
#	)
#endef

	# --enable-nfqueue \
	# --enable-prelude \
	# --enable-pfring \
	# --enable-non-bundled-htp \

CONFIGURE_ARGS += \
	--with-libnet-includes=${STAGING_DIR}/usr/include/ \
	--with-libnet-libraries=${STAGING_DIR}/usr/lib/

define Package/suricata/install
	# $(INSTALL_DIR) $(1)/usr/sbin
	# $(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/dansguardian $(1)/usr/sbin/
        #
	# $(INSTALL_DIR) $(1)/etc
	# $(CP) $(PKG_INSTALL_DIR)/etc/dansguardian $(1)/etc/
	# $(INSTALL_CONF) ./files/dansguardianf1.conf $(1)/etc/dansguardian/dansguardianf1.conf
        #
	# $(INSTALL_DIR) $(1)/etc/config
	# $(INSTALL_CONF) ./files/dansguardian.config $(1)/etc/config/dansguardian
        #
	# $(INSTALL_DIR) $(1)/usr/share/dansguardian
	# $(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/share/dansguardian/transparent1x1.gif $(1)/usr/share/dansguardian/
	# $(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/share/dansguardian/blockedflash.swf $(1)/usr/share/dansguardian/
        #
	# $(INSTALL_DIR) $(1)/usr/share/dansguardian/languages/ukenglish
	# $(CP) $(PKG_INSTALL_DIR)/usr/share/dansguardian/languages/ukenglish/* $(1)/usr/share/dansguardian/languages/ukenglish/
        #
	# $(INSTALL_DIR) $(1)/etc/init.d/
	# $(INSTALL_BIN) ./files/dansguardian.init $(1)/etc/init.d/dansguardian
endef

$(eval $(call BuildPackage,suricata))
