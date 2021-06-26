#
# Copyright (C) 2020 Openwrt.org
#
# This is free software, licensed under the Apache License, Version 2.0 .
#

PKG_NAME:=qtbase
PKG_HASH:=909fad2591ee367993a75d7e2ea50ad4db332f05e1c38dd7a5a274e156a4e0f8
PKG_MAINTAINER:=David Yang <mmyangfl@gmail.com>

include qtlib.mk

PKG_CPE_ID:=cpe:/a:qt:qt

define Package/qtbase
	$(call Package/qt/Default)
	TITLE:=Qt Base Module
endef

define Package/qtbase/description
$(call Package/qt/Default/description)

The Qt Base module offers classes for embedded Linux devices. The Base
module is based on Qt and builds the foundation for all other modules of
Qt Extended. This means that all other modules rely on this module.
endef

define Package/qtbase/install
	true
endef

define Package/qtbase/config
	source "$(SOURCE)/Config.in"

	menu "Select Qtbase Modules"
		depends on PACKAGE_qtbase

		$(foreach lib,$(QTBASE_LIBS),
			config PACKAGE_libqt5$(lib)
				bool "Qt $(lib) Library"
				default y
		)

	endmenu

endef

CONFIGURE_ARGS += \
	$(if $(CONFIG_PACKAGE_libqt5bluetooth),,$(if $(CONFIG_PACKAGE_libqt5nfc),,-skip connectivity)) \
	$(if $(CONFIG_PACKAGE_libqt5bodymovin),,-skip lottie) \
	$(if $(CONFIG_PACKAGE_libqt5charts),,-skip charts) \
	$(if $(CONFIG_PACKAGE_libqt5gamepad),,-skip gamepad) \
	$(if $(CONFIG_PACKAGE_libqt5gui),-no-opengl,-no-gui) \
	$(if $(CONFIG_PACKAGE_libqt5multimedia),,-skip multimedia) \
	$(if $(CONFIG_PACKAGE_libqt5networkauth),,-skip networkauth) \
	$(if $(CONFIG_PACKAGE_libqt5positioning),,-skip location) \
	$(if $(CONFIG_PACKAGE_libqt5purchasing),,-skip purchasing) \
	$(if $(CONFIG_PACKAGE_libqt5qml),,-skip declarative) \
	$(if $(CONFIG_PACKAGE_libqt5quicktemplates2),,-skip quickcontrols2 -skip graphicaleffects) \
	$(if $(CONFIG_PACKAGE_libqt5remoteobjects),,-skip remoteobjects) \
	$(if $(CONFIG_PACKAGE_libqt5script),,-skip script) \
	$(if $(CONFIG_PACKAGE_libqt5scxml),,-skip scxml) \
	$(if $(CONFIG_PACKAGE_libqt5sensors),,-skip sensors) \
	$(if $(CONFIG_PACKAGE_libqt5serialbus),,-skip serialbus) \
	$(if $(CONFIG_PACKAGE_libqt5serialport),,-skip serialport) \
	$(if $(CONFIG_PACKAGE_libqt5svg),,-skip svg) \
	$(if $(CONFIG_PACKAGE_libqt5texttospeech),,-skip speech) \
	$(if $(CONFIG_PACKAGE_libqt5virtualkeyboard),,-skip virtualkeyboard) \
	$(if $(CONFIG_PACKAGE_libqt5webchannel),,-skip webchannel) \
	$(if $(CONFIG_PACKAGE_libqt5websockets),,-skip websockets) \
	$(if $(CONFIG_PACKAGE_libqt5webview),,-skip webview) \
	$(if $(CONFIG_PACKAGE_libqt5widgets),,-no-widgets) \
	$(if $(CONFIG_PACKAGE_libqt5xmloatterns),,-skip xmlpatterns) \

define Build/InstallDev
	$(MAKE) -C $(PKG_BUILD_DIR) install
	$(CP) $(PKG_BUILD_DIR)/bin/qt.conf $(TOOLCHAIN_DIR)/bin
	$(RM) $(TOOLCHAIN_DIR)/bin/qt{diag,paths,plugininfo}
endef

define DefineQtbaseLibrary
  QTBASE_LIBS+=$(1)
  $(eval $(call DefineQtLibrary,$(1),$(2),$(3)))
endef

$(eval $(call DefineQtbaseLibrary,core,,+libatomic +libpcre2-16 +libstdcpp +zlib @!LINUX_2_6_36))
$(eval $(call DefineQtbaseLibrary,network,core,+libopenssl))
$(eval $(call DefineQtbaseLibrary,xml,core,))

$(foreach lib,$(QTBASE_LIBS),$(eval $(call BuildPackage,libqt5$(lib))))
$(eval $(call BuildPackage,qtbase))
