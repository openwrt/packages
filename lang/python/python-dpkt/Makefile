#
# Copyright (C) 2017 Andrew McConachie
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-dpkt
PKG_VERSION:=1.91
PKG_RELEASE:=1
PKG_MAINTAINER:=Andrew McConachie <andrew@depht.com>
PKG_LICENSE:=BSD-3-Clause

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/kbandla/dpkt.git
PKG_SOURCE_VERSION:=6cd0909d613a66033ecdefaca6cc07cfa7d46d6b
PKG_MIRROR_HASH:=fe8657552b1dbaf8b9eba50168730e200567dc88a06932aa1cf60dc93211d16b
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/python-dpkt
	SECTION:=language-python
	CATEGORY:=Languages
	SUBMENU:=Python
	TITLE:=python-dpkt
	URL:=https://dpkt.readthedocs.io/en/latest/
	DEPENDS:=+python
endef

define Package/python-dpkt/description
  dpkt is a python module for fast, simple packet creation / parsing, with definitions for the basic TCP/IP protocols
  https://pypi.python.org/pypi/dpkt
  https://github.com/kbandla/dpkt
endef

define Build/Compile
	$(call Build/Compile/PyMod,,\
		install --prefix=/usr --root="$(PKG_INSTALL_DIR)" \
	)
endef

$(eval $(call PyPackage,python-dpkt))
$(eval $(call BuildPackage,python-dpkt))
