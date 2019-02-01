#
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=clamav
PKG_VERSION:=0.101.1
PKG_RELEASE:=2

PKG_LICENSE:=GPL-2.0
PKG_MAINTAINER:=Marko Ratkaj <marko.ratkaj@sartura.hr> \
		Lucian Cristian <lucian.cristian@gmail.com>
PKG_CPE_ID:=cpe:/a:clamav:clamav

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.clamav.net/downloads/production/
PKG_HASH:=fa368fa9b2f57638696150c7d108b06dec284e8d8e3b8e702c784947c01fb806

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk

define Package/clamav/Default
  SECTION:=net
  DEPENDS:=$(CXX_DEPENDS) +libpthread +zlib +libcurl +libjson-c +libmilter-sendmail +libopenssl +libltdl +libpcre2 +USE_MUSL:musl-fts
  CATEGORY:=Network
  SUBMENU:=Web Servers/Proxies
  TITLE:=ClamAV
  URL:=https://www.clamav.net/
endef

define Package/clamav
    $(call Package/clamav/Default)
endef

define Package/freshclam
    $(call Package/clamav/Default)
    DEPENDS+= +clamav
    TITLE+=database updater
endef

define Package/clamav/description
 ClamAV is an open source antivirus engine for detecting trojans,
 viruses, malware & other malicious threats.
endef

define Package/freshclam/description
 Database updater for ClamAV
endef

define Package/clamav/conffiles
endef

CONFIGURE_VARS += \
	INCLUDES="" \
	CXXFLAGS="$$$$CXXFLAGS -fno-rtti" \
	$(if $(CONFIG_USE_MUSL),LIBS="-lpthread -lfts",LIBS="-lpthread") \

define Build/Configure
	$(call Build/Configure/Default, \
		--sysconfdir=/etc/clamav/ \
		--prefix=/usr/ \
		--exec-prefix=/usr/ \
		--enable-milter \
		--with-xml=no \
		--disable-bzip2 \
		--with-user nobody \
		--with-group nogroup \
		--with-pcre="$(STAGING_DIR)/usr/" \
		--with-openssl="$(STAGING_DIR)/usr/" \
		--with-zlib="$(STAGING_DIR)/usr/" \
		--disable-zlib-vcheck \
		--disable-clamdtop \
	)
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		all install
endef

define Package/clamav/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/clamd $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/clamav-milter $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/clamav-config $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/clambc $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/clamconf $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/clamdscan $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/clamscan $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/sigtool $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/clamav.h $(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib*/* $(1)/usr/lib/

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/clamav.config $(1)/etc/config/clamav

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/clamav.init $(1)/etc/init.d/clamav

	$(INSTALL_DIR) $(1)/usr/share/clamav
	$(CP) ./files/bytecode.cvd $(1)/usr/share/clamav/
endef

define Package/freshclam/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/freshclam $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/freshclam.config $(1)/etc/config/freshclam

	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/freshclam.init $(1)/etc/init.d/freshclam
endef

$(eval $(call BuildPackage,clamav))
$(eval $(call BuildPackage,freshclam))
