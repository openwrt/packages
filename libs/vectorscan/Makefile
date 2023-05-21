#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=vectorscan
PKG_VERSION:=5.4.9
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/VectorCamp/vectorscan/tar.gz/$(PKG_NAME)/$(PKG_VERSION)?
PKG_HASH:=e61c78f26a9d04ccffab0df1159885c4503fc501172402c57f7357a2126ea3c6
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=John Audia <therealgraysky@proton.me>
PKG_LICENSE:=BSD-3-Clause BSD-2-Clause BSL-1.0
PKG_LICENSE_FILES:=LICENSE
PKG_BUILD_PARALLEL:=1
CMAKE_INSTALL:=1

PKG_BUILD_DEPENDS:=ragel/host python3/host boost/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS += \
	-DCMAKE_INSTALL_LIBDIR=lib \
	-DBUILD_SHARED_LIBS=ON \
	-Wno-dev

define Package/vectorscan-headers
  CATEGORY:=Libraries
  SECTION:=libs
  TITLE:=Vectorscan Headers
  URL:=https://github.com/VectorCamp/vectorscan
  DEPENDS:=@(aarch64||arm||i386||i686||x86_64)
endef

define Package/vectorscan-runtime
  CATEGORY:=Libraries
  SECTION:=libs
  TITLE:=Vectorscan Runtime
  URL:=https://github.com/VectorCamp/vectorscan
  DEPENDS:=@(aarch64||arm||i386||i686||x86_64)
endef

define Package/vectorscan-headers/description
  This package contains the headers for Vectorscan.
  A fork of Intel's Hyperscan, modified to run on more platforms.
endef

define Package/vectorscan-runtime/description
  This package contains the shared objects for Vectorscan.
  A fork of Intel's Hyperscan, modified to run on more platforms.
endef

define Package/vectorscan-runtime/install
endef

# This installs files into ./staging_dir/. so that you can cross compile from the host
define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/hs
	$(CP) $(PKG_INSTALL_DIR)/usr/include/hs* $(1)/usr/include/hs/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libhs.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) \
		$(PKG_BUILD_DIR)/usr/lib/pkgconfig/libhs.pc $(1)/usr/lib/pkgconfig/libhs.pc
endef

# This installs files on the target.  Compare with Build/InstallDev
define Package/vectorscan-headers/install
	$(INSTALL_DIR) $(1)/usr/include/hs
	$(CP) $(PKG_INSTALL_DIR)/usr/include/hs* $(1)/usr/include/hs/
endef

define Package/vectorscan-runtime/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libhs.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,vectorscan-headers))
$(eval $(call BuildPackage,vectorscan-runtime))
