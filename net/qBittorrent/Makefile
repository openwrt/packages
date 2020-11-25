#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=qBittorrent
PKG_VERSION:=4.2.5
PKG_RELEASE=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/qbittorrent/qBittorrent.git
PKG_SOURCE_VERSION:=2c65b796401f924d6889aadde958de3d2846bb4b

PKG_LICENSE:=GPL-2.0+
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk

define Package/qBittorrent
  SUBMENU:=BitTorrent
  SECTION:=net
  CATEGORY:=Network
  TITLE:=BitTorrent Client Programmed in C++ / Qt
  URL:=https://www.qbittorrent.org/
  DEPENDS:=+libQt5Core +libQt5Network +libQt5Xml +libtorrent
endef

define Package/qBittorrent/description
qBittorrent is a bittorrent client programmed in C++ / Qt that uses 
libtorrent (sometimes called libtorrent-rasterbar) by Arvid Norberg.
It aims to be a good alternative to all other bittorrent clients out 
there. qBittorrent is fast, stable and provides unicode support as 
well as many features.
endef

CONFIGURE_VARS += \
  	QT_QMAKE="$(TOOLCHAIN_DIR)/bin" \
	PKG_CONFIG_PATH="$(TOOLCHAIN_DIR)/lib/pkgconfig"

CONFIGURE_ARGS += \
	--disable-gui \
	--enable-stacktrace=no \
	--with-boost="$(STAGING_DIR)/usr"

MAKE_VARS += \
	INSTALL_ROOT="$(PKG_INSTALL_DIR)"

define Build/Prepare
	$(call Build/Prepare/Default)
	$(SED) '/<context>/{:a;N;/<\/context>/!ba;/\/gui\//d}' `ls $(PKG_BUILD_DIR)/src/lang/qbittorrent_*.ts`
endef

define Build/Compile
	#$(STAGING_DIR_HOST)/bin/upx --lzma --best $(PKG_BUILD_DIR)/src/qbittorrent-nox
endef

define Package/qBittorrent/install
	$(INSTALL_DIR) $(1)/usr/man/man1
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/man/man1/qbittorrent-nox.1 $(1)/usr/man/man1/qbittorrent-nox.1
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/qbittorrent-nox $(1)/usr/bin
endef

$(eval $(call BuildPackage,qBittorrent))
