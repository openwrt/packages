# SPDX-License-Identifier: GPL-2.0-or-later

include $(TOPDIR)/rules.mk

PKG_NAME:=geoipupdate
PKG_VERSION:=4.9.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/maxmind/geoipupdate/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=43195d457a372dc07be593d815212d6ea21e499a37a6111058efa3296759cba9

PKG_LICENSE:=Apache-2.0 MIT
PKG_LICENSE_FILES:=LICENSE-APACHE LICENSE-MIT
PKG_MAINTAINER:=Matthew Hagan <mnhagan88@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/maxmind/geoipupdate
GO_PKG_LDFLAGS_X:= \
	main.defaultConfigFile=/etc/GeoIP.conf \
	main.defaultDatabaseDirectory=/var/GeoIP

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/geoipupdate
  TITLE:=GeoIP Update
  URL:=https://github.com/maxmind/geoipupdate
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/geoipupdate/description
 The GeoIP Update program performs automatic updates of GeoIP2 and GeoIP
 Legacy binary databases. CSV databases are not supported.

 Users will need to update /etc/GeoIP.conf with their API key and DB
 choice, currently set to country only. To update the DB, the user can
 manually run the utility or set up a cron job.

 This package contains the program and config file.
endef

define Package/geoipupdate/install
	$(call GoPackage/Package/Install/Bin,$(PKG_INSTALL_DIR))
	
	$(INSTALL_DIR) \
	$(1)/usr/sbin \
	$(1)/etc/init.d

	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/geoipupdate $(1)/usr/sbin/
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/GeoIP.conf.default $(1)/etc/GeoIP.conf
	$(INSTALL_BIN) ./files/geoipupdate.init $(1)/etc/init.d/geoipupdate

	$(SED) "s/^EditionIDs GeoLite2-Country GeoLite2-City/EditionIDs GeoLite2-Country/" $(1)/etc/GeoIP.conf
endef

define Package/geoipupdate/conffiles
/etc/GeoIP.conf
endef

$(eval $(call GoBinPackage,geoipupdate))
$(eval $(call BuildPackage,geoipupdate))
