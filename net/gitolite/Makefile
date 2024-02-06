#
# Copyright (C) 2009-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gitolite
PKG_VERSION:=3.6.13
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/sitaramc/gitolite.git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=f4ac58bc11fde65ef2c6a07f84af214989324147c4aa117ae1483ba0453e402f

PKG_CPE_ID:=cpe:/a:sitaram_chamarty:gitolite

include $(INCLUDE_DIR)/package.mk

define Package/gitolite
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Version Control Systems
  DEPENDS:= \
	+git \
	+perlbase-essential \
	+perlbase-data \
	+perlbase-digest \
	+perlbase-env \
	+perlbase-findbin \
	+perlbase-getopt \
	+perlbase-mime \
	+perlbase-storable \
	+perlbase-sys \
	+perlbase-text \
	+perlbase-time \
	+perlbase-utf8 \

  TITLE:=Easy administration of git repositories
  URL:=https://gitolite.com/gitolite/
  USERID:=git=382:git=382
endef

define Package/gitolite/description
  Gitolite is a system for managing access to git repositories.
  See https://openwrt.org/docs/guide-user/services/gitolite for a guide
  to installation.
  NB: You will need an SSH server to use gitolite: dropbear is now sufficient
  for gitolite purposes.
endef

define Package/gitolite/postinst
sed -i -e 's,/var/run/git,/srv/git,' $${IPKG_INSTROOT}/etc/passwd
sed -i -e 's,git:\(.*\):/bin/false,git:\1:/bin/ash,' $${IPKG_INSTROOT}/etc/passwd
sed -i -e 's,git:x:0:\(.*\)$$,git:x:99999:\1,' $${IPKG_INSTROOT}/etc/shadow
endef

define Build/Configure
	true
endef

define Build/Compile
	mkdir -p $(PKG_INSTALL_DIR)/usr/libexec/gitolite
	$(PKG_BUILD_DIR)/install -to $(PKG_INSTALL_DIR)/usr/libexec/gitolite
	mkdir -p $(PKG_INSTALL_DIR)/usr/bin
	$(LN) ../libexec/gitolite/gitolite $(PKG_INSTALL_DIR)/usr/bin/gitolite
endef

define Package/gitolite/install
	$(INSTALL_DIR) $(1)
	$(CP) $(PKG_INSTALL_DIR)/* $(1)/
endef

$(eval $(call BuildPackage,gitolite))
