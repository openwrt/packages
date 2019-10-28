# Copyright (C) 2019 Lucian Cristian <lucian.cristian@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=xorg-tigervnc
PKG_VERSION:=1.20.3
PKG_RELEASE:=1
TIGER:=tigervnc-1.9.0
PKG_SOURCE_URL:=https://www.x.org/releases/individual/xserver
PKG_SOURCE:=xorg-server-$(PKG_VERSION).tar.bz2
PKG_HASH:=1b3ce466c12cacbe2252b3ad5b0ed561972eef9d09e75900d65fb1e21f9201de

PKG_BUILD_DEPENDS:=util-macros xorgproto xtrans font-util/host tigervnc
PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

#PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
#PKG_BUILD_DIR:=$(BUILD_DIR)/xorg-server-$(PKG_VERSION)

PKG_UNPACK=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xjf $(DL_DIR)/$(PKG_SOURCE)

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/xorg-tigervnc
  SECTION:=xorg
  CATEGORY:=Xorg
  DEPENDS:=+libsm +libx11 +libxext +libice +libjpeg-turbo +perl +zlib \
	+libxdamage +libxfixes +libxrandr +libstdcpp +libxfont2 +mesa \
	+libopenssl +pixman +libxshmfence +tigervnc +libbsd
  TITLE:=TigerVNC (Virtual Network Computing) Xserver
  URL:=https://www.tigervnc.org/
endef


define Build/Prepare
	$(call Build/Prepare/Default)
	$(CP) $(BUILD_DIR)/$(TIGER)/unix/xserver/hw $(PKG_BUILD_DIR)/
#	$(CP) ./files/include $(PKG_BUILD_DIR)
	$(SED) 's,$$$${top_srcdir}/../..,$(BUILD_DIR)/$(TIGER),g' \
	    $(PKG_BUILD_DIR)/hw/vnc/Makefile.am
endef

MAKE_FLAGS+= \
  --output-sync=target

CONFIGURE_ARGS += \
    --with-pic --without-dtrace --disable-static --disable-dri \
    --disable-xinerama --disable-xvfb --disable-xnest --disable-xorg \
    --disable-dmx --disable-xwin --disable-xephyr --disable-kdrive \
    --disable-config-dbus --disable-config-hal --disable-config-udev \
    --disable-dri --disable-dri2 --disable-dri3 --enable-glx \
    --disable-xwayland --without-systemd-daemon \
    --without-doxygen --without-xsltproc --without-xmlto --without-fop \
    --with-default-font-path="catalogue:/etc/X11/fontpath.d,built-ins" \
    --with-xkb-path=/usr/share/X11/xkb \
    --with-xkb-output=/var/lib/xkb \
    --with-xkb-bin-directory=/usr/bin \
    --with-serverconfig-path=/usr/lib/xorg \
    --prefix=/usr \
    --libdir=/usr/lib \
    --sbindir=/usr/sbin \
    --bindir=/usr/bin \
    --sysconfdir=/etc/X11 \
    --datarootdir=/usr/share \
    --with-fontrootdir=/usr/share/fonts/X11

define Package/xorg-tigervnc/install
$(INSTALL_DIR) \
	  $(1)/usr/bin \
	  $(1)/usr/lib/xorg/modules/extensions

	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/bin/* \
	  $(1)/usr/bin/
	$(CP) \
	  $(PKG_INSTALL_DIR)/usr/lib/xorg/modules/extensions/*.so \
	  $(1)/usr/lib/xorg/modules/extensions/
endef

$(eval $(call BuildPackage,xorg-tigervnc))
