#
# Copyright (C) 2020-2023 Olof Hagsand and Rubicon Communications, LLC(Netgate)
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=clixon
PKG_VERSION:=7.5.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/clicon/$(PKG_NAME)/tar.gz/$(PKG_VERSION)?
PKG_HASH:=e05c9697ce9c278e2f29d7152722d72610555a11220349f3275aa64de59bc674
PKG_MAINTAINER:=Olof Hagsand <olof@hagsand.se>, Philip Prindeville <philipp@redfish-solutions.com>

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILE:=LICENSE.md

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/clixon
  SECTION:=utils
  CATEGORY:=Utilities
  URL:=https://www.clicon.org
  TITLE:=YANG-based toolchain
  DEPENDS:=+cligen +libopenssl +libnghttp2 +libcurl \
	 @(PACKAGE_openssh-server||PACKAGE_openssh-server-pam)
  USERID:=clicon=61:clicon=61
endef

define Package/clixon/description
  YANG-based toolchain including NETCONF and RESTCONF interfaces and an interactive CLI.
endef

define Package/clixon/conffiles
/etc/clixon/restconf.xml
/etc/ssh/sshd_config.d/90-netconf-subsystem.conf
endef

CONFIGURE_ARGS += \
	--exec-prefix=/usr \
	--with-restconf=native \
	--with-configfile=/etc/clixon/clixon.xml \
	--with-cligen=$(STAGING_DIR)/usr

CONFIGURE_ARGS:=$(filter-out --disable-dependency-tracking,$(CONFIGURE_ARGS))

INSTALLFLAGS:=-s --strip-program=$(TARGET_CROSS)strip

CONFIGURE_VARS+= \
	INSTALLFLAGS="$(INSTALLFLAGS)" \
	SSH_BIN=/usr/bin/ssh

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/clixon $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libclixon.so* \
	      $(PKG_INSTALL_DIR)/usr/lib/libclixon_backend.so* \
	      $(PKG_INSTALL_DIR)/usr/lib/libclixon_restconf.so* \
	      $(PKG_INSTALL_DIR)/usr/lib/libclixon_cli.so* \
	      $(1)/usr/lib/
endef

define Package/clixon/install
	$(INSTALL_DIR) $(1)/etc/clixon
	$(INSTALL_DATA) ./files/restconf.xml $(1)/etc/clixon/
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/clixon_* $(1)/usr/sbin/
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/clixon_* $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/share/clixon
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/share/clixon/*.yang $(1)/usr/share/clixon/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libclixon.so* \
	      $(PKG_INSTALL_DIR)/usr/lib/libclixon_backend.so* \
	      $(PKG_INSTALL_DIR)/usr/lib/libclixon_restconf.so* \
	      $(PKG_INSTALL_DIR)/usr/lib/libclixon_cli.so* \
	      $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/clixon.init $(1)/etc/init.d/clixon
	$(INSTALL_DIR) $(1)/etc/ssh/sshd_config.d
	$(INSTALL_CONF) ./files/netconf-subsystem.conf $(1)/etc/ssh/sshd_config.d/90-netconf-subsystem.conf
endef

$(eval $(call BuildPackage,clixon))

