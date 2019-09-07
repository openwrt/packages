#
# Copyright (C) 2019 Lucian Cristian
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=nss
PKG_VERSION:=3.46
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:= \
    https://download.cdn.mozilla.net/pub/security/$(PKG_NAME)/releases/NSS_$(subst .,_,$(PKG_VERSION))_RTM/src \
    https://archive.mozilla.org/pub/security/$(PKG_NAME)/releases/NSS_$(subst .,_,$(PKG_VERSION))_RTM/src
PKG_HASH:=6b699649d285602ba258a4b0957cb841eafc94eff5735a9da8da0adbb9a10cef

PKG_MAINTAINER:=Lucian Cristian <lucian.cristian@gmail.com>
PKG_LICENCE:=MPL-2.0
PKG_LICENSE_FILES:=nss/COPYING
PKG_CPE_ID:=cpe:/a:mozilla:network_security_services

PKG_BUILD_PARALLEL:=0

include $(INCLUDE_DIR)/package.mk

define Package/libnss
  SECTION:=libs
  SUBMENU:=SSL
  CATEGORY:=Libraries
  TITLE:=Mozilla's SSL and TLS implementation
  URL:=https://developer.mozilla.org/en-US/docs/Mozilla/Projects/NSS
  DEPENDS:=+libpthread +libsqlite3 +nspr
endef

define Package/nss-utils
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Utilities for Mozilla's SSL and TLS implementation
  URL:=https://developer.mozilla.org/en-US/docs/Mozilla/Projects/NSS
  DEPENDS:=+libnss
endef

define Package/libnss/description
  Network Security Services (NSS) is a set of libraries designed to support
  cross-platform development of security-enabled client and server applications.
  Applications built with NSS can support SSL v2 and v3, TLS, PKCS 5, PKCS 7,
  PKCS 11, PKCS 12, S/MIME, X.509 v3 certificates, and other security standards.
endef

CONFIGURE_PATH = ./nss
MAKE_PATH = ./nss

LBITS = $(shell $(TARGET_CC) -dM -E - </dev/null | grep -q "__LP64__" && echo 64 || echo 32)

ifeq ($(LBITS),64)
    export USE_64=1
endif

TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

export CROSS_COMPILE=1
export BUILD_OPT=1
export NATIVE_CC=$(HOSTCC)
export NATIVE_FLAGS=$(HOST_CFLAGS)
export NSDISTMODE=copy
export NSS_ENABLE_WERROR=0
export NSS_DISABLE_GTESTS=1
export NSS_USE_SYSTEM_SQLITE=1
export OS_TARGET=Linux
export OS_ARCH=Linux
export OS_TEST=$(ARCH)
export CPU_ARCH=$(ARCH)
export fpic=$(FPIC)
export NSPR_INCLUDE_DIR=$(STAGING_DIR)/usr/include/nspr
export SEED_ONLY_DEV_URANDOM=1
export OS_REL_CFLAGS=$(TARGET_CFLAGS)
export NS_USE_GCC=1
export FREEBL_NO_DEPEND=1
#size optimisation, seems to not impact speed
export NSS_DISABLE_DBM=1
export NSS_PKIX_NO_LDAP=1
export ALLOW_OPT_CODE_SIZE=1
export OPT_CODE_SIZE=1

#native compile nsinstall
define Build/Prepare
	$(call Build/Prepare/Default)
	USE_NATIVE=1 OS_REL_CFLAGS="$(HOST_CFLAGS)" LDFLAGS="$(HOST_LDFLAGS)" CC="$(HOSTCC)" \
	    $(MAKE) -C $(PKG_BUILD_DIR)/nss/coreconf/nsinstall
#	$(if $(CONFIG_LIBC_USE_GLIBC),, \
#		$(SED) '/-DHAVE_SYS_CDEFS_H/d' $(PKG_BUILD_DIR)/nss/lib/dbm/config/config.mk)
endef

define Package/libnss/conffiles
/etc/pki/nssdb
endef

define Build/InstallDev
	$(INSTALL_DIR) \
	 $(1)/usr/include/nss \
	 $(1)/usr/lib \
	 $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_BUILD_DIR)/dist/private/nss/*.h \
	  $(1)/usr/include/nss/
	$(CP) $(PKG_BUILD_DIR)/dist/public/nss/*.h \
	  $(1)/usr/include/nss/
	$(CP) $(PKG_BUILD_DIR)/dist/build_dir/lib/*.so \
	  $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/nss/config/*.pc \
	  $(1)/usr/lib/pkgconfig/
endef

define Package/nss-utils/install
	$(INSTALL_DIR) \
	 $(1)/usr/bin
	$(CP) $(PKG_BUILD_DIR)/dist/build_dir/bin/certutil $(1)/usr/bin
	$(CP) $(PKG_BUILD_DIR)/dist/build_dir/bin/pk12util $(1)/usr/bin
endef

#for now pack only libreswan needed libs
define Package/libnss/install
	$(INSTALL_DIR) \
	 $(1)/usr/lib \
	 $(1)/etc/pki/nssdb \
	 $(1)/etc/ipsec.d

	$(CP) $(PKG_BUILD_DIR)/dist/build_dir/lib/libfreebl3.so $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/dist/build_dir/lib/libnss3.so $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/dist/build_dir/lib/libnssutil3.so $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/dist/build_dir/lib/libsmime3.so $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/dist/build_dir/lib/libsoftokn3.so $(1)/usr/lib/
	$(CP) $(PKG_BUILD_DIR)/dist/build_dir/lib/libssl3.so $(1)/usr/lib/
#	Pprovide databases with a blank certificate
	$(CP)	./files/blank-cert9.db $(1)/etc/pki/nssdb/cert9.db
	$(CP)	./files/blank-key4.db $(1)/etc/pki/nssdb/key4.db
	$(CP)	./files/system-pkcs11.txt $(1)/etc/pki/nssdb/pkcs11.txt
	ln -s /etc/pki/nssdb/cert9.db $(1)/etc/ipsec.d/cert9.db
	ln -s /etc/pki/nssdb/key4.db $(1)/etc/ipsec.d/key4.db
	ln -s /etc/pki/nssdb/pkcs11.txt $(1)/etc/ipsec.d/pkcs11.txt
endef

$(eval $(call BuildPackage,nss-utils))
$(eval $(call BuildPackage,libnss))
