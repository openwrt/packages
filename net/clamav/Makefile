
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=clamav
PKG_VERSION:=0.102.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.clamav.net/downloads/production/
PKG_HASH:=eebd426a68020ecad0d2084b8c763e6898ccfd5febcae833d719640bb3ff391b

PKG_MAINTAINER:=Marko Ratkaj <marko.ratkaj@sartura.hr> \
		Lucian Cristian <lucian.cristian@gmail.com>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING*
PKG_CPE_ID:=cpe:/a:clamav:clamav

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_FIXUP:=autoreconf

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

CONFIGURE_ARGS += \
	--sysconfdir=/etc/clamav/ \
	--enable-milter \
	--disable-bzip2 \
	--disable-check \
	--disable-clamdtop \
	--disable-rpath \
	--disable-xml \
	--disable-zlib-vcheck \
	--with-user=nobody \
	--with-group=nogroup \
	--with-libcurl="$(STAGING_DIR)/usr/" \
	--with-libjson="$(STAGING_DIR)/usr/" \
	--with-openssl="$(STAGING_DIR)/usr/" \
	--with-pcre="$(STAGING_DIR)/usr/" \
	--with-zlib="$(STAGING_DIR)/usr/" \
	--without-iconv \
	--without-libncurses-prefix

CONFIGURE_VARS += \
	ax_cv_uname_syscall=yes \
	ac_cv_c_mmap_private=yes \
	have_cv_gai=yes \
	ac_cv_sys_file_offset_bits=no

CONFIGURE_VARS += $(if $(CONFIG_IPV6),have_cv_ipv6=yes)

TARGET_CXXFLAGS += -ffunction-sections -fdata-sections -fno-rtti -flto
TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed $(if $(CONFIG_USE_MUSL),-lfts)

define Package/clamav/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/clamd $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/clamav-milter $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/clambc $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/clamconf $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/clamdscan $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/clamscan $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/clamonacc $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/sigtool $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib*/lib*.so.* $(1)/usr/lib/

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
