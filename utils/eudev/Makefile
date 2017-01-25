#
# Copyright (C) 2006-2008 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=eudev
PKG_VERSION:=3.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://dev.gentoo.org/~blueness/eudev/
PKG_MD5SUM:=7e42d9b9ed8162021665139520676367
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

PKG_BUILD_DEPENDS:=gperf/host
PKG_FIXUP:=autoreconf
PKG_INSTALL=1

define Package/libudev
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Dynamic device management subsystem
  URL:=https://wiki.gentoo.org/wiki/Project:Eudev
  MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
endef

define Package/eudev
  SECTION:=base
  CATEGORY:=Base system
  TITLE:=Dynamic device management subsystem
  URL:=https://wiki.gentoo.org/wiki/Project:Eudev
  MAINTAINER:=Daniel Golle <daniel@makrotopia.org>
  MENU:=1
  DEPENDS:=+EUDEV_EXTRA_blkid:libblkid +EUDEV_EXTRA_kmod:libkmod +librt +libudev
  PROVIDES:=udev
  CONFLICTS:=udev
endef

define Package/eudev/description
udev allows Linux users to have a dynamic /dev directory and it
provides the ability to have persistent device names.
eudev is a fork of systemd-udev with the goal of obtaining better
compatibility with existing software such as OpenRC and Upstart, older
kernels, various toolchains and anything else required by users and
various distributions.
endef

define Package/eudev/conffiles
/etc/udev/udev.conf
endef

define Package/eudev/config
	source "$(SOURCE)/Config.in"
endef

CONFIGURE_ARGS += \
	--prefix=/usr --exec-prefix= --sysconfdir=/etc \
	--libexecdir=/lib/udev --sbindir=/sbin \
	--disable-hwdb --disable-introspection --disable-manpages \
	--disable-selinux \
	$(if $(CONFIG_EUDEV_EXTRA_blkid),--enable-blkid,--disable-blkid) \
	$(if $(CONFIG_EUDEV_EXTRA_kmod),--enable-kmod,--disable-kmod)


eudev-extra-lib-bin-$(CONFIG_EUDEV_EXTRA_ata_id) += ata_id

eudev-extra-rules-$(CONFIG_EUDEV_EXTRA_blkid) += 60-persistent-storage.rules

eudev-extra-lib-bin-$(CONFIG_EUDEV_EXTRA_cdrom_id) += cdrom_id
eudev-extra-rules-$(CONFIG_EUDEV_EXTRA_cdrom_id) += 60-cdrom_id.rules

eudev-extra-lib-bin-$(CONFIG_EUDEV_EXTRA_collect) += collect

eudev-extra-rules-$(CONFIG_EUDEV_EXTRA_input_id) += 60-persistent-input.rules

eudev-extra-lib-bin-$(CONFIG_EUDEV_EXTRA_mtd_probe) += mtd_probe
eudev-extra-rules-$(CONFIG_EUDEV_EXTRA_mtd_probe) += 75-probe_mtd.rules

eudev-extra-lib-bin-$(CONFIG_EUDEV_EXTRA_scsi_id) += scsi_id

eudev-extra-lib-bin-$(CONFIG_EUDEV_EXTRA_v4l_id) += v4l_id
eudev-extra-rules-$(CONFIG_EUDEV_EXTRA_v4l_id) += 60-persistent-v4l.rules

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libudev.h $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/share/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/share/pkgconfig/udev.pc $(1)/usr/share/pkgconfig
	$(INSTALL_DIR) $(1)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libudev.so* $(1)/lib
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/lib/pkgconfig/libudev.pc $(1)/usr/lib/pkgconfig
endef

define Package/libudev/install
	$(INSTALL_DIR) $(1)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libudev.so* $(1)/lib
endef

define Package/eudev/install
	$(INSTALL_DIR) $(1)/etc/udev/rules.d
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/etc/udev/udev.conf $(1)/etc/udev

	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/bin/udevadm \
		$(PKG_INSTALL_DIR)/sbin/udevd \
		$(1)/sbin

	$(INSTALL_DIR) $(1)/lib/udev/rules.d
	$(INSTALL_DATA) \
		$(addprefix $(PKG_INSTALL_DIR)/lib/udev/rules.d/, \
			$(eudev-extra-rules-y)) \
		$(addprefix $(PKG_INSTALL_DIR)/lib/udev/rules.d/, \
			50-udev-default.rules \
			60-block.rules \
			60-drm.rules \
			60-evdev.rules \
			60-persistent-alsa.rules \
			60-persistent-storage-tape.rules \
			60-serial.rules \
			64-btrfs.rules \
			70-mouse.rules \
			75-net-description.rules \
			78-sound-card.rules \
			80-net-name-slot.rules) \
		$(1)/lib/udev/rules.d

ifneq ($(eudev-extra-lib-bin-y),)
		$(INSTALL_BIN) \
			$(addprefix $(PKG_INSTALL_DIR)/lib/udev/, \
				$(eudev-extra-lib-bin-y)) \
			$(1)/lib/udev/
endif
endef

$(eval $(call BuildPackage,eudev))
$(eval $(call BuildPackage,libudev))
