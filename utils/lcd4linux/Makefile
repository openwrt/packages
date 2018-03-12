#
# Copyright (C) 2007-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=lcd4linux
PKG_REV:=1203
PKG_VERSION:=r$(PKG_REV)
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=https://ssl.bulix.org/svn/lcd4linux/trunk/
PKG_SOURCE_SUBDIR:=lcd4linux-$(PKG_VERSION)
PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_SOURCE_PROTO:=svn

LCD4LINUX_DRIVERS:= \
	ASTUSB \
	BeckmannEgle \
	BWCT \
	CrystalFontz \
	Curses \
	Cwlinux \
	D4D \
	DPF \
	EA232graphic \
	EFN \
	FutabaVFD \
	FW8888 \
	G15 \
	GLCD2USB \
	IRLCD \
	$(if $(CONFIG_BROKEN),HD44780) \
	$(if $(CONFIG_BROKEN),HD44780-I2C) \
	LCD2USB \
	$(if $(CONFIG_BROKEN),LCDLinux) \
	LCDTerm \
	LEDMatrix \
	LPH7508 \
	$(if $(CONFIG_BROKEN),LUIse) \
	LW_ABP \
	M50530 \
	MatrixOrbital \
	MatrixOrbitalGX \
	MilfordInstruments \
	Newhaven \
	Noritake \
	NULL \
	Pertelian \
	PHAnderson \
	PICGraphic \
	picoLCD \
	picoLCDGraphic \
	PNG \
	PPM \
	$(if $(CONFIG_TARGET_rb532),RouterBoard) \
	$(if $(CONFIG_BROKEN),SamsungSPF) \
	ShuttleVFD \
	SimpleLCD \
	st2205 \
	T6963 \
	TeakLCM \
	$(if $(CONFIG_TARGET_ar71xx),TEW673GRU) \
	Trefon \
	USBHUB \
	USBLCD \
	VNC \
	WincorNixdorf \
#	ULA200 \
#	X11 \

LCD4LINUX_PLUGINS:= \
	apm \
	asterisk \
	button_exec \
	cpuinfo \
	dbus \
	diskstats \
	dvb \
	event \
	exec \
	fifo \
	file \
	gps \
	hddtemp \
	huawei \
	i2c_sensors \
	iconv \
	imon \
	isdn \
	kvv \
	loadavg \
	netdev \
	netinfo \
	meminfo \
	mpd \
	mpris_dbus \
	mysql \
	netdev \
	pop3 \
	ppp \
	proc_stat \
	qnaplog \
	seti \
	statfs \
	uname \
	uptime \
	w1retap \
	$(if $(CONFIG_BROKEN),wireless) \
	xmms \
#	python \

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/$(PKG_NAME)-$(PKG_VERSION)

PKG_BUILD_DEPENDS:= \
	ppp \
#	libftdi \
#	libX11 \
#	python \

PKG_CONFIG_DEPENDS:= \
	$(patsubst %,CONFIG_LCD4LINUX_CUSTOM_DRIVER_%,$(LCD4LINUX_DRIVERS)) \
	$(patsubst %,CONFIG_LCD4LINUX_CUSTOM_PLUGIN_%,$(LCD4LINUX_PLUGINS)) \

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/lcd4linux/Default
  SECTION:=utils
  CATEGORY:=Utilities
  PKG_MAINTAINER:=Jonathan McCrohan <jmccrohan@gmail.com>
  TITLE:=LCD display utility
  URL:=http://lcd4linux.bulix.org/
endef

define Package/lcd4linux/Default/description
 LCD4Linux is a small program that grabs information from the kernel and
 some subsystems and displays it on an external liquid crystal display.
endef


define Package/lcd4linux-custom
$(call Package/lcd4linux/Default)
  DEPENDS:= \
	+LCD4LINUX_CUSTOM_NEEDS_libdbus:libdbus \
	+LCD4LINUX_CUSTOM_NEEDS_libgd:libgd \
	$(if $(ICONV_FULL),+LCD4LINUX_CUSTOM_NEEDS_libiconv:libiconv-full) \
	+LCD4LINUX_CUSTOM_NEEDS_libjpeg:libjpeg \
	+LCD4LINUX_CUSTOM_NEEDS_libmpdclient:libmpdclient \
	+LCD4LINUX_CUSTOM_NEEDS_libmysqlclient:libmysqlclient \
	+LCD4LINUX_CUSTOM_NEEDS_libncurses:libncurses \
	+LCD4LINUX_CUSTOM_NEEDS_libsqlite3:libsqlite3 \
	+LCD4LINUX_CUSTOM_NEEDS_libusb:libusb-compat \
#	+LCD4LINUX_CUSTOM_NEEDS_libftdi:libftdi \
#	+LCD4LINUX_CUSTOM_NEEDS_libX11:libX11 \
#	+LCD4LINUX_CUSTOM_NEEDS_python:python
  MENU:=1
  PROVIDES:=lcd4linux
  VARIANT=custom
endef

define Package/lcd4linux-custom/config
	source "$(SOURCE)/Config.in"
endef

define Package/lcd4linux-custom/description
$(call Package/lcd4linux/Default/description)
 .
 This package contains a customized version of LCD4Linux.
endef


define Package/lcd4linux-full
$(call Package/lcd4linux/Default)
  DEPENDS:= @DEVEL \
	+libdbus \
	+libgd \
	$(if $(ICONV_FULL),+libiconv-full) \
	+libmpdclient \
	+libmysqlclient \
	+libncurses \
	+libsqlite3 \
	+libusb-compat \
#	+libftdi \
#	+libX11 \
#	+python
  PROVIDES:=lcd4linux
  VARIANT=full
endef

define Package/lcd4linux-full/description
$(call Package/lcd4linux/Default/description)
 .
 This package contains a version of LCD4Linux built with all supported
 drivers and plugins.
endef


CONFIGURE_ARGS+= \
	--disable-rpath \

EXTRA_LDFLAGS+= -Wl,-rpath-link,$(STAGING_DIR)/usr/lib

ifeq ($(BUILD_VARIANT),custom)

  LCD4LINUX_CUSTOM_DRIVERS:= $(strip $(foreach c, $(LCD4LINUX_DRIVERS), \
    $(if $(CONFIG_LCD4LINUX_CUSTOM_DRIVER_$(c)),$(c),) \
 ))
  ifeq ($(LCD4LINUX_CUSTOM_DRIVERS),)
    LCD4LINUX_CUSTOM_DRIVERS:=Sample
  endif

  LCD4LINUX_CUSTOM_PLUGINS:= $(strip $(foreach c, $(LCD4LINUX_PLUGINS), \
    $(if $(CONFIG_LCD4LINUX_CUSTOM_PLUGIN_$(c)),$(c)) \
  ))
  ifeq ($(LCD4LINUX_CUSTOM_PLUGINS),)
    LCD4LINUX_CUSTOM_PLUGINS:=sample
  endif

  CONFIGURE_ARGS+= \
	--with-drivers="$(LCD4LINUX_CUSTOM_DRIVERS)" \
	--with-plugins="$(LCD4LINUX_CUSTOM_PLUGINS)" \

  ifneq ($(CONFIG_LCD4LINUX_CUSTOM_NEEDS_libiconv),)
    CONFIGURE_ARGS+= --with-libiconv-prefix="$(ICONV_PREFIX)"
  else
    CONFIGURE_ARGS+= --without-libiconv-prefix
  endif

  ifneq ($(CONFIG_LCD4LINUX_CUSTOM_NEEDS_libmysqlclient),)
    EXTRA_LDFLAGS+= -L$(STAGING_DIR)/usr/lib/mysql
  endif

#  ifneq ($(CONFIG_LCD4LINUX_CUSTOM_NEEDS_python),)
#    CONFIGURE_ARGS+= --with-python
#  else
    CONFIGURE_ARGS+= --without-python
#  endif

#  ifneq ($(CONFIG_LCD4LINUX_CUSTOM_NEEDS_libX11),)
#    CONFIGURE_ARGS+= --with-x
#  else
    CONFIGURE_ARGS+= --without-x
#  endif

endif

ifeq ($(BUILD_VARIANT),full)

  LCD4LINUX_FULL_DRIVERS:= $(strip $(foreach c, $(LCD4LINUX_DRIVERS), \
    $(c) \
  ))

  LCD4LINUX_FULL_PLUGINS:= $(strip $(foreach c, $(LCD4LINUX_PLUGINS), \
    $(c) \
  ))

  CONFIGURE_ARGS+= \
	--with-drivers="$(LCD4LINUX_FULL_DRIVERS)" \
	--with-plugins="$(LCD4LINUX_FULL_PLUGINS)" \
	--with-libiconv-prefix="$(ICONV_PREFIX)" \
	--without-python \
	--without-x \

  EXTRA_LDFLAGS+= -L$(STAGING_DIR)/usr/lib/mysql

endif


define Package/lcd4linux/conffiles
/etc/lcd4linux.conf
endef

define Package/lcd4linux/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/lcd4linux $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/lcd4linux.conf.sample $(1)/etc/lcd4linux.conf
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/lcd4linux.init $(1)/etc/init.d/lcd4linux
	$(SED) "s|^\(Display 'GLCD2USB'\)|#\1|g" \
	    -e "s|^\(Layout 'TestLayer'\)|#\1|g" \
	    -e "s|^#\(Display 'Image'\)|\1|g" \
	    -e "s|^#\(Layout 'Default'\)|\1|g" \
	     $(1)/etc/lcd4linux.conf
endef

Package/lcd4linux-custom/conffiles = $(Package/lcd4linux/conffiles)
Package/lcd4linux-custom/install = $(Package/lcd4linux/install)

Package/lcd4linux-full/conffiles = $(Package/lcd4linux/conffiles)
Package/lcd4linux-full/install = $(Package/lcd4linux/install)

$(eval $(call BuildPackage,lcd4linux-custom))
$(eval $(call BuildPackage,lcd4linux-full))
