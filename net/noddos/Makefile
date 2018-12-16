#
# Copyright (C) 2017 Steven Hessing
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=noddos
PKG_VERSION:=0.5.6
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/noddos/noddos/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=c0663aac0556c4b967d4bfb4650e757a992b530c9676400ed24b23b73ddf3464

PKG_MAINTAINER:=Steven Hessing <steven.hessing@gmail.com>
PKG_LICENSE:=GPLv3
PKG_LICENSE_FILES:=LICENSE.md

PKG_BUILD_PARALLEL:=1
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/noddos
	SECTION:=net
	CATEGORY:=Network
	TITLE:=noddos -- device-aware cloud-powered firewall
	URL:=https://www.noddos.io/
	DEPENDS:=+libstdcpp +libnetfilter-conntrack +libcurl +libopenssl +openssl-util +ca-bundle +ca-certificates +wget +bzip2 +libtins +ipset +libpthread +libyaml-cpp
endef

define Package/noddos/description
Noddos discovers what devices you have in your network and tailors the firewall rules based on whitelisted flows for that device. Noddos downloads the firewall rules periodically from the cloud. In order to support creating these firewall rules, noddos can, after opt-in, upload anonimized traffic statistics for each device to the cloud. The Luci interface is available in the luci-apps-noddos package. For information, visit https://www.noddos.io/
endef

define Package/noddos/conffiles
	/etc/config/noddos
endef

define Package/noddos/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/etc/noddos
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/noddos $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tools/getnoddosdeviceprofiles $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/tools/makenoddoscert.sh $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/noddos.init $(1)/etc/init.d/noddos
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/files/noddos.uciconfig $(1)/etc/config/noddos
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/files/noddos.yml-base $(1)/etc/noddos
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/files/noddosconfig.pem $(1)/etc/noddos
endef

define Package/noddos/prerm
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		/etc/init.d/noddos stop
		echo "Removing rc.d symlink for noddos"
		/etc/init.d/noddos disable
	fi
	exit 0
endef

define Package/noddos/postrm
	#!/bin/sh
	# check if we are on real system
	if [ -z "$${IPKG_INSTROOT}" ]; then
		echo "Removing noddos data directory"
		rm -rf /var/lib/noddos
		if [ -f /var/etc/noddos.yml ]; then
			rm /var/etc/noddos.yml
		fi
	fi
	exit 0
endef

$(eval $(call BuildPackage,noddos))
