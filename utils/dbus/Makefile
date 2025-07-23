#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=dbus
PKG_VERSION:=1.16.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://dbus.freedesktop.org/releases/dbus
PKG_HASH:=0ba2a1a4b16afe7bceb2c07e9ce99a8c2c3508e5dec290dbb643384bd6beb7e2

PKG_MAINTAINER:=Robert Marko <robimarko@gmail.com>
PKG_LICENSE:=AFL-2.1
PKG_CPE_ID:=cpe:/a:freedesktop:dbus

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

PKG_CONFIG_DEPENDS:= \
	CONFIG_DBUS_VERBOSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

define Package/dbus/Default
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Simple interprocess messaging system
  URL:=https://dbus.freedesktop.org/
  USERID:=dbus=91:dbus=91
endef

define Package/dbus/Default/description
 D-Bus is a message bus system, a simple way for applications to talk to one
 another. In addition to interprocess communication, D-Bus helps coordinate
 process lifecycle; it makes it simple and reliable to code a "single instance"
 application or daemon, and to launch applications and daemons on demand when
 their services are needed.
endef

define Package/libdbus
$(call Package/dbus/Default)
  CATEGORY:=Libraries
  TITLE+= (library)
  DEPENDS:= +libpthread
endef

define Package/libdbus/Description
$(call Package/dbus/Default/description)
 This package contains the D-Bus shared library.
endef

define Package/dbus
$(call Package/dbus/Default)
 TITLE+= (daemon)
 DEPENDS:= +libexpat +libdbus
endef

define Package/dbus/Description
$(call Package/dbus/Default/description)
 This package contains the D-Bus daemon.
endef

define Package/dbus-utils
$(call Package/dbus/Default)
 TITLE+= (utilities)
 DEPENDS:= +dbus
endef

define Package/dbus-utils/Description
$(call Package/dbus/Default/description)
 This package contains D-Bus utilities.
endef

define Package/dbus/config
  source "$(SOURCE)/Config.in"
endef

MESON_ARGS += \
	-Ddbus_user=root \
	-Dsession_socket_dir=/tmp \
	-Dsystem_socket=/var/run/dbus/system_bus_socket \
	-Dsystem_pid_file=/var/run/dbus.pid \
	-Dasserts=false \
	-Dchecks=false \
	-Ddoxygen_docs=disabled \
	-Dxml_docs=disabled \
	-Dducktype_docs=disabled \
	-Dselinux=disabled \
	-Dapparmor=disabled \
	-Dlibaudit=disabled \
	-Dinotify=enabled \
	-Dkqueue=disabled \
	-Dsystemd=disabled \
	-Dmodular_tests=disabled \
	-Dintrusive_tests=false \
	-Dinstalled_tests=false \
	-Dx11_autolaunch=disabled \
	-Dtools=true \
	-Duser_session=false \
	-Dmessage_bus=true \
	-Dstats=false

ifeq ($(CONFIG_DBUS_VERBOSE),y)
  MESON_ARGS += -Dverbose_mode=true
else
  MESON_ARGS += -Dverbose_mode=false
endif

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/dbus-1.0 $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib/dbus-1.0/include/dbus/
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/lib/dbus-1.0/include/dbus/*.h \
		$(1)/usr/lib/dbus-1.0/include/dbus/
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libdbus-1.so* \
		$(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/dbus-1.0 $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/dbus-1.pc \
		$(1)/usr/lib/pkgconfig/
endef

define Package/libdbus/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libdbus-1.so.* $(1)/usr/lib/
endef

define Package/dbus/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/dbus-cleanup-sockets $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/dbus-daemon $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/dbus-launch $(1)/usr/bin/dbus-launch.real
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/dbus-uuidgen $(1)/usr/bin/
	$(INSTALL_BIN) ./files/dbus-launch $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/libexec/dbus-daemon-launch-helper $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/dbus.init $(1)/etc/init.d/dbus
	$(INSTALL_DIR) $(1)/usr/share/dbus-1
	$(CP) $(PKG_INSTALL_DIR)/usr/share/dbus-1 $(1)/usr/share/
	$(INSTALL_DIR) $(1)/etc/capabilities
	$(INSTALL_DATA) ./files/dbus.json $(1)/etc/capabilities
endef

define Package/dbus-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/dbus-monitor $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/dbus-send $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/dbus-test-tool $(1)/usr/bin/
endef

$(eval $(call BuildPackage,libdbus))
$(eval $(call BuildPackage,dbus))
$(eval $(call BuildPackage,dbus-utils))
