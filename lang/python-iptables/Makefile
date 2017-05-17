#
# Copyright (C) 2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-iptables
PKG_VERSION:=0.3.0
PKG_RELEASE:=1
PKG_MAINTAINER:=Andrew McConachie <andrew@depht.com>
PKG_LICENSE:=Apache-2.0

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_PROTO:=https
PKG_SOURCE_URL:=git://github.com/ldx/python-iptables.git
#PKG_SOURCE_VERSION:=0250cebacfbca41b850a3728ec2c10ea21108434
PKG_SOURCE_VERSION:=a71f64f40929d934da8189b729dac4cab001083d
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

PKG_BUILD_DEPENDS:=python python-setuptools

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

define Package/python-iptables
	SECTION:=language-python
	CATEGORY:=Languages
	SUBMENU:=Python
	TITLE:=python-iptables
	URL:=https://pypi.python.org/pypi/python-iptables
	DEPENDS:=+python
endef

define Package/python-iptables/description
Python-iptables provides a pythonesque wrapper via python bindings to iptables under Linux. Interoperability with iptables is achieved via using the iptables C libraries (libiptc, libxtables, and the iptables extensions), not calling the iptables binary and parsing its output. It is meant primarily for dynamic and/or complex routers and firewalls, where rules are often updated or changed, or Python programs wish to interface with the Linux iptables framework.
endef

define Build/Compile
	$(call Build/Compile/PyMod,,\
		install --prefix=/usr --root="$(PKG_INSTALL_DIR)" \
	)
endef

$(eval $(call PyPackage,python-iptables))
$(eval $(call BuildPackage,python-iptables))
