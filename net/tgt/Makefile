# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.

include $(TOPDIR)/rules.mk

PKG_NAME:=tgt
PKG_VERSION:=1.0.75
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/fujita/tgt/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=1c719fdccc6ddc8e5de57a6e546aa64f41056a2fb1d710b8b2a22f65e08f5b90

PKG_MAINTAINER:=Maxim Storchak <m.storchak@gmail.com>
PKG_LICENSE:=GPL-2.0

PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk

define Package/tgt
  SECTION:=net
  CATEGORY:=Network
  URL:=http://stgt.sourceforge.net/
  TITLE:=userspace iSCSI target
  DEPENDS:=+libpthread +libaio
endef

define Package/tgt/description
The Linux target framework (tgt) is a user space SCSI target framework
that supports the iSCSI and iSER transport protocols and that also
supports multiple methods for accessing block storage. Tgt consists of
a user-space daemon and user-space tools.
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
	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/init.d $(1)/usr/sbin
	$(INSTALL_DATA) ./files/tgt.config $(1)/etc/config/tgt
	$(INSTALL_BIN) ./files/tgt.init $(1)/etc/init.d/tgt
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/tgtd $(PKG_INSTALL_DIR)/usr/sbin/tgtadm $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,tgt))
