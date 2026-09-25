#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/openssl-module.mk

PKG_NAME:=libopenssl-oqsprovider
PKG_VERSION:=0.10.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/open-quantum-safe/oqs-provider.git
PKG_SOURCE_VERSION:=f076e91faab88871ff1973db0287cc6e4b94c4b0
PKG_MIRROR_HASH:=cf8fcc4b1cd8fc914bc7948c35666769d5f4a1ca40a36c049f116d6e216b3f82

PKG_MAINTAINER:=Christian Marangi <ansuelsmth@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE.txt

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

$(eval $(call Package/openssl/add-provider,oqsprovider))
define Package/libopenssl-oqsprovider
  $(call Package/openssl/module/Default)
  TITLE:=Open Quantum Safe provider for OpenSSL (3.x)
  DEPENDS:=+libopenssl +liboqs
  URL:=https://openquantumsafe.org/
endef

define Package/libopenssl-oqsprovider/description
  This enable quantum-safe cryptography (QSC) in a standard OpenSSL (3.x)
  distribution by way of implementing a single shared library, the
  OQS provider.
endef

CMAKE_OPTIONS += \
	-DBUILD_SHARED_LIBS=ON \
	-DBUILD_TESTING=OFF \
	-DOPENSSL_MODULES_PATH=/usr/lib/$(MODULES_DIR)

$(eval $(call BuildPackage,libopenssl-oqsprovider))
