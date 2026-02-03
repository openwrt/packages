include $(TOPDIR)/rules.mk

PKG_NAME:=fluent-bit
PKG_VERSION:=4.2.0
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/fluent/fluent-bit.git
PKG_SOURCE_VERSION=v$(PKG_VERSION)
PKG_MIRROR_HASH:=cad2d94cf7a720a3910c781f80187e2c399aa8acbfa1046aa7445a4d1495fafd

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/fluent-bit
  SECTION:=admin
  CATEGORY:=Administration
  TITLE:=Fast and Lightweight Logs and Metrics processor
  URL:=https://fluentbit.io/
  DEPENDS:= +libyaml +libopenssl +libcurl +libstdcpp +libatomic +musl-fts +flex +bison \
	    +libsasl2
endef

define Package/fluent-bit/description
  Fluent Bit is a super fast, lightweight, and highly scalable logging
  and metrics processor and forwarder.
endef

define Package/fluent-bit/conffiles
/etc/fluent-bit/parsers.conf
endef

TARGET_LDFLAGS +=-lfts -latomic

CMAKE_OPTIONS+= \
	-DFLB_RELEASE=Yes \
	-DEXCLUDE_FROM_ALL=true \
	-DFLB_EXAMPLES=No \
	-DFLB_CHUNK_TRACE=No \
	-DFLB_BACKTRACE=No \
	-DFLB_WASM=No \
	-DFLB_LUAJIT=No \
	-DWITH_SASL=No \
	-DWITH_ZLIB=No \
	-DWITH_ZSTD=No

define Package/fluent-bit/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/fluent-bit $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/etc/fluent-bit
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/conf/parsers.conf $(1)/etc/fluent-bit/parsers.conf
endef

$(eval $(call BuildPackage,fluent-bit))
