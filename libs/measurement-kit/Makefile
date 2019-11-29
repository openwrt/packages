#
# Copyright (C) 2019 CZ.NIC z.s.p.o. (http://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=measurement-kit
PKG_VERSION:=0.10.6
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/measurement-kit/measurement-kit/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=5ec94e522c3bc43cbf749659c18d4b13bcfbb2874db4d6b4e21b160d76dd5bd0

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec@nic.cz>
PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/measurement-kit
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=library for open network measurement
  URL:=https://measurement-kit.github.io/
  DEPENDS:=+libstdcpp +libcurl +libevent2-pthreads +libevent2-extra +libevent2-openssl +libevent2-core +libmaxminddb +ca-bundle
endef

define Package/measurement-kit/description
 Measurement Kit is a C++14 library that implements open network measurement methodologies (performance, censorship, etc.)
endef

CONFIGURE_ARGS+= --with-ca-bundle=/etc/ssl/cert.pem

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
endef

$(eval $(call BuildPackage,measurement-kit))
