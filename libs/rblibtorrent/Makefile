
include $(TOPDIR)/rules.mk

PKG_NAME:=rblibtorrent
PKG_VERSION:=1.1.12
PKG_RELEASE:=1
PKG_MAINTAINER:= Sergey Pushilin <pushilin@gmail.com>

PKG_SOURCE:=libtorrent-rasterbar-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/arvidn/libtorrent/releases/download/libtorrent_1_1_12/
PKG_HASH:=a5937134edf3ca8c109403a47f5a5fc93f7b8dca4e97f1a629a8c84288bee7a7
PKG_BUILD_DIR:=$(BUILD_DIR)/libtorrent-rasterbar-$(PKG_VERSION)

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/rblibtorrent
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Rasterbar BitTorrent library
  URL:=http://www.rasterbar.com/products/libtorrent/
  DEPENDS:=+boost +boost-python +boost-filesystem +boost-regex +boost-thread +boost-program_options +boost-system +boost-random +zlib +libopenssl
endef

define Package/rblibtorrent/description
Rasterbar libtorrent is a C++ library that aims to be a good alternative to
all the other bittorrent implementations around. It is a library and not a
full featured client, although it comes with a working example client.
endef

TARGET_CFLAGS +=-I$(STAGING_DIR)/usr/include/python2.7/

CONFIGURE_ARGS+= \
	--enable-shared \
	--disable-debug \
	--enable-python-binding \
	--with-ssl=$(STAGING_DIR)/usr \
	--with-boost=$(STAGING_DIR)/usr/include \
	--with-boost-libdir=$(STAGING_DIR)/usr/lib \
	--with-zlib=detect \
	--with-boost-system \
	--with-boost-filesystem \
	--with-boost-thread \
	--with-boost-regex \
	--with-boost-python \
	--with-boost-program_options

CONFIGURE_VARS+=CC="$(TARGET_CXX)"

EXTRA_LDFLAGS+=-lz -lpthread

define Build/InstallDev
	mkdir -p $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libtorrent $(1)/usr/include/
	mkdir -p $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
	mkdir -p $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libtorrent-rasterbar.pc $(1)/usr/lib/pkgconfig/
endef

define Package/rblibtorrent/install
	$(INSTALL_DIR) $(1)/usr/lib $(1)/usr/lib/python2.7/site-packages/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/python2.7/site-packages/*.so* $(1)/usr/lib/python2.7/site-packages/
endef

$(eval $(call BuildPackage,rblibtorrent))
