#
# Copyright (C) 2006-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ntp
PKG_VERSION:=4.2.6p5
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.eecis.udel.edu/~ntp/ntp_spool/ntp4/ntp-4.2/
PKG_MD5SUM:=00df80a84ec9528fcfb09498075525bc

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

PKG_BUILD_DEPENDS:=libelf1
PKG_FIXUP:=autoreconf
PKG_LIBTOOL_PATHS:=. sntp

include $(INCLUDE_DIR)/package.mk

define Package/ntpd/Default
  SUBMENU:=Time Synchronization
  SECTION:=net
  CATEGORY:=Network
  TITLE:=ISC ntp
  MAINTAINER:=Peter Wagner <tripolar@gmx.at>
  URL:=http://www.ntp.org/
  DEPENDS:=+libcap
endef

define Package/ntpd/Default/description
 The ISC ntp suite is a collection of tools used to synchronize the
 system clock with remote NTP time servers and run/montior local NTP
 servers.
endef

define Package/ntpd
$(call Package/ntpd/Default)
  TITLE+= server
  VARIANT:=nossl
endef

define Package/ntpd/description
$(call Package/ntpd/Default/description)
 .
 This package contains the ntpd server.
endef

define Package/ntpd-ssl
$(call Package/ntpd/Default)
  TITLE+= server (with OpenSSL support)
  VARIANT:=ssl
  DEPENDS+= +libopenssl
endef

define Package/ntpd-ssl/description
$(call Package/ntpd/Default/description)
 .
 This package contains the ntpd server with OpenSSL support.
endef

define Package/ntpdate
$(call Package/ntpd/Default)
  TITLE+=date
  VARIANT:=nossl
endef

define Package/ntpdate/description
$(call Package/ntpd/Default/description)
 .
 This package contains ntpdate.
endef

define Package/ntp-utils
$(call Package/ntpd/Default)
  TITLE+= utilities
  VARIANT:=nossl
endef

define Package/ntp-utils/description
$(call Package/ntpd/Default/description)
 .
 This package contains ntpdc, ntpq and ntptime.
endef

define Package/ntp-keygen
$(call Package/ntpd/Default)
  TITLE+=keygen
  VARIANT:=nossl
endef

define Package/ntp-keygen/description
$(call Package/ntpd/Default/description)
 .
 This package contains the ntp-keygen.
endef

define Package/ntp-keygen-ssl
$(call Package/ntpd/Default)
  TITLE+=keygen (with OpenSSL support)
  VARIANT:=ssl
  DEPENDS+= +libopenssl
endef

define Package/ntp-keygen-ssl/description
$(call Package/ntpd/Default/description)
 .
 This package contains the ntp-keygen with OpenSSL support.
endef

define Package/ntpd/conffiles
/etc/ntp.conf
endef

CONFIGURE_VARS += \
	ac_cv_header_md5_h=no \
	ac_cv_lib_rt_sched_setscheduler=no \
	ac_cv_header_dns_sd_h=no

CONFIGURE_ARGS += \
	--disable-all-clocks \
	--disable-parse-clocks \
	--without-ntpsnmpd \
	--without-lineeditlibs \
	--enable-NMEA \
	--enable-LOCAL-CLOCK \
	--enable-SHM \
	--enable-linuxcaps

ifeq ($(BUILD_VARIANT),ssl)
  CONFIGURE_ARGS += \
	--with-crypto \
	--with-openssl-incdir="$(STAGING_DIR)/usr/include" \
	--with-openssl-libdir="$(STAGING_DIR)/usr/lib"
endif

define Package/ntpd/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ntpd/ntpd $(1)/sbin/
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) ./files/ntp.conf $(1)/etc/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/ntpd.init $(1)/etc/init.d/ntpd
	$(INSTALL_DIR) $(1)/etc/hotplug.d/iface
	$(INSTALL_BIN) ./files/ntpd.hotplug $(1)/etc/hotplug.d/iface/20-ntpd
endef

define Package/ntpd/postinst
#!/bin/sh
[ -L "$${IPKG_INSTROOT}/usr/sbin/ntpd" ] && rm -f "$${IPKG_INSTROOT}/usr/sbin/ntpd"
exit 0
endef

define Package/ntpd/postrm
#!/bin/sh
/bin/busybox ntpd -h 2>&1 | grep -q BusyBox && ln -sf ../../bin/busybox /usr/sbin/ntpd
exit 0
endef

Package/ntpd-ssl/conffiles = $(Package/ntpd/conffiles)
Package/ntpd-ssl/install = $(Package/ntpd/install)

define Package/ntpdate/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ntpdate/ntpdate $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/ntpdate.init $(1)/etc/init.d/ntpdate
endef

define Package/ntp-utils/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ntpdc/ntpdc $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ntpq/ntpq $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/util/ntptime $(1)/usr/sbin/
endef

define Package/ntp-keygen/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/util/ntp-keygen $(1)/usr/sbin/
endef

Package/ntp-keygen-ssl/install = $(Package/ntp-keygen/install)

$(eval $(call BuildPackage,ntpd))
$(eval $(call BuildPackage,ntpd-ssl))
$(eval $(call BuildPackage,ntpdate))
$(eval $(call BuildPackage,ntp-utils))
$(eval $(call BuildPackage,ntp-keygen))
$(eval $(call BuildPackage,ntp-keygen-ssl))
