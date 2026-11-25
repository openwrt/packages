include $(TOPDIR)/rules.mk

PKG_NAME:=wireplumber
PKG_VERSION:=0.5.18
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://gitlab.freedesktop.org/pipewire/$(PKG_NAME)/-/archive/$(PKG_VERSION)
PKG_HASH:=0c2ea30a7b3bb4ecad456bb27e2c283defda59bb53d97df6917a495f12887e33

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Mirko Vogt <mirko-openwrt@nanl.de>
PKG_BUILD_PARALLEL:=1
# glib2/host: glib-mkenums, glib-compile-resources and gdbus-codegen
PKG_BUILD_DEPENDS:=glib2/host

PKG_CONFIG_DEPENDS:= \
	CONFIG_WIREPLUMBER_TOOLS \
	CONFIG_PIPEWIRE_BLUETOOTH \
	CONFIG_PIPEWIRE_V4L2

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/meson.mk

define Package/wireplumber
  SECTION:=sound
  CATEGORY:=Sound
  TITLE:=WirePlumber session manager (minimal)
  URL:=https://pipewire.pages.freedesktop.org/wireplumber/
  # pipewire: the daemon it manages (which also creates the pipewire user)
  DEPENDS:=+libpipewire +pipewire +glib2 +liblua5.4 \
	+PIPEWIRE_BLUETOOTH:bluez-daemon
  PROVIDES:=pipewire-session-manager
endef

define Package/wireplumber/description
  WirePlumber, the session and policy manager of PipeWire, set up for the
  system-wide PipeWire instance of the pipewire package.
endef

# Monitors have no build option (they are configured at runtime): the V4L2 and
# Bluetooth monitors follow the respective support in pipewire (PIPEWIRE_V4L2,
# PIPEWIRE_BLUETOOTH) through the drop-ins installed below.
define Package/wireplumber/config
	menu "WirePlumber feature selection"

config WIREPLUMBER_TOOLS
	bool "Install CLI tools (wpctl, wpexec)"
	default y
	help
		Command-line tools for inspecting/controlling the
		graph (wpctl status, wpctl set-default, ...).
	endmenu
endef

define Package/wireplumber/conffiles
/etc/wireplumber/wireplumber.conf.d/10-openwrt-log.conf
/etc/wireplumber/wireplumber.conf.d/20-openwrt-rt.conf
/etc/wireplumber/wireplumber.conf.d/30-openwrt-monitors.conf
$(if $(CONFIG_PIPEWIRE_V4L2),/etc/wireplumber/wireplumber.conf.d/31-openwrt-v4l2.conf)
$(if $(CONFIG_PIPEWIRE_BLUETOOTH),/etc/wireplumber/wireplumber.conf.d/32-openwrt-bluez.conf)
/etc/wireplumber/wireplumber.conf.d/40-openwrt-static-stream-targets.conf
endef

# All options from upstream meson_options.txt are explicit; defaults overridden for minimal build.
MESON_ARGS += \
	-Dintrospection=disabled \
	-Ddoc=disabled \
	-Dmodules=true \
	-Ddaemon=true \
	-Dtools=$(if $(CONFIG_WIREPLUMBER_TOOLS),true,false) \
	-Dsystem-lua=true \
	-Dsystem-lua-version=5.4 \
	-Delogind=disabled \
	-Dsystemd=disabled \
	-Dsystemd-system-service=false \
	-Dsystemd-user-service=false \
	-Dglib-supp='' \
	-Dtests=false \
	-Ddbus-tests=false \
	-Dsystemd-system-unit-dir=/usr/lib/systemd/system \
	-Dsystemd-user-unit-dir=/usr/lib/systemd/user

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/wireplumber-0.5 $(1)/usr/include/

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libwireplumber-0.5.{a,so*} $(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/wireplumber-0.5.pc $(1)/usr/lib/pkgconfig/
endef

define Package/wireplumber/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/wireplumber $(1)/usr/bin/
	# wpctl/wpexec only exist when tools are built (brace-expansion avoided:
	# the comma would be parsed as a make $(if) argument separator)
	$(if $(CONFIG_WIREPLUMBER_TOOLS),$(CP) $(PKG_INSTALL_DIR)/usr/bin/wpctl $(PKG_INSTALL_DIR)/usr/bin/wpexec $(1)/usr/bin/)

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libwireplumber-0.5.so.* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/wireplumber-0.5 $(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/share/wireplumber
	$(CP) $(PKG_INSTALL_DIR)/usr/share/wireplumber/* $(1)/usr/share/wireplumber/

	# drop-ins for the main-embedded profile: the base monitor set is ALSA only
	# (30-); the V4L2 (31-) and bluez (32-) monitors are enabled only when
	# pipewire is built with the respective support, mirroring pipewire.
	$(INSTALL_DIR) $(1)/etc/wireplumber/wireplumber.conf.d
	$(INSTALL_DATA) ./files/10-openwrt-log.conf $(1)/etc/wireplumber/wireplumber.conf.d/10-openwrt-log.conf
	$(INSTALL_DATA) ./files/20-openwrt-rt.conf $(1)/etc/wireplumber/wireplumber.conf.d/20-openwrt-rt.conf
	$(INSTALL_DATA) ./files/30-openwrt-monitors.conf $(1)/etc/wireplumber/wireplumber.conf.d/30-openwrt-monitors.conf
	$(if $(CONFIG_PIPEWIRE_V4L2),$(INSTALL_DATA) ./files/31-openwrt-v4l2.conf $(1)/etc/wireplumber/wireplumber.conf.d/31-openwrt-v4l2.conf)
	$(if $(CONFIG_PIPEWIRE_BLUETOOTH),$(INSTALL_DATA) ./files/32-openwrt-bluez.conf $(1)/etc/wireplumber/wireplumber.conf.d/32-openwrt-bluez.conf)
	$(INSTALL_DATA) ./files/40-openwrt-static-stream-targets.conf $(1)/etc/wireplumber/wireplumber.conf.d/40-openwrt-static-stream-targets.conf

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/wireplumber.init $(1)/etc/init.d/wireplumber
endef

$(eval $(call BuildPackage,wireplumber))
