include $(TOPDIR)/rules.mk

PKG_NAME:=cifsd-tools
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/cifsd-team/cifsd-tools.git
PKG_SOURCE_DATE:=2019-11-27
PKG_SOURCE_VERSION:=06fd4153a5d5af1f96a20234f397bd149a8e4832
PKG_MIRROR_HASH:=2849d2af471e327abc8d67afc91ca767c410e2b307d6554531a0b387d9ad909a

PKG_MAINTAINER:=Andy Walsh <andy.walsh44+github@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=COPYING

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_REMOVE_FILES:=autogen.sh

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/cifsd-tools
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Filesystem
  TITLE:=Kernel CIFS/SMB server support and userspace tools
  URL:=https://github.com/cifsd-team/cifsd-tools
  DEPENDS:=+kmod-fs-cifsd +glib2 +libnl-core +libnl-genl
endef

define Package/cifsd-tools/description
  Userspace tools (cifsd, cifsuseradd, cifsshareadd) for the CIFS/SMB kernel fileserver.
  The config file location is /etc/cifs/smb.conf
endef

define Package/cifsd-tools/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libcifsdtools.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/{cifsuseradd,cifsshareadd,cifsd} $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/etc/config $(1)/etc/cifs $(1)/etc/init.d
	$(INSTALL_CONF) ./files/cifsd.config $(1)/etc/config/cifsd
	$(INSTALL_DATA) ./files/smb.conf.template $(1)/etc/cifs/
	$(INSTALL_BIN) ./files/cifsd.init $(1)/etc/init.d/cifsd
	# copy examples until we have a wiki page
	$(INSTALL_DATA) ./files/cifsd.config.example $(1)/etc/cifs/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/Documentation/configuration.txt $(1)/etc/cifs/
endef

define Package/cifsd-tools/conffiles
/etc/config/cifsd
/etc/cifs/smb.conf.template
/etc/cifs/smb.conf
/etc/cifs/cifsdpwd.db
endef

$(eval $(call BuildPackage,cifsd-tools))
