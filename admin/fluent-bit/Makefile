include $(TOPDIR)/rules.mk

PKG_NAME:=fluent-bit
PKG_VERSION:=5.0.8
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/fluent/fluent-bit.git
PKG_SOURCE_VERSION=v$(PKG_VERSION)
PKG_MIRROR_HASH:=e512206f301abee2f326a62faeaae258d1a2b3a5d698d6c4dc45909d0a9e0dca

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:treasuredata:fluent_bit

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/fluent-bit
  SECTION:=admin
  CATEGORY:=Administration
  TITLE:=Fast and Lightweight Logs and Metrics processor
  URL:=https://fluentbit.io/
  DEPENDS:= +libyaml +libopenssl +libcurl +libstdcpp +libatomic +USE_MUSL:musl-fts +flex +bison \
	    +libsasl2
endef

define Package/fluent-bit/description
  Fluent Bit is a super fast, lightweight, and highly scalable logging
  and metrics processor and forwarder.
endef

define Package/fluent-bit/conffiles
/etc/fluent-bit/parsers.conf
endef

TARGET_LDFLAGS += $(if $(CONFIG_USE_MUSL),-lfts) -latomic

# Force native __thread TLS: GCC 14 makes upstream's C-TLS probe fail (undeclared
# __tls_get_addr), and its pthread_key fallback segfaults on musl at startup.
CMAKE_OPTIONS+= \
	-DFLB_RELEASE=Yes \
	-DEXCLUDE_FROM_ALL=true \
	-DFLB_EXAMPLES=No \
	-DFLB_CHUNK_TRACE=No \
	-DFLB_BACKTRACE=No \
	-DFLB_WASM=No \
	-DFLB_LUAJIT=No \
	-DFLB_CORO_STACK_SIZE=4096 \
	-DWITH_SASL=No \
	-DWITH_ZLIB=No \
	-DWITH_ZSTD=No \
	-DFLB_HAVE_C_TLS=Yes

define Package/fluent-bit/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/fluent-bit $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/etc/fluent-bit
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/parsers.conf $(1)/etc/fluent-bit/parsers.conf
endef

$(eval $(call BuildPackage,fluent-bit))
