include $(TOPDIR)/rules.mk

PKG_NAME:=libfizz
PKG_VERSION:=2019.07.22.00
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/facebookincubator/fizz
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=aa46793a4983d4d4c49ff86b4b0cb9b2bcac50d59fbc9744982a726966aa1596

PKG_MAINTAINER:=Amol Bhave <ambhave@fb.com>
PKG_LICENSE:=BSD
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1
CMAKE_SOURCE_SUBDIR:=fizz
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libfizz
	SECTION:=libs
	CATEGORY:=Libraries
	DEPENDS:=+libfolly
	TITLE:=C++14 implementation of the TLS-1.3 standard
	URL:=https://github.com/facebookincubator/fizz
endef

define Package/libfizz/description
	C++14 implementation of the TLS-1.3 standard.
	Fizz currently supports TLS 1.3 drafts 28, 26 (both wire-compatible with the final specification), and 23.
endef

CMAKE_OPTIONS += \
	-DBUILD_EXAMPLES=OFF \
	-DBUILD_SHARED_LIBS=ON

define Package/libfizz/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libfizz.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libfizz))
