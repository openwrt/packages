#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=minisatip
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/catalinii/minisatip.git
PKG_SOURCE_VERSION:=b9fcb51b207f3b26b32b9b7c0e633cffea82274d
PKG_SOURCE_DATE:=2019-07-08
PKG_MIRROR_HASH:=1857595acb8216c078b1c4a355f7559cfce4dff22464a5b31c7712be6b374534

PKG_MAINTAINER:=Daniel Kucera <github@danman.eu>
PKG_LICENSE:=GPL-2.0-or-later

include $(INCLUDE_DIR)/package.mk

define Package/minisatip
  TITLE:=SATIP server
  URL:=https://github.com/catalinii/minisatip
  SECTION:=multimedia
  CATEGORY:=Multimedia
  DEPENDS:=+MINISATIP_AES:libopenssl
endef

define Package/minisatip/config
	if PACKAGE_minisatip

		config MINISATIP_AES
			bool "OpenSSL (AES as part of DVBAPI)"
			default n

		config MINISATIP_CLIENT
			bool "SatIP Client"
			default y

	endif
endef

ifeq ($(CONFIG_MINISATIP_AES),)
	CONFIGURE_ARGS += --disable-dvbaes
endif

ifeq ($(CONFIG_MINISATIP_CLIENT),)
	CONFIGURE_ARGS += --disable-satipc
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
