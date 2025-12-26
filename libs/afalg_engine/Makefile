# Copyright (C) 2019 Eneas Ulir de Queiroz <cotequeiroz@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=afalg_engine
PKG_VERSION:=1.2.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/cotequeiroz/afalg_engine/archive/v$(PKG_VERSION)
PKG_HASH:=6fe451cf37b0c9911445e46bfe96926aad5dc486c9cb81ecf7b87bb3ffff1c1a

PKG_MAINTAINER:=Eneas U de Queiroz <cotequeiroz@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_CONFIG_DEPENDS:= \
	CONFIG_AFALG_DIGESTS \
	CONFIG_AFALG_FALLBACK \
	CONFIG_AFALG_UPDATE_CTR_IV \
	CONFIG_AFALG_ZERO_COPY

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk
include $(INCLUDE_DIR)/openssl-module.mk

TARGET_CFLAGS += -Wno-deprecated-declarations

$(eval $(call Package/openssl/add-engine,afalg,libopenssl-afalg_sync))
define Package/libopenssl-afalg_sync
    $(call Package/openssl/engine/Default)
    TITLE:=AF_ALG engine using sync crypto API
    URL:=https://github.com/cotequeiroz/afalg_engine
    DEPENDS += @!OPENSSL_ENGINE_BUILTIN_AFALG +kmod-crypto-user
    CONFLICTS:=libopenssl-afalg
    MENU:=1
endef

define Package/libopenssl-afalg_sync/description
    This is an alternate AF_ALG engine for openssl, based on the devcrypto
    engine, but using the AF_ALG interface instead of /dev/crypto

    It is different than the AF_ALG engine that ships with OpenSSL:
     - it is faster
     - it uses sync calls, instead of async
     - it supports more algorithms
endef

define Package/libopenssl-afalg_sync/config
    source "$(SOURCE)/Config.in"
endef

CMAKE_OPTIONS += \
	-DOPENSSL_ENGINES_DIR=/usr/lib/$(ENGINES_DIR) \
	-DDIGESTS=$(if $(CONFIG_AFALG_DIGESTS),ON,OFF) \
	-DUPDATE_CTR_IV=$(if $(CONFIG_AFALG_UPDATE_CTR_IV),ON,OFF) \
	-DUSE_ZERO_COPY=$(if $(CONFIG_AFALG_ZERO_COPY),ON,OFF)

$(eval $(call BuildPackage,libopenssl-afalg_sync))
