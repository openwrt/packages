#
# Copyright (C) 2024 TDT AG <development@tdt.de>
#
# This is free software, licensed under the GNU General Public License v2.
# See https://www.gnu.org/licenses/gpl-2.0.txt for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=fwupd
PKG_VERSION:=1.9.24
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/fwupd/fwupd/releases/download/$(PKG_VERSION)
PKG_HASH:=12f560b35dbed981fde8cf774c6d1f2e658a157d3a63d6c439bf418dbcc44b4c

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
	+FWUPD_LIBARCHIVE:libarchive \
	+FWUPD_CBOR:libcbor \
	+FWUPD_LZMA:liblzma \
	+FWUPD_CURL:libcurl \
	+FWUPD_SQLITE:libsqlite3 \
	+FWUPD_GUDEV:libgudev \
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
	-Db_lto=true \
	-Dbuild=all \
	-Dpython=$(HOST_PYTHON3_BIN) \
	-Dudevdir=/lib/udev \
	-Dsupported_build=enabled \
	-Dstatic_analysis=false \
	-Dtests=false \
	-Dmetainfo=false \
	-Dbash_completion=false \
	-Dfish_completion=false \
	-Dman=false \
	-Dthinklmi_compat=false \
	-Dconsolekit=disabled \
	-Ddocs=disabled \
	-Dintrospection=disabled \
	-Dbluez=disabled \
	-Dpolkit=disabled \
	-Dgnutls=disabled \
	-Dpassim=disabled \
	-Dplugin_acpi_phat=disabled \
	-Dplugin_amdgpu=disabled \
	-Dplugin_android_boot=disabled \
	-Dplugin_bcm57xx=disabled \
	-Dplugin_cfu=disabled \
	-Dplugin_cpu=disabled \
	-Dplugin_emmc=disabled \
	-Dplugin_ep963x=disabled \
	-Dplugin_gpio=disabled \
	-Dplugin_igsc=disabled \
	-Dplugin_kinetic_dp=disabled \
	-Dplugin_logitech_bulkcontroller=disabled \
	-Dplugin_logitech_scribe=disabled \
	-Dplugin_logitech_tap=disabled \
	-Dplugin_parade_lspcon=disabled \
	-Dplugin_pixart_rf=disabled \
	-Dplugin_realtek_mst=disabled \
	-Dplugin_synaptics_mst=disabled \
	-Dplugin_mediatek_scaler=disabled \
	-Dplugin_synaptics_rmi=disabled \
	-Dplugin_scsi=disabled \
	-Dplugin_tpm=disabled \
	-Dplugin_redfish=disabled \
	-Dplugin_uefi_capsule=disabled \
	-Dplugin_uefi_pk=disabled \
	-Dplugin_nitrokey=disabled \
	-Dplugin_nvme=disabled \
	-Dplugin_msr=disabled \
	-Dplugin_mtd=disabled \
	-Dplugin_flashrom=disabled \
	-Dplugin_intel_me=disabled \
	-Dplugin_uf2=disabled \
	-Dplugin_upower=disabled \
	-Dplugin_powerd=disabled \
	-Dplugin_fastboot=disabled \
	-Dgusb=disabled \
	-Dsystemd=disabled \
	-Dlaunchd=disabled \
	-Delogind=disabled \
	-Dfirmware-packager=$(if $(CONFIG_FWUPD_FIRMWARE_PACKAGER),true,false) \
	-Dhsi=$(if $(CONFIG_FWUPD_HSI),enabled,disabled) \
	-Dlvfs=$(if $(CONFIG_FWUPD_LVFS),true,false) \
	-Dcbor=$(if $(CONFIG_FWUPD_CBOR),enabled,disabled) \
	-Dlzma=$(if $(CONFIG_FWUPD_LZMA),enabled,disabled) \
	-Dcurl=$(if $(CONFIG_FWUPD_CURL),enabled,disabled) \
	-Dsqlite=$(if $(CONFIG_FWUPD_SQLITE),enabled,disabled) \
	-Dlibarchive=$(if $(CONFIG_FWUPD_LIBARCHIVE),enabled,disabled) \
	-Dgudev=$(if $(CONFIG_FWUPD_GUDEV),enabled,disabled) \
	-Dplugin_modem_manager=$(if $(CONFIG_FWUPD_PLUGIN_MODEMMANAGER),enabled,disabled)

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/fwupd-1
	$(CP) $(PKG_INSTALL_DIR)/usr/include/fwupd-1/fwupd.h $(1)/usr/include/fwupd-1

	$(INSTALL_DIR) $(1)/usr/include/fwupd-1/libfwupd
	$(CP) $(PKG_INSTALL_DIR)/usr/include/fwupd-1/libfwupd/*.h $(1)/usr/include/fwupd-1/libfwupd

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

	$(if $(CONFIG_FWUPD_GUDEV), \
		$(INSTALL_DIR) $(1)/lib/udev/rules.d; \
		$(INSTALL_DATA) $(PKG_INSTALL_DIR)/lib/udev/rules.d/*.rules $(1)/lib/udev/rules.d)

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
