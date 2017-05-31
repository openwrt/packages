#
# Copyright (C) 2013 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=facter
PKG_VERSION:=2.0.2
PKG_RELEASE:=1

PKG_SOURCE:=${PKG_NAME}-${PKG_VERSION}.tar.gz
PKG_SOURCE_URL:=http://downloads.puppetlabs.com/facter/
PKG_MD5SUM:=2f249675f4068aaaae132c5c771524b1

include $(INCLUDE_DIR)/package.mk

define Package/facter
  SECTION:=admin
  CATEGORY:=Administration
  DEPENDS:= +libruby +ruby-core +ruby-enc +ruby-yaml
  TITLE:=Collect and display facts about the system
  URL:=http://projects.puppetlabs.com/projects/facter
endef

define Package/facter/description
  A cross-platform Ruby library for retrieving facts from operating systems.
  Supports multiple resolution mechanisms, any of which can be restricted to
  working only on certain operating systems or environments. Facter is
  especially useful for retrieving things like operating system names, IP
  addresses, MAC addresses, and SSH keys.
  .
  It is easy to extend Facter to include your own custom facts or to include
  additional mechanisms for retrieving facts.
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/facter/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/$(PKG_NAME) $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/lib/ruby/1.9/facter
	$(CP) $(PKG_BUILD_DIR)/lib/* $(1)/usr/lib/ruby/1.9/
endef

$(eval $(call BuildPackage,facter))
