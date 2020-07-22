#
# Copyright (C) 2019-2020 CZ.NIC z.s.p.o. (http://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=measurement-kit
PKG_VERSION:=0.10.12
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/measurement-kit/measurement-kit/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=508d9db72579efbe4747dd791771f47299bc5867c72d67a86e371d66d20fd19e

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec@nic.cz>
PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_DEPENDS:=curl libevent2 libmaxminddb openssl
PKG_BUILD_PARALLEL:=1

PKG_CONFIG_DEPENDS:=MEASUREMENT_KIT_BUILD_DEPENDS

include $(INCLUDE_DIR)/package.mk

define Package/measurement-kit
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=library for open network measurement
  URL:=https://measurement-kit.github.io/
  DEPENDS:=+libstdcpp +libcurl +libevent2-pthreads +libevent2-extra +libevent2-openssl +libevent2-core +libmaxminddb +libopenssl +ca-bundle
endef

define Package/measurement-kit/description
 Measurement Kit is a C++14 library that implements open network measurement methodologies (performance, censorship, etc.)
endef

define Package/measurement-kit/config
config MEASUREMENT_KIT_BUILD_DEPENDS
	bool
	default PACKAGE_measurement-kit

config MEASUREMENT_KIT_BUILD_SELECT
	tristate
	default m if MEASUREMENT_KIT_BUILD_DEPENDS
	select PACKAGE_libevent2-openssl
	select PACKAGE_libevent2-pthreads
endef

CONFIGURE_ARGS+= --with-ca-bundle=/etc/ssl/cert.pem

TARGET_CFLAGS += $(if $(CONFIG_USE_UCLIBC),-DCATCH_CONFIG_GLOBAL_NEXTAFTER)

define Build/Configure
	( cd $(PKG_BUILD_DIR); ./autogen.sh )
	$(call Build/Configure/Default)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/* $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/* $(1)/usr/lib/
endef

define Package/measurement-kit/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/measurement_kit $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/measurement_kit
	$(CP) $(PKG_BUILD_DIR)/*.mmdb $(1)/etc/measurement_kit
endef

$(eval $(call BuildPackage,measurement-kit))
