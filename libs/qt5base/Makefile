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
#
# https://github.com/openwrt/video/blob/master/frameworks/qt5base/Makefile
#
# Copyright (C) 2020 OpenWrt.org
# Author: Mirko Vogt <mirko-openwrt@nanl.de>
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

PKG_NAME:=qt5base
QT_NAME:=qtbase
PKG_HASH:=909fad2591ee367993a75d7e2ea50ad4db332f05e1c38dd7a5a274e156a4e0f8

include qtlib.mk

PKG_MAINTAINER:=David Yang <mmyangfl@gmail.com>
PKG_CPE_ID:=cpe:/a:qt:qt

# Yes, the host build depends on the target build. This is not a mistake!
# The target build provides the (target specific) qmake.mk file which
# is also used for host builds.
# Host projects depend on qt5base/host which however don't build
# if qt5base didn't install the qmake.mk file before.
# Benefit of the target build providing qmake.mk instead of the host build
# is that the host build really only needs to be built, if there're targets
# which actually depend on it. At the time of this writing, only qt5tools
# makes use of the host build.
HOST_BUILD_DEPENDS:=qt5base

define Package/qt5base
	$(call Package/qt5/Default)
	TITLE:=Qt Base Module
endef

define Package/qt5base/description
$(call Package/qt5/Default/description)

The Qt Base module offers classes for embedded Linux devices. The Base
module is based on Qt and builds the foundation for all other modules of
Qt Extended. This means that all other modules rely on this module.
endef

define Package/qt5base/config
	source "$(SOURCE)/Config.in"

	menu "Select Qtbase Modules"
		depends on PACKAGE_qt5base

		$(foreach lib,$(QT5BASE_LIBS),
			config PACKAGE_qt5base-$(lib)
				bool "Qt $(lib) Library"
				default y
		)

	endmenu

endef

PKG_CONFIG_DEPENDS+= \
	QT_BUILD_RELEASE QT_BUILD_DEBUG \
	QT_OPTIMIZE_SIZE QT_OPTIMIZE_DEBUG QT_OPTIMIZE_TOOLS

ifndef CONFIG_USE_GLIBC
  # Do not use sstrip for QT5. When sstrip is used the QT5 plugin loading does
  # not work, because of QT''s internal elf parser, see
  # https://bugreports.qt.io/browse/QTBUG-52567
  # Use the code from the gcc package to use strip instaed.
  ifneq ($(CONFIG_USE_SSTRIP),)
    STRIP:=$(TARGET_CROSS)strip $(call qstrip,$(CONFIG_STRIP_ARGS))
    RSTRIP:= \
      export CROSS="$(TARGET_CROSS)" \
        $(if $(CONFIG_KERNEL_KALLSYMS),NO_RENAME=1) \
        $(if $(CONFIG_KERNEL_PROFILING),KEEP_SYMBOLS=1); \
      NM="$(TARGET_CROSS)nm" \
      STRIP="$(STRIP)" \
      STRIP_KMOD="$(SCRIPT_DIR)/strip-kmod.sh" \
      $(SCRIPT_DIR)/rstrip.sh
  endif
endif

include $(INCLUDE_DIR)/host-build.mk
include qmake.mk

BASE_CONFIGURE_ARGSBASE= \
	--gcc-sysroot=no \
	--verbose=yes \
	--opensource \
	--confirm-license \
	--release=$(if $(CONFIG_QT_BUILD_RELEASE),yes,no) \
	$(if $(CONFIG_QT_BUILD_DEBUG),--debug,) \
	--optimized-tools=$(if $(CONFIG_QT_OPTIMIZE_TOOLS),yes,no) \
	--optimize-size=$(if $(CONFIG_QT_OPTIMIZE_SIZE),yes,no) \
	--optimize-debug=$(if $(CONFIG_QT_OPTIMIZE_DEBUG),yes,no) \
	--strip=no \
	--shared=yes \
	--framework=no \
	--reduce-exports=no \
	--reduce-relocations=no \
	--pch=no \
	--ltcg=no \
	--use-gold-linker=no \
	--warnings-are-errors=no \
	--pkg-config=yes \

# ICU is preferred over iconv by, moreover, you should have enough space to hold Qt programs.
CONFIGURE_ARGS=$(BASE_CONFIGURE_ARGSBASE) \
	--prefix=$(QT_INSTALL_PREFIX) \
	--extprefix=$(QT_EXTPREFIX) \
	--hostprefix=$(QT_HOST_PREFIX) \
	--bindir=$(QT_INSTALL_BINS) \
	--headerdir=$(QT_INSTALL_HEADERS) \
	--libdir=$(QT_INSTALL_LIBS) \
	--archdatadir=$(QT_INSTALL_ARCHDATA) \
	--plugindir=$(QT_INSTALL_PLUGINS) \
	--libexecdir=$(QT_INSTALL_LIBEXECS) \
	--importdir=$(QT_INSTALL_IMPORTS) \
	--qmldir=$(QT_INSTALL_QML) \
	--datadir=$(QT_INSTALL_DATA) \
	--docdir=$(QT_INSTALL_DOCS) \
	--translationdir=$(QT_INSTALL_TRANSLATIONS) \
	--sysconfdir=$(QT_INSTALL_CONFIGURATION) \
	--examplesdir=$(QT_INSTALL_EXAMPLES) \
	--testsdir=$(QT_INSTALL_TESTS) \
	--hostbindir=$(QT_HOST_BINS) \
	--hostlibdir=$(QT_HOST_LIBS) \
	--hostdatadir=$(QT_HOST_DATA) \
	--xplatform=linux-openwrt-g++ \
	--compile-examples=$(if $(CONFIG_PACKAGE_qt5base-examples),yes,no) \
	$(if $(CONFIG_PACKAGE_qt5base-examples),,--nomake=examples) \
	--gui=$(if $(CONFIG_PACKAGE_qt5base-gui),yes,no) \
	--widgets=$(if $(CONFIG_PACKAGE_qt5base-widgets),yes,no) \
	--dbus=no \
	--accessibility=yes \
	--doubleconversion=system \
	--glib=no \
	--eventfd=no \
	--inotify=no \
	--iconv=no \
	--icu=yes \
	--pcre=system \
	--zlib=system \
	--journald=no \
	--syslog=no \
	--ssl=$(if $(CONFIG_PACKAGE_qt5base-network),yes,no) \
	--openssl-linked$(if $(CONFIG_PACKAGE_qt5base-network),,=no) \
	--libproxy=no \
	--system-proxies=yes \
	--cups=no \
	--fontconfig=no \
	--freetype=no \
	--harfbuzz=no \
	--gtk=no \
	--opengl=no \
	--opengles3=no \
	--egl=no \
	--xcb-xlib=no \
	--qpa=$(if $(CONFIG_PACKAGE_qt5base-plugin-platforms-linuxfb),linuxfb,no) \
	--directfb=no \
	--eglfs=no \
	--gbm=no \
	--linuxfb=$(if $(CONFIG_PACKAGE_qt5base-plugin-platforms-linuxfb),yes,no) \
	--xcb=no \
	\
	--libudev=no \
	--evdev=no \
	--libinput=$(if $(CONFIG_PACKAGE_qt5base-plugin-input-libinput),yes,no) \
	--mtdev=no \
	--tslib=no \
	--bundled-xcb-xinput=no \
	--xkbcommon=no \
	--gif=$(if $(CONFIG_PACKAGE_qt5base-gui),yes,no) \
	--ico=$(if $(CONFIG_PACKAGE_qt5base-plugin-imageformats-ico),yes,no) \
	--libjpeg=$(if $(CONFIG_PACKAGE_qt5base-plugin-imageformats-jpeg),system,no) \
	--libpng=no \
	--sql-db2=no \
	--sql-ibase=no \
	--sql-mysql=no \
	--sql-oci=no \
	--sql-odbc=no \
	--sql-psql=no \
	--sql-sqlite=no \
	--sql-sqlite2=no \
	--sql-tds=no \
	--sqlite=no \

CONFIGURE_ARGS+= \
	$(if $(CONFIG_PACKAGE_qt5base-bluetooth),,$(if $(CONFIG_PACKAGE_qt5base-nfc),,--skip connectivity)) \
	$(if $(CONFIG_PACKAGE_qt5base-bodymovin),,--skip lottie) \
	$(if $(CONFIG_PACKAGE_qt5base-charts),,--skip charts) \
	$(if $(CONFIG_PACKAGE_qt5base-gamepad),,--skip gamepad) \
	$(if $(CONFIG_PACKAGE_qt5base-multimedia),,--skip multimedia) \
	$(if $(CONFIG_PACKAGE_qt5base-networkauth),,--skip networkauth) \
	$(if $(CONFIG_PACKAGE_qt5base-positioning),,--skip location) \
	$(if $(CONFIG_PACKAGE_qt5base-purchasing),,--skip purchasing) \
	$(if $(CONFIG_PACKAGE_qt5base-qml),,--skip declarative) \
	$(if $(CONFIG_PACKAGE_qt5base-quicktemplates2),,--skip quickcontrols2 --skip graphicaleffects) \
	$(if $(CONFIG_PACKAGE_qt5base-remoteobjects),,--skip remoteobjects) \
	$(if $(CONFIG_PACKAGE_qt5base-script),,--skip script) \
	$(if $(CONFIG_PACKAGE_qt5base-scxml),,--skip scxml) \
	$(if $(CONFIG_PACKAGE_qt5base-sensors),,--skip sensors) \
	$(if $(CONFIG_PACKAGE_qt5base-serialbus),,--skip serialbus) \
	$(if $(CONFIG_PACKAGE_qt5base-serialport),,--skip serialport) \
	$(if $(CONFIG_PACKAGE_qt5base-svg),,--skip svg) \
	$(if $(CONFIG_PACKAGE_qt5base-texttospeech),,--skip speech) \
	$(if $(CONFIG_PACKAGE_qt5base-virtualkeyboard),,--skip virtualkeyboard) \
	$(if $(CONFIG_PACKAGE_qt5base-webchannel),,--skip webchannel) \
	$(if $(CONFIG_PACKAGE_qt5base-websockets),,--skip websockets) \
	$(if $(CONFIG_PACKAGE_qt5base-webview),,--skip webview) \
	$(if $(CONFIG_PACKAGE_qt5base-xmloatterns),,--skip xmlpatterns) \

define Build/Configure
	# CROSS/TARGET_* need to be passed to configure, in order to use cross-compiling tools to check for requirements.
	# Usually used variables such as CC/CXX/CFLAGS/CXXFLAGS/LDFLAGS would be used for compilation of host tools (qmake, moc, etc.),
	# hence we use the TARGET_* nomenclature.
	cd $(PKG_BUILD_DIR) ; \
		TARGET_CROSS="$(TARGET_CROSS)" \
		TARGET_CFLAGS="$(TARGET_CFLAGS)" \
		TARGET_CXXFLAGS="$(TARGET_CFLAGS) $(TARGET_CXXFLAGS)" \
		TARGET_LDFLAGS="$(TARGET_LDFLAGS)" \
		PKG_CONFIG_SYSROOT_DIR="$(STAGING_DIR)" \
		./configure $(CONFIGURE_ARGS)
endef

HOST_CONFIGURE_ARGS=$(BASE_CONFIGURE_ARGSBASE) \
	--prefix=$(STAGING_DIR_HOST) \
	--hostprefix=$(STAGING_DIR_HOST) \
	--hostdatadir=$(STAGING_DIR_HOST)/share \
	--datadir=$(STAGING_DIR_HOST)/share \
	--archdatadir=$(STAGING_DIR_HOST)/lib \
	--compile-examples=no \
	--make=libs \
	--nomake=tools \
	--nomake=examples \
	--gui=yes \
	--widgets=no \
	--dbus=no \
	--accessibility=no \
	--doubleconversion=qt \
	--glib=no \
	--eventfd=no \
	--inotify=no \
	--iconv=no \
	--icu=no \
	--pcre=qt \
	--zlib=qt \
	--journald=no \
	--syslog=no \
	--ssl=no \
	--libproxy=no \
	--system-proxies=no \
	--cups=no \
	--fontconfig=no \
	--freetype=no \
	--harfbuzz=no \
	--gtk=no \
	--opengl=no \
	--opengles3=no \
	--egl=no \
	--xcb-xlib=no \
	--directfb=no \
	--eglfs=no \
	--gbm=no \
	--linuxfb=no \
	--xcb=no \
	\
	--libudev=no \
	--evdev=no \
	--libinput=no \
	--mtdev=no \
	--tslib=no \
	--bundled-xcb-xinput=no \
	--xkbcommon=yes \
	--gif=no \
	--ico=no \
	--libjpeg=no \
	--libpng=no \
	--sql-db2=no \
	--sql-ibase=no \
	--sql-mysql=no \
	--sql-oci=no \
	--sql-odbc=no \
	--sql-psql=no \
	--sql-sqlite=no \
	--sql-sqlite2=no \
	--sql-tds=no \
	--sqlite=no \

define Host/Configure
	# CROSS/TARGET_* need to be passed to configure, in order to use cross-compiling tools to check for requirements.
	# Usually used variables such as CC/CXX/CFLAGS/CXXFLAGS/LDFLAGS would be used for compilation of host tools (qmake, moc, etc.),
	# hence we use the TARGET_* nomenclature.
	cd $(HOST_BUILD_DIR) ; \
		TARGET_CFLAGS="$(HOST_CFLAGS)" \
		TARGET_CXXFLAGS="$(HOST_CFLAGS) $(HOST_CXXFLAGS)" \
		TARGET_LDFLAGS="$(HOST_LDFLAGS)" \
		./configure $(HOST_CONFIGURE_ARGS)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(STAGING_DIR)/host/mk
	$(CP) ./qmake.mk $(STAGING_DIR)/host/mk/

	$(call Build/Install/Headers,$(1))
	$(call Build/Install/Libdevs,$(1))
endef

define Host/Install
	$(call Host/Install/Default)

	$(INSTALL_DIR) $(STAGING_DIR_HOST)
	$(CP) $(HOST_INSTALL_DIR)/lib $(STAGING_DIR_HOST)
	$(CP) $(HOST_INSTALL_DIR)/include $(STAGING_DIR_HOST)
	$(CP) $(HOST_INSTALL_DIR)/share $(STAGING_DIR_HOST)
	$(CP) $(HOST_INSTALL_DIR)/bin $(STAGING_DIR_HOST)
endef

define DefineQt5baseLibrary
  PKG_CONFIG_DEPENDS+=CONFIG_PACKAGE_qt5base-$(1)
  QT5BASE_LIBS+=$(1)
  $(eval $(call DefineQt5Library,$(1),$(2),$(3)))
endef

$(eval $(call DefineQt5baseLibrary,core,,+libatomic +libpthread +zlib +libzstd +libpcre2-16 +libstdcpp +librt +libdouble-conversion +icu))
$(eval $(call DefineQt5baseLibrary,network,core,+libopenssl))
$(eval $(call DefineQt5baseLibrary,xml,core,))

$(foreach lib,$(QT5BASE_LIBS),$(eval $(call BuildPackage,qt5base-$(lib))))
$(eval $(call BuildPackage,qt5base))
$(eval $(call HostBuild))
