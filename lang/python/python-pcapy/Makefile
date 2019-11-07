#
# Copyright (C) 2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pcapy
PKG_VERSION:=0.11.4
PKG_RELEASE:=2

PYPI_NAME:=pcapy
PKG_HASH:=aa239913678d7ba116e66057a37f914de7726aecd11d00db470127df115c4e78

PKG_MAINTAINER:=Andrew McConachie <andrew@depht.com>
PKG_LICENSE:=Apache-1.1

include ../pypi.mk
include $(INCLUDE_DIR)/uclibc++.mk
include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/python-pcapy
	SECTION:=language-python
	CATEGORY:=Languages
	SUBMENU:=Python
	TITLE:=python-pcapy
	URL:=https://www.coresecurity.com/corelabs-research/open-source-tools/pcapy
	DEPENDS:=+python +libpcap $(CXX_DEPENDS)
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
