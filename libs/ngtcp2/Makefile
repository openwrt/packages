include $(TOPDIR)/rules.mk

PKG_NAME:=ngtcp2
PKG_VERSION:=1.1.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/ngtcp2/ngtcp2/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=987d784643edea4f2859c405f7dfbc53871a9f7ae5fcddf5fb12ec5dfce1ef22

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYING
PKG_MAINTAINER:=Stan Grishin <stangri@melmac.ca>

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libngtcp2
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Implementation of QUIC protocol
  URL:=https://nghttp2.org/ngtcp2
  DEPENDS:=+libnghttp3 +libopenssl
endef

define Package/libngtcp2/description
ngtcp2 project is an effort to implement QUIC protocol which is now being
discussed in IETF QUICWG for its standardization.
endef

CMAKE_OPTIONS += -DENABLE_LIB_ONLY=ON

define Package/libngtcp2/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libngtcp2*.so* $(1)/usr/lib
endef

$(eval $(call BuildPackage,libngtcp2))
