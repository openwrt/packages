include $(TOPDIR)/rules.mk

PKG_NAME:=libtorrent
#PKG_VERSION:=1.1.13
#PKG_VERSION:=1.2.5
PKG_VERSION:=1.2.7
PKG_RELEASE=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/arvidn/libtorrent.git
#PKG_SOURCE_VERSION:=6f1250c6535730897909240ea0f4f2a81937d21a
#PKG_SOURCE_VERSION:=bc666052c7f77183fd3cade654d8521426f40404
PKG_SOURCE_VERSION:=8e710151c80e655ee0513ca37c367f75a448c6bd

PKG_LICENSE:=BSD
PKG_LICENSE_FILES:=COPYING

PKG_USE_MIPS16:=0
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/libtorrent
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Rasterbar BitTorrent library
  URL:=https://www.libtorrent.org/
  DEPENDS:=+libstdcpp +libopenssl +boost +boost-system +boost-chrono +boost-random
  MAINTAINER:=Arvid Norberg <arvid@libtorrent.org>
endef

define Package/libtorrent/description
Rasterbar libtorrent is a C++ library that aims to be a good alternative to
all the other bittorrent implementations around. It is a library and not a
full featured client, although it comes with a working example client.
endef

TARGET_CFLAGS += $(if $(CONFIG_SOFT_FLOAT),-DBOOST_NO_FENV_H) -fPIC

EXTRA_CXXFLAGS += $(if $(CONFIG_GCC_VERSION_4_8),-std=gnu++11,-std=gnu++14)

TARGET_LDFLAGS += -lstdc++

CONFIGURE_ARGS += \
	--disable-debug \
	--disable-rpath \
	--enable-encryption \
	--enable-deprecated-functions \
	--with-gnu-ld \
	--with-openssl=$(STAGING_DIR)/usr \
	--with-boost=$(STAGING_DIR)/usr \
	--with-libiconv \
	--with-libiconv-prefix=$(ICONV_PREFIX)

define Build/Configure
	cd $(PKG_BUILD_DIR) ; \
		sh autotool.sh
	$(call Build/Configure/Default)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libtorrent $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtorrent-rasterbar.{a,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libtorrent-rasterbar.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libtorrent/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libtorrent-rasterbar.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libtorrent))
