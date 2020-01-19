# Copyright (C) 2019 Eneas Ulir de Queiroz <cotequeiroz@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=afalg_engine
PKG_VERSION:=1.1.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/cotequeiroz/afalg_engine/archive/v$(PKG_VERSION)
PKG_HASH:=0c0304558e9450752656522a8f9036130f4e745c4818f02f92cb8d6c99357ed6

PKG_MAINTAINER:=Eneas U de Queiroz <cotequeiroz@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_CONFIG_DEPENDS:= CONFIG_AFALG_ZERO_COPY

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

ENGINES_DIR:=engines-1.1

define Package/libopenssl-afalg_sync
    SECTION:=libs
    CATEGORY:=Libraries
    SUBMENU:=SSL
    MDEPENDS:=libopenssl
    TITLE:=AF_ALG engine using sync crypto API
    URL:=https://github.com/cotequeiroz/afalg_engine
    DEPENDS:=libopenssl @OPENSSL_ENGINE @!OPENSSL_ENGINE_BUILTIN_AFALG \
	     +libopenssl-conf +kmod-crypto-user
    CONFLICTS:=libopenssl-afalg
endef

define Package/libopenssl-afalg_sync/description
    This is an alternate AF_ALG engine for openssl, based on the devcrypto
    engine, but using the AF_ALG interface instead of /dev/crypto

    It is different than the AF_ALG engine that ships with OpenSSL:
     - it uses sync calls, instead of async
     - it suports more algorithms
endef

define Package/libopenssl-afalg_sync/config
    config AFALG_ZERO_COPY
        depends on PACKAGE_libopenssl-afalg_sync
	bool "Use Zero-Copy Mode"
	help
	    Uses a Zero-Copy interface.  Even though it is supposed to improve
	    performance, actual measurements indicate otherwise.
endef

CMAKE_OPTIONS += \
	-DOPENSSL_ENGINES_DIR=/usr/lib/$(ENGINES_DIR) \
	-DUSE_CRYPTOUSER=OFF \
	-DUSE_ZERO_COPY=$(if $(CONFIG_AFALG_ZERO_COPY),ON,OFF)

define Package/libopenssl-afalg_sync/install
	$(INSTALL_DIR) $(1)/usr/lib/$(ENGINES_DIR)
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/$(ENGINES_DIR)/afalg.so \
			$(1)/usr/lib/$(ENGINES_DIR)/
endef

$(eval $(call BuildPackage,libopenssl-afalg_sync))
