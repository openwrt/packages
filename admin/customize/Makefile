#
# Copyright (C) 2018 Philip Prindeville
#
# This is free software, licensed under the GNU General Public License v3 or
# later.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=customize
PKG_VERSION:=1.0
PKG_RELEASE:=1
PKG_LICENSE:=GPLv3

PKG_MAINTAINER:=Philip Prindeville <philipp@redfish-solutions.com>

include $(INCLUDE_DIR)/package.mk

define Package/customize/Default
  SECTION:=admin
  CATEGORY:=Administration
endef

define Package/customize/description
  Customize your target system.
endef

define Package/customize/download
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile

endef

define Package/root-passwd
$(call Package/customize/Default)
  TITLE:=Set default root password
endef

define Package/root-passwd/description
  Use this package to seed your images with a preset root password.
endef

define Package/root-passwd/config
	config TARGET_ROOT_PASSWD
		string "Default root password (hashed, with dollars doubled up)"
		help
			Default root password.
endef

define Package/root-passwd/install
   # nothing to do
endef

ROOT_PASSWD:=$(call qstrip,$(CONFIG_TARGET_ROOT_PASSWD))

define Package/root-passwd/postinst
#!/bin/sh
if [ -n "$$IPKG_INSTROOT" ] && [ -n "$(ROOT_PASSWD)" ]; then
    $(SED) 's/^root::0:/root:$(ROOT_PASSWD)::/' $$IPKG_INSTROOT/etc/shadow
fi
exit 0
endef

define Package/disable-openssh-password-login
$(call Package/customize/Default)
  TITLE:=Turn off password logins via openssh
  DEPENDS+= @(PACKAGE_openssh-server||PACKAGE_openssh-server-pam)
endef

define Package/disable-openssh-password-login/description
  Change default openssh server setting to disallow password logins (and
  thereby mitigate possible password attacks)
endef

define Package/disable-openssh-password-login/install
  # nothing to do
endef

define Package/disable-openssh-password-login/postinst
#!/bin/sh
if [ -n "$$IPKG_INSTROOT" ]; then
  $(SED) 's/#PasswordAuthentication yes$$/PasswordAuthentication no/' \
	$$IPKG_INSTROOT/etc/ssh/sshd_config
fi
exit 0
endef

$(eval $(call BuildPackage,root-passwd))
$(eval $(call BuildPackage,disable-openssh-password-login))

