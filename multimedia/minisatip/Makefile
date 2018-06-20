#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=minisatip
PKG_VERSION:=snapshot-20181122
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/catalinii/minisatip.git
PKG_SOURCE_VERSION:=6ca3b082e5fc2736764ff9a04f10600f36428527
PKG_MIRROR_HASH:=f6a10446d229bbed734e19fab8d82171ed63c6c8ae4fc78a0ad24c7591b540f9

PKG_MAINTAINER:=Daniel Kucera <github@danman.eu>

include $(INCLUDE_DIR)/package.mk

define Package/minisatip
  TITLE:=SATIP server
  URL:=https://github.com/catalinii/minisatip
  SECTION:=multimedia
  CATEGORY:=Multimedia
  DEPENDS := +MINISATIP_DVBAPI:libdvbapi +MINISATIP_DVBCSA:libdvbcsa +MINISATIP_CI:libdvben50221 +MINISATIP_AES:libopenssl
endef

define Package/minisatip/config
	if PACKAGE_minisatip

		config MINISATIP_CI
			bool "Common Interface"
			default n

		config MINISATIP_AES
			bool "OpenSSL (AES as part of DVBAPI)"
			default n

		config MINISATIP_DVBCSA
			bool "DVBCSA"
			default n

		config MINISATIP_CLIENT
			bool "SatIP Client"
			default y

		config MINISATIP_DVBAPI
			bool "dvbapi"
			default y

	endif
endef

ifeq ($(CONFIG_MINISATIP_CI),)
	CONFIGURE_ARGS += --disable-dvbca
endif

ifeq ($(CONFIG_MINISATIP_AES),)
	CONFIGURE_ARGS += --disable-dvbaes
endif

ifeq ($(CONFIG_MINISATIP_DVBCSA),)
	CONFIGURE_ARGS += --disable-dvbcsa
endif

ifeq ($(CONFIG_MINISATIP_CLIENT),)
	CONFIGURE_ARGS += --disable-satipc
endif

ifeq ($(CONFIG_MINISATIP_DVBAPI),)
	CONFIGURE_ARGS += --disable-dvbapi
endif

define Package/minisatip/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/minisatip $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/share/minisatip/html/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/html/* $(1)/usr/share/minisatip/html
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/minisatip.init $(1)/etc/init.d/minisatip
endef

$(eval $(call BuildPackage,minisatip))
