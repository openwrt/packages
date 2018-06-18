
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sslsplit
PKG_VERSION:=0.5.2
PKG_RELEASE:=1
PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=LICENSE LICENSE.contrib LICENSE.third

PKG_SOURCE:=sslsplit-0.5.2.tar.bz2
PKG_SOURCE_URL:=https://mirror.roe.ch/rel/sslsplit/
PKG_HASH:=f32c7fd760a45bb521adb8d96c819173fcaed1964bf114e666fcd7cf7ff043a8

PKG_INSTALL:=1

PKG_MAINTAINER:=Awais Chishti <chishtiawais511@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/sslsplit
  SECTION:=net
  CATEGORY:=Network
  DEPENDS:=+libevent2 +libopenssl +libevent2-openssl +libevent2-pthreads +USE_MUSL:musl-fts
  TITLE:=Transparent SSL/TLS interception
  URL:=https://www.roe.ch/SSLsplit
endef

define Package/sslsplit/description
  Transparent SSL/TLS interception
endef

MAKE_FLAGS += prefix=/usr \
	OSNAME=Linux

define Package/sslsplit/install
	$(INSTALL_DIR) $(1)/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/local/bin/sslsplit $(1)/bin/
endef

$(eval $(call BuildPackage,sslsplit))

