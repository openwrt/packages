#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=dbus
PKG_VERSION:=1.12.12
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://dbus.freedesktop.org/releases/dbus/
PKG_HASH:=9546f226011a1e5d9d77245fe5549ef25af4694053189d624d0d6ac127ecf5f8
PKG_MAINTAINER:=
PKG_LICENSE:=AFL-2.1
PKG_CPE_ID:=cpe:/a:freedesktop:dbus

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/dbus/Default
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Simple interprocess messaging system
  URL:=http://dbus.freedesktop.org/
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

CONFIGURE_ARGS += \
	--disable-maintainer-mode \
	--disable-developer \
	--enable-debug=no \
	--enable-shared \
	--disable-static \
	--disable-verbose-mode \
	--disable-asserts \
	--disable-xml-docs \
	--disable-doxygen-docs \
	--disable-ducktype-docs \
	--disable-selinux \
	--disable-apparmor \
	--disable-libaudit \
	--enable-inotify \
	--disable-kqueue \
	--disable-console-owner-file \
	--disable-systemd \
	--disable-tests \
	--disable-code-coverage \
	--disable-x11-autolaunch \
	--with-session-socket-dir=/tmp \
	--with-system-socket=/var/run/dbus/system_bus_socket \
	--with-system-pid-file=/var/run/dbus.pid \
	--with-dbus-user=root \
	--without-x

HOST_CONFIGURE_ARGS+= \
	--disable-maintainer-mode \
	--disable-developer \
	--enable-debug=no \
	--enable-shared \
	--disable-static \
	--disable-verbose-mode \
	--disable-asserts \
	--disable-xml-docs \
	--disable-doxygen-docs \
	--disable-ducktype-docs \
	--disable-selinux \
	--disable-apparmor \
	--disable-libaudit \
	--enable-inotify \
	--disable-kqueue \
	--disable-console-owner-file \
	--disable-systemd \
	--disable-tests \
	--disable-code-coverage \
	--disable-x11-autolaunch \
	--with-system-socket="$(STAGING_DIR_HOSTPKG)/var/run/dbus/system_bus_socket" \
	--with-system-pid-file="$(STAGING_DIR_HOSTPKG)/var/run/dbus.pid" \
	--with-dbus-daemondir="$(STAGING_DIR_HOSTPKG)/bin" \
	--without-x

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/dbus-1.0 $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib/dbus-1.0/include/dbus/
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/lib/dbus-1.0/include/dbus/*.h \
		$(1)/usr/lib/dbus-1.0/include/dbus/
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/libdbus-1.{so*,la} \
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
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/lib/dbus-daemon-launch-helper $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/dbus.init $(1)/etc/init.d/dbus
	$(INSTALL_DIR) $(1)/usr/share/dbus-1
	$(CP) $(PKG_INSTALL_DIR)/usr/share/dbus-1 $(1)/usr/share/
endef

define Package/dbus-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) 	$(PKG_INSTALL_DIR)/usr/bin/dbus-{monitor,send,update-activation-environment} $(1)/usr/bin/
endef

$(eval $(call HostBuild))
$(eval $(call BuildPackage,libdbus))
$(eval $(call BuildPackage,dbus))
$(eval $(call BuildPackage,dbus-utils))
