#
# Copyright (C) 2012-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=tgt
PKG_VERSION:=1.0.73
PKG_REV:=013223dc886a03719ca02db52162056249d99448
PKG_MIRROR_HASH:=649bd012ab0944644ff83cc2974e7a5c374d568e0f4328d9f8d352d4b59f73bb
PKG_RELEASE:=1
PKG_USE_MIPS16:=0

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/fujita/tgt.git

PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(PKG_REV).tar.gz
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_MAINTAINER:=Maxim Storchak <m.storchak@gmail.com>
PKG_LICENSE:=GPL-2.0

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)

include $(INCLUDE_DIR)/package.mk

define Package/tgt
  SECTION:=net
  CATEGORY:=Network
  URL:=http://stgt.sourceforge.net/
  TITLE:=userspace iSCSI target
  DEPENDS:=+libpthread +libaio @KERNEL_AIO
endef

define Package/tgt/description
Linux SCSI target framework (tgt) aims to simplify various SCSI target driver (iSCSI, Fibre Channel, SRP, etc) creation and maintenance.
Key goals of the project are the clean integration into the scsi-mid layer and implementing a great portion of tgt in user space.
Tgt consists of kernel-space and user-space code. The kernel-space component is included in upstream as of 2.6.20.
Note that if you are interested in only iSCSI (probably you are), you need only the user-space code (any kernel version is fine).
endef

define Build/Compile
	CC=$(TARGET_CC) CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" \
		$(MAKE) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		LD="$(TARGET_CC)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		install-programs
endef

define Package/tgt/conffiles
/etc/config/tgt
endef

define Package/tgt/install
	$(INSTALL_DIR) $(1)/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(CP) ./files/* $(1)/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/tgtd $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/tgtadm $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,tgt))
