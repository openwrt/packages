#
# Copyright (C) 2022 Thomas Cujé
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sshuttle
PKG_VERSION:=1.1.1
PKG_RELEASE:=1

PYPI_NAME:=sshuttle
PKG_HASH:=f5a3ed1e5ab1213c7a6df860af41f1a903ab2cafbfef71f371acdcff21e69ee6

PKG_MAINTAINER:=Thomas Cujé <dev.cuje@freenet.de>
PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=LICENSE

include ../../lang/python/pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python3-package.mk

define Package/sshuttle
  SUBMENU:=SSH
  SECTION:=net
  CATEGORY:=Network
  TITLE:=Full-featured VPN over an SSH tunnel
  URL:=https://github.com/sshuttle/sshuttle
  EXTRA_DEPENDS:= \
  	python3-light \
  	python3-ctypes \
  	python3-urllib
  PKGARCH:=all
endef

define Package/sshuttle/description
  Transparent proxy server that works as a poor man's VPN. Forwards over ssh. Doesn't require admin. Works with Linux and MacOS. Supports DNS tunneling.
endef

define Package/sshuttle/conffiles
/etc/config/sshuttle
endef

# Some sshuttle script files are copied to SSH remote hosts and are therefore mandatory.
# This causes the otherwise pre-compiled package to contain the source package.
# Compare with https://github.com/sshuttle/sshuttle/blob/v1.1.1/sshuttle/ssh.py#L95-L103
# Since the source is very small in general, to reduce complexity
# and support all architectures no explicit filtering is used.
define Package/sshuttle/install
	$(call Py3Package/sshuttle/install,$(1))
	$(call Py3Package/ProcessFilespec,sshuttle,$(PKG_INSTALL_DIR),$(1))
	$(call Python3/DeleteEmptyDirs,$(1))
	if [ -d "$(1)/usr/bin" ]; then \
		$(call Python3/FixShebang,$(1)/usr/bin/*) ; \
	fi
endef

define Py3Package/sshuttle/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/sshuttle $(1)/usr/bin/

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/sshuttle.config $(1)/etc/config/sshuttle

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/sshuttle.init $(1)/etc/init.d/sshuttle
endef

$(eval $(call Py3Package,sshuttle))
$(eval $(call BuildPackage,sshuttle))
