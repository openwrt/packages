#
# Copyright (C) 2008-2011 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=vis

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://git.open-mesh.org/vis.git
PKG_REV:=e141311c6a4fc824efbad536c137ed279905d825
PKG_VERSION:=1440
PKG_RELEASE:=0
PKG_LICENSE:=GPL-2.0

PKG_SOURCE_VERSION:=$(PKG_REV)
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_SOURCE_SUBDIR).tar.gz
PKG_MIRROR_HASH:=fd4b337a56993eec9a03ad8e7918bccc7691aa8b2e5ab6dd7863350f07503285
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_SOURCE_SUBDIR)

PKG_EXTRA_CFLAGS=-DDEBUG_MALLOC -DMEMORY_USAGE -DPROFILE_DATA -DREVISION_VERSION=\"\ rv$(PKG_REV)\" -D_GNU_SOURCE

include $(INCLUDE_DIR)/package.mk

define Package/vis
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Routing and Redirection
  DEPENDS:=+libpthread
  TITLE:=visualization server for B.A.T.M.A.N. layer 3
  URL:=https://www.open-mesh.org/
  MAINTAINER:=Corinna "Elektra" Aichele <onelektra@gmx.net>
endef

define Package/vis/description
visualization server for B.A.T.M.A.N. layer 3
endef

MAKE_VIS_ARGS += \
	EXTRA_CFLAGS='$(TARGET_CFLAGS) $(PKG_EXTRA_CFLAGS)' \
	CCFLAGS="$(TARGET_CFLAGS)" \
	OFLAGS="$(TARGET_CFLAGS)" \
	REVISION="$(PKG_REV)" \
	CC="$(TARGET_CC)" \
	NODEBUG=1 \
	UNAME="Linux" \
	INSTALL_PREFIX="$(PKG_INSTALL_DIR)" \
	STRIP="/bin/true" \
	vis install


define Build/Configure
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) $(MAKE_VIS_ARGS)
endef

define Package/vis/install
	$(INSTALL_DIR) $(1)/usr/sbin $(1)/etc/config $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/vis $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/etc/init.d/vis $(1)/etc/init.d
	$(INSTALL_DATA) ./files/etc/config/vis $(1)/etc/config
endef

define Package/vis/conffiles
/etc/config/vis
endef

$(eval $(call BuildPackage,vis))
