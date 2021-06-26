#
# ported from
#
#
# https://github.com/KryptonLee/qBittorrent-openwrt-package/blob/master/qt5/Makefile
#
# Copyright (C) 2020 Krypton Lee <jun.k.lee199410@outlook.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
#
# https://github.com/pawelkn/qt5-openwrt-package/blob/master/Makefile
#
# Copyright (C) 2013 Riccardo Ferrazzo <f.riccardo87@gmail.com>
# Copyright (C) 2017 Paweł Knioła <pawel.kn@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
#
# https://github.com/Entware/rtndev/blob/master/qt5/Makefile
#
# Copyright (C) 2017-2021 Entware
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
#
# https://github.com/coolsnowwolf/lede/blob/master/package/lean/qtbase/Makefile
#
# Copyright (C) 2020 Openwrt.org
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

include qt.mk

PKG_CONFIG_DEPENDS+= \
	QT_BUILD_RELEASE QT_BUILD_DEBUG \
	QT_OPTIMIZE_SIZE QT_OPTIMIZE_DEBUG QT_OPTIMIZE_TOOLS

ifndef CONFIG_USE_GLIBC
# not using sstrip here as this screw up the .so's somehow
STRIP:=/bin/true
RSTRIP:= \
	NM="$(TOOLCHAIN_DIR)/bin/$(TARGET_CROSS)nm" \
	STRIP="$(STRIP)" \
	STRIP_KMOD="$(STRIP)" \
	$(SCRIPT_DIR)/rstrip.sh
endif

CONFIGURE_ARGS = \
	$(if $(CONFIG_QT_BUILD_RELEASE),-release,) \
	$(if $(CONFIG_QT_BUILD_DEBUG),-debug,) \
	$(if $(CONFIG_QT_OPTIMIZE_SIZE),-optimize-size,) \
	$(if $(CONFIG_QT_OPTIMIZE_DEBUG),-optimize-debug,) \
	$(if $(CONFIG_QT_OPTIMIZE_TOOLS),-optimized-tools,) \
	-sysroot $(STAGING_DIR) \
	-hostprefix $(STAGING_DIR_HOSTPKG) \
	-extprefix $(STAGING_DIR)/usr \
	-prefix /usr \
	-archdatadir /usr/share/Qt \
	-datadir /usr/share/Qt \
	-xplatform linux-openwrt-g++ \
	-confirm-license \
	-opensource \
	-release \
	-shared \
	-strip \
	-no-rpath \
	-no-use-gold-linker \
	-ltcg \
	-mimetype-database \
	-openssl-linked \
	-qt-doubleconversion \
	-system-pcre \
	-system-zlib \
	$(if $(findstring i386,$(ARCH)),-no-sse2 -no-sse4.1) \
	-no-angle \
	-no-cups \
	-no-dbus \
	-no-directfb \
	-no-dtls\
	-no-egl \
	-no-eglfs \
	-no-freetype \
	-no-gbm \
	-no-glib \
	-no-gtk \
	-no-harfbuzz \
	-no-iconv \
	-no-icu \
	-no-kms \
	-no-libjpeg \
	-no-libmd4c \
	-no-libpng \
	-no-libudev \
	-no-mtdev \
	-no-opengles3 \
	-no-openvg \
	-no-pch \
	-no-slog2 \
	-no-sql-db2 \
	-no-sql-ibase \
	-no-sql-mysql \
	-no-sql-oci \
	-no-sql-odbc \
	-no-sql-psql \
	-no-sql-sqlite \
	-no-sql-sqlite2 \
	-no-sql-tds \
	-no-sqlite \
	-no-trace \
	-no-tslib \
	-no-vulkan \
	-no-xcb \
	-no-xkbcommon \
	-no-zstd \
	-no-compile-examples \
	-no-feature-concurrent \
	-no-feature-gssapi \
	-no-feature-sql \
	-no-feature-testlib \
	-make libs \
	-nomake examples \
	-nomake tests \
	-nomake tools \
	-v

define Build/Configure
	$(SED) \
		's@$$$$(TARGET_CROSS)@$(TARGET_CROSS)@g;s@$$$$(TARGET_CFLAGS)@$(TARGET_CFLAGS)@g' \
		$(PKG_BUILD_DIR)/mkspecs/linux-openwrt-g++/qmake.conf
	cd $(PKG_BUILD_DIR) && ./configure $(CONFIGURE_ARGS)
endef

# ar: invalid option -- '.'
define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)
endef

define Package/qt/Default/install
	$(INSTALL_DIR) $(1)/usr/lib
	find $(PKG_BUILD_DIR)/lib -iname libQt5$(2).so.* -exec $(CP) {} $(1)/usr/lib \;
endef

define DefineQtLibrary
  define Package/libqt5$(1)
    $(call Package/qt/Default)
    TITLE:=Qt $(1) Library
    DEPENDS+=$(foreach lib,$(2),+libqt5$(lib)) $(3)
    HIDDEN:=1
  endef

  define Package/libqt5$(1)/description
    This package contains the Qt $(1) library.
  endef

  define Package/libqt5$(1)/install
    $(call Package/qt/Default/install,$$(1),$(1))
  endef
endef
