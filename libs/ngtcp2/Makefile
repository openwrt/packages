include $(TOPDIR)/rules.mk

PKG_NAME:=ngtcp2
PKG_VERSION:=1.15.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/ngtcp2/ngtcp2/releases/download/v$(PKG_VERSION)/
PKG_HASH:=30a29827b49ffbdf31dadcdeba703df63676526c93724ef741c72dc73c05e3a4

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libngtcp2/config
  if PACKAGE_libngtcp2
    choice
      prompt "QUIC crypto backend"
      default NGTCP2_CRYPTO_WOLFSSL

    config NGTCP2_CRYPTO_WOLFSSL
      bool "wolfSSL (recommended for OpenWrt)"
      depends on PACKAGE_libwolfssl

    config NGTCP2_CRYPTO_OPENSSL
      bool "OpenSSL"

    endchoice
  endif
endef

define Package/libngtcp2
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Implementation of QUIC protocol
  URL:=https://nghttp2.org/ngtcp2
  DEPENDS:=+NGTCP2_CRYPTO_WOLFSSL:libwolfssl +NGTCP2_CRYPTO_OPENSSL:libopenssl
endef

define Package/libngtcp2/description
ngtcp2 project is an effort to implement IETF QUIC protocol.
Default crypto backend is wolfSSL (native QUIC support).
endef

CMAKE_OPTIONS += -DENABLE_LIB_ONLY=ON \
  -DENABLE_WOLFSSL=$(if $(CONFIG_NGTCP2_CRYPTO_WOLFSSL),ON,OFF) \
  -DENABLE_OPENSSL=$(if $(CONFIG_NGTCP2_CRYPTO_OPENSSL),ON,OFF)

define Build/InstallDev
	$(call Build/InstallDev/cmake,$(1))
	$(SED) 's,/usr/include,$$$${prefix}/include,g' $(1)/usr/lib/pkgconfig/libngtcp2.pc
	$(SED) 's,/usr/lib,$$$${exec_prefix}/lib,g' $(1)/usr/lib/pkgconfig/libngtcp2.pc
	[ -f $(1)/usr/lib/pkgconfig/libngtcp2_crypto_wolfssl.pc ] && \
	  $(SED) 's,/usr/include,$$$${prefix}/include,g' $(1)/usr/lib/pkgconfig/libngtcp2_crypto_wolfssl.pc && \
	  $(SED) 's,/usr/lib,$$$${exec_prefix}/lib,g' $(1)/usr/lib/pkgconfig/libngtcp2_crypto_wolfssl.pc || true
	[ -f $(1)/usr/lib/pkgconfig/libngtcp2_crypto_ossl.pc ] && \
	  $(SED) 's,/usr/include,$$$${prefix}/include,g' $(1)/usr/lib/pkgconfig/libngtcp2_crypto_ossl.pc && \
	  $(SED) 's,/usr/lib,$$$${exec_prefix}/lib,g' $(1)/usr/lib/pkgconfig/libngtcp2_crypto_ossl.pc || true
endef

define Package/libngtcp2/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libngtcp2*.so* $(1)/usr/lib
endef

$(eval $(call BuildPackage,libngtcp2))
