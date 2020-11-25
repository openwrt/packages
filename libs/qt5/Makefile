include $(TOPDIR)/rules.mk

PKG_NAME:=qt5
PKG_SUBVERSION:=5.15
PKG_VERSION:=$(PKG_SUBVERSION).1
PKG_RELEASE:=1

PKG_SOURCE:=qt-everywhere-src-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:= https://mirrors.tuna.tsinghua.edu.cn/qt/archive/qt/$(PKG_SUBVERSION)/$(PKG_VERSION)/single/ \
		 https://mirrors.ustc.edu.cn/qtproject/archive/qt/$(PKG_SUBVERSION)/$(PKG_VERSION)/single/ \
		 http://download.qt-project.org/archive/qt/$(PKG_SUBVERSION)/$(PKG_VERSION)/single/
PKG_HASH:=44da876057e21e1be42de31facd99be7d5f9f07893e1ea762359bcee0ef64ee9

PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

PKG_BUILD_DIR=$(BUILD_DIR)/qt-everywhere-src-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

ifndef CONFIG_USE_GLIBC

RSTRIP:= \
	NM="$(TOOLCHAIN_DIR)/bin/$(TARGET_CROSS)nm" \
	STRIP="$(STRIP)" \
	STRIP_KMOD="$(STRIP)" \
	$(SCRIPT_DIR)/rstrip.sh
endif

define Package/qt5/Default
	SECTION:=libs
	CATEGORY:=Libraries
	SUBMENU:=Qt5
	TITLE:=qt5
	URL:=http://qt-project.org
	DEPENDS:=+librt +libstdcpp +libpthread @!LINUX_2_6_36
endef

define Package/libQt5Core
	$(call Package/qt5/Default)
	TITLE+=core
	DEPENDS+=+libatomic +libzstd +zlib +libpcre2-16 +libdouble-conversion +icu
endef

define Package/libQt5Network
	$(call Package/qt5/Default)
	TITLE+=network
	DEPENDS+=+libQt5Core +libopenssl
endef

define Package/libQt5Xml
	$(call Package/qt5/Default)
	TITLE+=xml
	DEPENDS+=+libQt5Core
endef

CONFIGURE_ARGS = \
		-prefix /usr \
		-extprefix $(TOOLCHAIN_DIR) \
		-sysroot $(STAGING_DIR) \
		-plugindir /usr/lib/Qt/plugins \
		-R /usr/lib \
		-I $(STAGING_DIR)/usr/include \
		-L $(STAGING_DIR)/usr/lib \
		-xplatform linux-openwrt-g++ \
		-opensource \
		-confirm-license \
		-system-doubleconversion \
		-system-pcre \
		-system-zlib \
		-openssl-runtime \
		-no-cups \
		-no-freetype \
		-no-harfbuzz \
		-no-gtk \
		-no-opengl \
		-no-opengles3 \
		-no-angle \
		-no-openvg \
		-no-dbus \
		-no-directfb \
		-no-eglfs \
		-no-feature-getentropy \
		-no-iconv \
		-no-kms \
		-no-pch \
		-no-libudev \
		-no-mtdev \
		-no-tslib \
		-no-libpng \
		-no-libjpeg \
		-no-sql-db2 \
		-no-sql-ibase \
		-no-sql-mysql \
		-no-sql-oci \
		-no-sql-odbc \
		-no-sql-psql \
		-no-sql-sqlite \
		-no-sql-sqlite2 \
		-no-sqlite \
		-no-sql-tds \
		-no-strip \
		-no-xcb \
		-no-gui \
		-no-widgets \
		-no-glib \
		-make libs \
		-nomake examples \
		-nomake tests \
		-nomake tools \
		-skip 3d \
		-skip activeqt \
		-skip charts \
		-skip connectivity \
		-skip datavis3d \
		-skip declarative \
		-skip doc \
		-skip gamepad \
		-skip imageformats \
		-skip location \
		-skip networkauth \
		-skip multimedia \
		-skip purchasing \
		-skip remoteobjects \
		-skip script \
		-skip sensors \
		-skip serialbus \
		-skip serialport \
		-skip speech \
		-skip svg \
		-skip wayland \
		-skip webengine \
		-skip websockets \
		-skip webchannel \
		-skip xmlpatterns \
		-v \

define Build/Configure
	$(SED) 's@$$$$(TARGET_CROSS)@$(TARGET_CROSS)@g' $(PKG_BUILD_DIR)/qtbase/mkspecs/linux-openwrt-g++/qmake.conf
	$(SED) 's@$$$$(TARGET_CFLAGS)@$(TARGET_CFLAGS)@g' $(PKG_BUILD_DIR)/qtbase/mkspecs/linux-openwrt-g++/qmake.conf
	$(SED) 's@$$$$(TARGET_CXXFLAGS)@$(TARGET_CXXFLAGS)@g' $(PKG_BUILD_DIR)/qtbase/mkspecs/linux-openwrt-g++/qmake.conf
	$(SED) 's@$$$$(TARGET_LDFLAGS)@$(TARGET_LDFLAGS)@g' $(PKG_BUILD_DIR)/qtbase/mkspecs/linux-openwrt-g++/qmake.conf

	$(call Build/Configure/Default)
endef

define Build/Compile
	$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR)
endef

define Build/InstallDev
	$(MAKE) -C $(PKG_BUILD_DIR) install
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/qtbase/bin/qt.conf $(STAGING_DIR)/usr/bin
	$(RM) $(STAGING_DIR)/usr/bin/qt{attributionsscanner,paths,plugininfo}
endef

define Package/libQt5Core/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/qtbase/lib/libQt5Core.so* $(1)/usr/lib/
endef

define Package/libQt5Network/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/qtbase/lib/libQt5Network.so* $(1)/usr/lib/
endef

define Package/libQt5Xml/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/qtbase/lib/libQt5Xml.so* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libQt5Core,+zlib,+libpcre2-16,+libdouble-conversion))
$(eval $(call BuildPackage,libQt5Network))
$(eval $(call BuildPackage,libQt5Xml))
