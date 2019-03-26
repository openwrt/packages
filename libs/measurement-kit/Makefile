#
# Copyright (C) 2019 CZ.NIC z.s.p.o. (http://www.nic.cz/)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=measurement-kit
PKG_VERSION:=0.10.0
PKG_RELEASE=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/measurement-kit/measurement-kit/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=c31ff8a457dfdbb2d42ef60f82646e508f6649107f15eec31fc22bc140ceb8e6

PKG_INSTALL:=1
PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1

PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_MAINTAINER:=Jan Pavlinec <jan.pavlinec@nic.cz>

include $(INCLUDE_DIR)/package.mk

define Package/measurement-kit
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=C++14 library that implements open network measurement methodologies
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

define Package/measurement-kit/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/measurement_kit $(1)/usr/bin/
endef

$(eval $(call BuildPackage,measurement-kit))
