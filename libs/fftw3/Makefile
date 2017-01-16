#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=fftw3
PKG_VERSION:=3.3.6
PKG_RELEASE:=1
PKG_LICENSE:=GPL-2.0+

PKG_SOURCE:=fftw-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.fftw.org
PKG_MD5SUM:=ccd91b5b12bd0a441e100070ff09a310

PKG_BUILD_DIR=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/fftw-$(PKG_VERSION)
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/fftw3
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=@!avr32 +libpthread
  VARIANT:=double
  TITLE:=Fast Fourier transform library
  URL:=http://www.fftw.org/
  MAINTAINER:=Vladimir Ulrich <admin@evl.su>
endef

define Package/fftw3f
  $(call Package/fftw3)
  VARIANT:=single
  TITLE+= (single precision)
endef

define Package/fftw3l
  $(call Package/fftw3)
  DEPENDS:=@BROKEN
  VARIANT:=long-double
  TITLE+= (long-double precision)
endef

define Package/fftw3/description
	FFTW is a collection of fast C routines for computing the
	Discrete Fourier Transform in one or more dimensions. It
	includes complex, real, and parallel transforms, and can
	handle arbitrary array sizes efficiently.
endef

define Package/fftw3f/description
  $(call Package/fftw3/description)

  This package contains the single precision library.
endef

define Package/fftw3l/description
  $(call Package/fftw3/description)

  This package contains the long-double precision library.
endef

TARGET_CFLAGS += $(FPIC)

CONFIGURE_ARGS += \
	--prefix=/usr \
	--without-libiconv-prefix \
	--without-libintl-prefix \
	--enable-shared \
	--enable-threads \
	--enable-type-prefix \
	--disable-debug \
	--disable-fortran

ifeq ($(BUILD_VARIANT), single)
CONFIGURE_ARGS += \
	--enable-single
endif

ifeq ($(BUILD_VARIANT), long-double)
CONFIGURE_ARGS += \
	--enable-long-double
endif

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) DESTDIR="$(PKG_INSTALL_DIR)" install
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/fftw3.h $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libfftw3*.{a,la} $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libfftw3*.so* $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/* $(1)/usr/lib/pkgconfig/
endef

define Package/fftw3/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libfftw3.so* $(1)/usr/lib/
endef

define Package/fftw3f/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libfftw3f.so* $(1)/usr/lib/
endef

define Package/fftw3l/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libfftw3l.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,fftw3))
$(eval $(call BuildPackage,fftw3f))
$(eval $(call BuildPackage,fftw3l))
