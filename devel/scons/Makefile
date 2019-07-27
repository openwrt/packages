#
# Copyright (C) 2011-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=scons
PKG_VERSION:=3.1.1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/scons \
		https://fossies.org/linux/misc/
PKG_HASH:=4cea417fdd7499a36f407923d03b4b7000b0f9e8fd7b31b316b9ce7eba9143a5

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

define Package/scons
  SECTION:=devel
  CATEGORY:=Development
  TITLE:=scons
  HIDDEN:=1
endef

define Package/scons/description
  SCons is an Open Source software construction tool—that is, a
  next-generation build tool. Think of SCons as an improved, cross-platform
  substitute for the classic Make utility with integrated functionality
  similar to autoconf/automake and compiler caches such as ccache. In short,
  SCons is an easier, more reliable and faster way to build software.
endef

define Host/Configure
endef

define Host/Compile
endef

define Host/Install
	./files/pywrap.sh $(HOST_BUILD_DIR)/setup.py install --prefix=$(STAGING_DIR_HOST)
	rm -f $(STAGING_DIR_HOST)/bin/scons*.py
	for bin in $(STAGING_DIR_HOST)/bin/scons*; do \
		mv "$$$$bin" "$$$$bin.py";                \
		cp ./files/pywrap.sh "$$$$bin";           \
	done
endef

$(eval $(call BuildPackage,scons))
$(eval $(call HostBuild))
