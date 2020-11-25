include $(TOPDIR)/rules.mk

PKG_NAME:=libtorrent-rasterbar
PKG_VERSION:=2.0.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/arvidn/libtorrent/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=cf906167e0b332681f6304a9bb740404a53bb0efed39897e1d2bd0f6f0d9e9cd

PKG_MAINTAINER:=David Yang <mmyangfl@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

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
	DEPENDS:=+boost-system +libopenssl
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

define Download/try_signal
	VERSION:=2a99893f92b29a5948569cba1e16fd259dbc2016
	SUBDIR:=deps/try_signal
	FILE:=$(PKG_NAME)-try_signal-$$(VERSION).tar.xz
	URL:=https://github.com/arvidn/try_signal.git
	MIRROR_HASH:=4dee408897de3475e6f7eca9c4e4617c3e746351d01cec3cccac38b9b4d38302
	PROTO:=git
endef
$(eval $(call Download,try_signal))

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Build/Prepare
	$(Build/Prepare/Default)
	$(eval $(Download/try_signal))
	xzcat $(DL_DIR)/$(FILE) | tar -C $(PKG_BUILD_DIR) $(TAR_OPTIONS)
endef

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
