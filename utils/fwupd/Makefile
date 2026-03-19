#
# Copyright (C) 2024 TDT AG <development@tdt.de>
#
# This is free software, licensed under the GNU General Public License v2.
# See https://www.gnu.org/licenses/gpl-2.0.txt for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=fwupd
PKG_VERSION:=2.1.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/fwupd/fwupd/releases/download/$(PKG_VERSION)
PKG_HASH:=0ae697f1f2011571310cef5d96429d8a5d541f73b0025bd2b622c9c7f4fe05b6

PKG_MAINTAINER:=Lukas Voegl <lvoegl@tdt.de>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=COPYING
PKG_CPE_ID:=cpe:/a:fwupd:fwupd

PKG_BUILD_DEPENDS:= \
	glib2/host \
	python3/host \
	python-packaging/host \
	python-jinja2/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/meson.mk
include ../../lang/python/python3-host.mk

define Package/fwupd/Default
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=fwupd
  URL:=https://fwupd.org
  DEPENDS:= \
	+glib2 \
	+dbus \
	+libxmlb \
	+libjcat \
	+libprotobuf-c \
	+libusb-1.0 \
	+libsqlite3 \
	+libcurl \
	+liblzma \
	+FWUPD_PLUGIN_FLASHROM:libflashrom \
	+FWUPD_LIBDRM:libdrm \
	+FWUPD_CBOR:libcbor \
	+FWUPD_PLUGIN_MODEMMANAGER:modemmanager \
	+FWUPD_PLUGIN_MODEMMANAGER:libqmi \
	+FWUPD_PLUGIN_MODEMMANAGER:libmbim
endef

define Package/fwupd/Default/description
  A simple system daemon to allow session software to easily update firmware on
  your local machine.
endef

define Package/fwupd-libs
  $(call Package/fwupd/Default)
  TITLE:=fwupd-libs
endef

define Package/fwupd-libs/description
  $(call Package/fwupd/Default/description)
  This package contains the fwupd libraries.
endef

define Package/fwupd-libs/config
  source "$(SOURCE)/Config.in"
endef

define Package/fwupd-tools
  $(call Package/fwupd/Default)
  DEPENDS:=+fwupd-libs
  TITLE:=fwupd-tools
endef

define Package/fwupd-tools/description
  $(call Package/fwupd/Default/description)
  This package contains the fwupd cli tools.
endef

define Package/fwupd-daemon
  $(call Package/fwupd/Default)
  DEPENDS:=+fwupd-libs
  TITLE:=fwupd-daemon
endef

define Package/fwupd-daemon/description
  $(call Package/fwupd/Default/description)
  This package contains the fwupd daemon.
endef

MESON_ARGS += \
	-Dbash_completion=false \
	-Dblkid=disabled \
	-Dbluez=disabled \
	-Dbuild=all \
	-Dcbor=$(if $(CONFIG_FWUPD_CBOR),enabled,disabled) \
	-Ddocs=disabled \
	-Dfirmware-packager=$(if $(CONFIG_FWUPD_FIRMWARE_PACKAGER),true,false) \
	-Dfish_completion=false \
	-Dgnutls=disabled \
	-Dhsi=$(if $(CONFIG_FWUPD_HSI),enabled,disabled) \
	-Dintrospection=disabled \
	-Dlibdrm=$(if $(CONFIG_FWUPD_LIBDRM),enabled,disabled) \
	-Dlibmnl=disabled \
	-Dlogind=disabled \
	-Dlvfs=$(if $(CONFIG_FWUPD_LVFS),true,false) \
	-Dman=false \
	-Dmetainfo=false \
	-Dudev_hotplug=false \
	-Dpassim=disabled \
	-Dplugin_flashrom=$(if $(CONFIG_FWUPD_PLUGIN_FLASHROM),enabled,disabled) \
	-Dplugin_modem_manager=$(if $(CONFIG_FWUPD_PLUGIN_MODEMMANAGER),enabled,disabled) \
	-Dplugin_uefi_capsule_splash=false \
	-Dpolkit=disabled \
	-Dpython=$(HOST_PYTHON3_BIN) \
	-Dqubes=false \
	-Dreadline=disabled \
	-Dstatic_analysis=false \
	-Dsupported_build=enabled \
	-Dsystemd=disabled \
	-Dtests=false \
	-Dumockdev_tests=disabled \
	-Dvalgrind=disabled \
	-Dvendor_ids_dir=/usr/share/hwdata \
	-Dvendor_metadata=false

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/fwupd-3
	$(CP) $(PKG_INSTALL_DIR)/usr/include/fwupd-3/fwupd.h $(1)/usr/include/fwupd-3

	$(INSTALL_DIR) $(1)/usr/include/fwupd-3/libfwupd
	$(CP) $(PKG_INSTALL_DIR)/usr/include/fwupd-3/libfwupd/*.h $(1)/usr/include/fwupd-3/libfwupd

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libfwupd.so* $(1)/usr/lib

	$(INSTALL_DIR) $(1)/usr/lib/fwupd-$(PKG_VERSION)
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/fwupd-$(PKG_VERSION)/*.so* $(1)/usr/lib/fwupd-$(PKG_VERSION)

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/fwupd.pc $(1)/usr/lib/pkgconfig

	$(INSTALL_DIR) $(1)/usr/share/dbus-1/interfaces
	$(CP) $(PKG_INSTALL_DIR)/usr/share/dbus-1/interfaces/*.xml $(1)/usr/share/dbus-1/interfaces
endef

define Package/fwupd-libs/install
	$(INSTALL_DIR) $(1)/etc/fwupd
	$(CP) $(PKG_INSTALL_DIR)/etc/fwupd/fwupd.conf $(1)/etc/fwupd

	$(INSTALL_DIR) $(1)/etc/fwupd/remotes.d
	$(CP) $(PKG_INSTALL_DIR)/etc/fwupd/remotes.d/*.conf $(1)/etc/fwupd/remotes.d

	$(INSTALL_DIR) $(1)/etc/pki
	$(CP) $(PKG_INSTALL_DIR)/etc/pki/fwupd $(1)/etc/pki
	$(CP) $(PKG_INSTALL_DIR)/etc/pki/fwupd-metadata $(1)/etc/pki

	$(INSTALL_DIR) $(1)/usr/share/dbus-1/system.d
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/dbus-1/system.d/org.freedesktop.fwupd.conf $(1)/usr/share/dbus-1/system.d

	$(INSTALL_DIR) $(1)/usr/share/fwupd
	$(CP) $(PKG_INSTALL_DIR)/usr/share/fwupd/quirks.d $(1)/usr/share/fwupd

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libfwupd.so* $(1)/usr/lib

	$(INSTALL_DIR) $(1)/usr/lib/fwupd-$(PKG_VERSION)
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/fwupd-$(PKG_VERSION)/*.so* $(1)/usr/lib/fwupd-$(PKG_VERSION)
endef

define Package/fwupd-tools/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/fwupdtool $(1)/usr/bin
endef

define Package/fwupd-daemon/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/fwupdmgr $(1)/usr/bin

	$(INSTALL_DIR) $(1)/usr/libexec/fwupd
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/libexec/fwupd/fwupd $(1)/usr/libexec/fwupd

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/fwupd $(1)/etc/init.d/fwupd
endef

$(eval $(call BuildPackage,fwupd-libs))
$(eval $(call BuildPackage,fwupd-tools))
$(eval $(call BuildPackage,fwupd-daemon))
