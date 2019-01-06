#
# Copyright (C) 2009-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gitolite
PKG_VERSION:=3.6.10
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_HASH:=0ae3bea637b25cff13826e5ecd181c7b74a6eff377cf4c2243d85c2b0a290d3f
PKG_SOURCE_URL:=https://codeload.github.com/sitaramc/gitolite/tar.gz/v$(PKG_VERSION)?

include $(INCLUDE_DIR)/package.mk

define Package/gitolite
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Version Control Systems
  DEPENDS:=+perlbase-essential +perlbase-sys +perlbase-data +perlbase-digest +perlbase-env +perlbase-time +git +perlbase-findbin +perlbase-storable +perlbase-text +perlbase-getopt +perlbase-utf8 +openssh-keygen +openssh-server +openssh-moduli perl
  TITLE:=Easy administration of git repositories
  URL:=http://gitolite.com/gitolite
  MAINTAINER:=Daniel Dickinson <cshored@thecshore.com>
  USERID:=git=382:git=382
endef

define Package/gitolite/description
  Gitolite is a system for managing access to git repositories.  Note you will need to make
  sure dropbear does not interfere with OpenSSH as gitolite depends on feature not in
  dropbear (to my knowledge).
  See https://openwrt.org/docs/guide-user/services/gitolite for a guide on installation.
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
	ln -sf /usr/libexec/gitolite/gitolite $(PKG_INSTALL_DIR)/usr/bin/gitolite
endef

define Package/gitolite/install
	$(INSTALL_DIR) $(1)
	$(CP) $(PKG_INSTALL_DIR)/* $(1)/
endef

$(eval $(call BuildPackage,gitolite))
