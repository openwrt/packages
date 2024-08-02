# SPDX-License-Identifier: GPL-2.0-or-later

include $(TOPDIR)/rules.mk

PKG_NAME:=geoipupdate
PKG_VERSION:=7.0.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/maxmind/geoipupdate/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=59c80ab737f128fc05e4ecdec4d84652182851dc8c8bea892022e3fc12db9101

PKG_LICENSE:=Apache-2.0 MIT
PKG_LICENSE_FILES:=LICENSE-APACHE LICENSE-MIT
PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/maxmind/geoipupdate/v7
GO_PKG_LDFLAGS_X:= \
	main.defaultConfigFile=/etc/GeoIP.conf \
	main.defaultDatabaseDirectory=/var/GeoIP \
	main.version=$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/geoipupdate
  SECTION:=net
  CATEGORY:=Network
  TITLE:=GeoIP Update
  URL:=https://github.com/maxmind/geoipupdate
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
	$(call GoPackage/Package/Install/Bin,$(1))

	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/GeoIP.conf.default $(1)/etc/GeoIP.conf
endef

define Package/geoipupdate/conffiles
/etc/GeoIP.conf
endef

$(eval $(call GoBinPackage,geoipupdate))
$(eval $(call BuildPackage,geoipupdate))
