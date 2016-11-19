#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pcapy
PKG_VERSION:=0.10.10
PKG_RELEASE:=1
PKG_MAINTAINER:=Andrew McConachie <andrew@depht.com>
PKG_LICENSE:=Apache-1.1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/CoreSecurity/pcapy.git
PKG_SOURCE_VERSION:=37179f5b6187ec58d3ba11ef7b24e3c341cbabbb
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

PKG_BUILD_DEPENDS:=python python-setuptools

include $(INCLUDE_DIR)/package.mk
$(call include_mk, python-package.mk)

define Package/python-pcapy
	SECTION:=language-python
	CATEGORY:=Languages
	SUBMENU:=Python
	TITLE:=python-pcapy
	URL:=https://www.coresecurity.com/corelabs-research/open-source-tools/pcapy
	DEPENDS:=+python +libpcap +libstdcpp
endef

define Package/python-pcapy/description
 Pcapy is a Python extension module that interfaces with the libpcap packet capture library. Pcapy enables python scripts to capture packets on the network. Pcapy is highly effective when used in conjunction with a packet-handling package such as Impacket, which is a collection of Python classes for constructing and dissecting network packets.
endef

define Build/Compile
	$(call Build/Compile/PyMod,,\
		install --prefix=/usr --root="$(PKG_INSTALL_DIR)" \
	)
endef

$(eval $(call PyPackage,python-pcapy))
$(eval $(call BuildPackage,python-pcapy))
