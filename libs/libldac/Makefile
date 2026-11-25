include $(TOPDIR)/rules.mk

PKG_NAME:=libldac
PKG_VERSION:=2.0.2.6
PKG_RELEASE:=1

# ldacBT: CMake build of Sony's LDAC codec library from AOSP (libldac), as
# also packaged by Debian. Its release tarball includes libldac. Encoder +
# ABR only - there is no open-source decoder.
PKG_SOURCE:=ldacBT-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/EHfive/ldacBT/releases/download/v$(PKG_VERSION)
PKG_HASH:=fee05740e86ee66f4540486d92683ee8e8071119907b57ca762c7e5d943ecef0

PKG_MAINTAINER:=Mirko Vogt <mirko-openwrt@nanl.de>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE libldac/LICENSE libldac/NOTICE

PKG_BUILD_PARALLEL:=1
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

# the release tarball has no top-level directory
TAR_CMD=$(HOST_TAR) -C $(1) $(TAR_OPTIONS)

# LDAC_SOFT_FLOAT selects libldac's fixed-point implementation, for targets
# without an FPU
CMAKE_OPTIONS += \
	-DLDAC_SOFT_FLOAT=$(if $(CONFIG_SOFT_FLOAT),ON,OFF)

define Package/libldac
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=LDAC Bluetooth audio codec (encoder + ABR)
  URL:=https://github.com/EHfive/ldacBT
  # the PCM input conversion of libldac implements little-endian only
  # (#error unsupported byte order)
  DEPENDS:=@!BIG_ENDIAN
  ABI_VERSION:=2
endef

define Package/libldac/description
  Sony's LDAC audio codec for Bluetooth A2DP streaming at up to 990 kbps:
  the encoder (libldacBT_enc) and the adaptive bitrate module
  (libldacBT_abr), as used by the bluez5 plugin of PipeWire. Encoder only;
  there is no open-source LDAC decoder.
endef

# The default cmake InstallDev copy, plus .pc normalization: upstream writes
# libdir/includedir as absolute literals (/usr/include/ldac), which OpenWrt's
# pkg-config wrapper cannot remap (it only redefines ${prefix}); consumers then
# get host -I paths and fail with "ldacBT.h: No such file or directory".
define Build/InstallDev
	$(INSTALL_DIR) $(1)
	$(CP) $(PKG_INSTALL_DIR)/* $(1)/
	$(SED) 's,^libdir=.*,libdir=$$$${exec_prefix}/lib,; s,^includedir=.*,includedir=$$$${prefix}/include/ldac,' \
		$(1)/usr/lib/pkgconfig/ldacBT-enc.pc $(1)/usr/lib/pkgconfig/ldacBT-abr.pc
endef

define Package/libldac/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libldacBT_enc.so.* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libldacBT_abr.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libldac))
