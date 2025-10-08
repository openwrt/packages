include $(TOPDIR)/rules.mk

PKG_NAME:=libdatachannel
PKG_VERSION:=0.23.2
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_SOURCE_URL=https://github.com/paullouisageneau/libdatachannel.git
PKG_MIRROR_HASH:=7246e54391ecc3835995a7721dac4af7d33ac06895ad539b27c7e5fc1e250ad1

PKG_LICENSE:=MPL-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Biao Zhu <zhumouren0623@qq.com>

PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libdatachannel/config
choice
	prompt "SSL backend for libdatachannel"
	default LIBDATACHANNEL_SSL_OPENSSL

	config LIBDATACHANNEL_SSL_OPENSSL
	bool "OpenSSL"

	config LIBDATACHANNEL_SSL_GNUTLS
	bool "GnuTLS"

	config LIBDATACHANNEL_SSL_MBEDTLS
	bool "MbedTLS"
endchoice
endef

SSL_DEPENDS:=+libopenssl

ifeq ($(CONFIG_LIBDATACHANNEL_SSL_GNUTLS),y)
  SSL_DEPENDS:=+libgnutls
  CMAKE_OPTIONS+= -DUSE_GNUTLS=ON
endif

ifeq ($(CONFIG_LIBDATACHANNEL_SSL_MBEDTLS),y)
  SSL_DEPENDS:=+libmbedtls
  CMAKE_OPTIONS+= -DUSE_MBEDTLS=ON
endif

define Package/libdatachannel
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=libdatachannel
  URL:=https://libdatachannel.org/
  DEPENDS:=+libstdcpp +libsrtp2 $(SSL_DEPENDS)
endef

define Package/libdatachannel/description
 libdatachannel is a standalone implementation of WebRTC Data Channels,
 WebRTC Media Transport, and WebSockets in C++ with C bindings for
 multiple platforms, including GNU/Linux, Android, FreeBSD, Apple macOS,
 iOS, and Microsoft Windows. WebRTC is a W3C and IETF standard enabling
 real-time peer-to-peer data and media exchange between two devices.
endef

CMAKE_OPTIONS+= \
	-DNO_EXAMPLES=ON \
	-DUSE_NICE=0 \
	-DCMAKE_BUILD_TYPE=Release \
	-DUSE_SYSTEM_SRTP=ON

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/rtc $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libdatachannel.so* $(1)/usr/lib/
endef

define Package/libdatachannel/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libdatachannel.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libdatachannel))
