include $(TOPDIR)/rules.mk

PKG_NAME:=libtorrent-rasterbar
PKG_VERSION:=2.0.11
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/arvidn/libtorrent/releases/download/v$(PKG_VERSION)/
PKG_HASH:=f0db58580f4f29ade6cc40fa4ba80e2c9a70c90265cd77332d3cdec37ecf1e6d

PKG_MAINTAINER:=David Yang <mmyangfl@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_DEPENDS:=boost
PKG_CONFIG_DEPENDS:=CONFIG_PACKAGE_python3-libtorrent

CMAKE_INSTALL:=1
PYTHON3_PKG_BUILD:=0
PYTHON3_PKG_WHEEL_NAME:=libtorrent

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk
include ../../lang/python/python3-package.mk

define Package/libtorrent-rasterbar/Default
  TITLE:=Rasterbar BitTorrent library
  URL:=https://libtorrent.org/
endef

define Package/libtorrent-rasterbar
  $(call Package/libtorrent-rasterbar/Default)
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+libopenssl +libatomic +libstdcpp
endef

define Package/python3-libtorrent
  $(call Package/libtorrent-rasterbar/Default)
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE+= (Python 3)
  DEPENDS:=+libtorrent-rasterbar +boost-python3
endef

define Package/libtorrent-rasterbar/description
  Rasterbar libtorrent is a C++ library that aims to be a good alternative to
  all the other bittorrent implementations around.
endef

define Package/python3-libtorrent/description
  $(call Package/libtorrent-rasterbar/description)
  This package contains Python 3 bindings for the libtorrent-rasterbar library.
endef

ifneq ($(CONFIG_PACKAGE_python3-libtorrent),)
CMAKE_OPTIONS += \
	-Dpython-bindings=ON \
	-Dpython-egg-info=ON
endif

define Build/Configure
	$(call Build/Configure/Default)
ifneq ($(CONFIG_PACKAGE_python3-libtorrent),)
	$(call Py3Build/Configure)
endif
endef

define Build/Compile
	$(call Build/Compile/Default)
ifneq ($(CONFIG_PACKAGE_python3-libtorrent),)
	$(call Py3Build/Compile)
endif
endef

define Build/Install
	$(call Build/Install/Default)
ifneq ($(CONFIG_PACKAGE_python3-libtorrent),)
	$(call Py3Build/Install/Default)
endif
endef

define Package/libtorrent-rasterbar/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtorrent-rasterbar.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libtorrent-rasterbar))
$(eval $(call Py3Package,python3-libtorrent))
$(eval $(call BuildPackage,python3-libtorrent))
