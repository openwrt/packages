# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=fltk
PKG_VERSION:=1.3.4
_PKG_VERSION:=2
PKG_RELEASE:=1

PKG_SOURCE_URL:=https://www.fltk.org/pub/fltk/$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(_PKG_VERSION)-source.tar.bz2
PKG_HASH:=8cfe7690d70f9a3db5cd88748a82aa7958a9dc7ec3d7e94eef9063e107864150

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)-$(_PKG_VERSION)
#PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/fltk
  SECTION:=xorg
  CATEGORY:=Xorg
  DEPENDS:=+libx11 +libxfixes +libxrandr +libopenssl +libjpeg-turbo \
	+libxinerama
  TITLE:=A cross-platform C++ GUI toolkit
  URL:=http://www.fltk.org/
endef

TARGET_LDFLAGS += -Wl,--gc-sections,--as-needed

CMAKE_OPTIONS += \
	-DOPTION_BUILD_EXAMPLES=OFF \
	-DOPTION_BUILD_SHARED_LIBS=ON \
	-DOPTION_USE_SYSTEM_LIBPNG=OFF \
	-DOPTION_OPTIM="$(CXXFLAGS)"

define Build/InstallDev
	$(INSTALL_DIR) \
	 $(1)/usr/{include,lib,share} \

	$(CP) \
	 $(PKG_INSTALL_DIR)/usr/{include,lib,share} \
	 $(1)/usr/
endef

$(eval $(call BuildPackage,fltk))
