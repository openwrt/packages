#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=hyperscan
PKG_VERSION:=5.4.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/intel/hyperscan/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=32b0f24b3113bbc46b6bfaa05cf7cf45840b6b59333d078cc1f624e4c40b2b99

PKG_MAINTAINER:=John Audia <therealgraysky@proton.me>
PKG_LICENSE:=BSD-3-Clause BSD-2-Clause BSL-1.0
PKG_LICENSE_FILES:=LICENSE
PKG_BUILD_DEPENDS:=ragel/host python3/host boost/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

# A minimum of SSSE3 support is required to use hyperscan
# We need to define the C(XX)FLAGS to avoid -march=native being
# used as this is hardcoded by upstream, see:
# https://github.com/intel/hyperscan/blob/master/doc/dev-reference/getting_started.rst
CMAKE_OPTIONS += \
	-DCMAKE_INSTALL_PREFIX=/usr \
	-DCMAKE_INSTALL_LIBDIR=lib \
	-DBUILD_SHARED_LIBS=ON \
	-DCMAKE_C_FLAGS="-march=x86-64-v2" \
	-DCMAKE_CXX_FLAGS="-march=x86-64-v2" \
	-Wno-dev

define Package/hyperscan-headers
  CATEGORY:=Libraries
  SECTION:=libs
  TITLE:=Hyperscan Headers
  URL:=https://github.com/intel/hyperscan
  DEPENDS:=@TARGET_x86_64
endef

define Package/hyperscan-runtime
  CATEGORY:=Libraries
  SECTION:=libs
  TITLE:=Hyperscan Runtime
  URL:=https://github.com/intel/hyperscan
  DEPENDS:=@TARGET_x86_64 +libstdcpp
endef

define Package/hyperscan-headers/description
  This package contains the headers for Hyperscan.
endef

define Package/hyperscan-runtime/description
  This package contains the shared objects for Hyperscan.
endef

# This installs files into ./staging_dir/. so that you can cross compile from the host
define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/hs
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/hs/* $(1)/usr/include/hs/
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libhs* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/libhs.pc $(1)/usr/lib/pkgconfig/libhs.pc
endef

# These install files on the target.  Compare with Build/InstallDev
define Package/hyperscan-headers/install
	$(INSTALL_DIR) $(1)/usr/include/hs
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/include/hs/*.h $(1)/usr/include/hs/
endef

define Package/hyperscan-runtime/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libhs* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,hyperscan-headers))
$(eval $(call BuildPackage,hyperscan-runtime))
