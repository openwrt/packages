include $(TOPDIR)/rules.mk

PKG_NAME:=libtorrent-rasterbar
PKG_VERSION:=2.0.9
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/arvidn/libtorrent/releases/download/v$(PKG_VERSION)/
PKG_HASH:=90cd92b6061c5b664840c3d5e151d43fedb24f5b2b24e14425ffbb884ef1798e

PKG_MAINTAINER:=David Yang <mmyangfl@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/libtorrent-rasterbar/Default
	TITLE:=Rasterbar BitTorrent library
	URL:=https://libtorrent.org/
endef

define Package/libtorrent-rasterbar
	$(call Package/libtorrent-rasterbar/Default)
	SECTION:=libs
	CATEGORY:=Libraries
	DEPENDS:=+boost-system +libopenssl +libatomic +libstdcpp
endef

#define Package/python3-libtorrent
#	$(call Package/libtorrent-rasterbar/Default)
#	SECTION:=lang
#	CATEGORY:=Languages
#	SUBMENU:=Python
#	TITLE+= (Python 3)
#	DEPENDS:=+libtorrent-rasterbar +boost-python
#endef

define Package/libtorrent-rasterbar/description
	Rasterbar libtorrent is a C++ library that aims to be a good alternative to
	all the other bittorrent implementations around.
endef

#define Package/python3-libtorrent/description
#	$(call Package/libtorrent-rasterbar/description)
#	This package contains Python 3 bindings for the libtorrent-rasterbar library.
#endef

#CMAKE_OPTIONS += \
#	-Dpython-bindings=ON \
#	-Dpython-egg-info=ON

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libtorrent $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtorrent-rasterbar.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libtorrent-rasterbar.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libtorrent-rasterbar/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtorrent-rasterbar.so.* $(1)/usr/lib/
endef

#define Package/python3-libtorrent/install
#	$(INSTALL_DIR) $(1)/usr/lib/python2.7/site-packages
#	$(CP) $(PKG_INSTALL_DIR)/usr/lib/python2.7/site-packages/*.so* $(1)/usr/lib/python2.7/site-packages/
#endef

$(eval $(call BuildPackage,libtorrent-rasterbar))
#$(eval $(call BuildPackage,python3-libtorrent))
