include $(TOPDIR)/rules.mk

PKG_NAME:=zstd
PKG_VERSION:=1.3.4
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/facebook/zstd/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=92e41b6e8dd26bbd46248e8aa1d86f1551bc221a796277ae9362954f26d605a9
PKG_MAINTAINER:=Rosen Penev <rosenp@gmail.com>

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libzstd
  SECTION:=libs
  CATEGORY:=Libraries
  SUBMENU:=Compression
  TITLE:=ZSTD Compression Library
  URL:=https://github.com/facebook/zstd
endef

define Package/zstd
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Compression
  DEPENDS:=+libzstd +liblzma +zlib
  TITLE:=ZSTD Compression Tool
  URL:=https://github.com/facebook/zstd
endef

define Package/libzstd/description
	libzstd is a library containing the ZSTD compression algorithm which combines LZ4
	with the FSE entropy coder.
endef

define Package/zstd/description
	ZSTD is a tool to generate compressed files using the ZSTD compression algorithm.
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/local/include/* $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/local/lib/libzstd.{a,so*} $(1)/usr/lib/
endef

define Package/libzstd/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/local/lib/libzstd.so* $(1)/usr/lib
endef

define Package/zstd/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/local/bin/zstd $(1)/usr/bin
endef

$(eval $(call BuildPackage,libzstd))
$(eval $(call BuildPackage,zstd))
