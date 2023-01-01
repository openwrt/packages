include $(TOPDIR)/rules.mk

PKG_NAME:=libtorrent-rasterbar
PKG_VERSION:=2.0.8
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/arvidn/libtorrent/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=29e5c5395de8126ed1b24d0540a9477fbb158b536021cd65aaf9de34d0aadb46

PKG_MAINTAINER:=David Yang <mmyangfl@gmail.com>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=COPYING

include $(INCLUDE_DIR)/package.mk
include ../../devel/ninja/ninja-cmake.mk

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

define Download/try_signal
	VERSION:=105cce59972f925a33aa6b1c3109e4cd3caf583d
	SUBDIR:=deps/try_signal
	FILE:=$(PKG_NAME)-try_signal-$$(VERSION).tar.xz
	URL:=https://github.com/arvidn/try_signal.git
	MIRROR_HASH:=da81da67d52b7a731c21148573b68bf8dc7863616d6ae1f81845b7afb29e8f00
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
