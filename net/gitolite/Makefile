#
# Copyright (C) 2009-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=gitolite
PKG_VERSION:=3.6.8
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/sitaramc/gitolite/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=4c5d66964b2881221915f1751ae5e64a89266f8943abf5efd457672374f03edf

include $(INCLUDE_DIR)/package.mk

define Package/gitolite
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Version Control Systems
  DEPENDS:=+perlbase-essential +perlbase-sys +perlbase-data +perlbase-digest +perlbase-env +perlbase-time +git +perlbase-findbin +perlbase-storable +perlbase-text +perlbase-getopt +perlbase-utf8 +openssh-keygen +openssh-server +openssh-moduli perl
  TITLE:=Easy administration of git repositories
  URL:=http://gitolite.com/gitlolite
  MAINTAINER:=Daniel Dickinson <cshored@thecshore.com>
  USERID:=git=382:git=382
endef

define Package/gitolite/description
  Gitolite is a system for managing access to git repositories.  Note you will need to make
  sure dropbear does not interfere with OpenSSH as gitolite depends on feature not in
  dropbear (to my knowledge).
endef

define Package/gitolite/postinst
sed -i -e 's,/var/run/git,/srv/git,' $${IPKG_INSTROOT}/etc/passwd
sed -i -e 's,git:\(.*\):/bin/false,git:\1:/bin/ash,' $${IPKG_INSTROOT}/etc/passwd
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
