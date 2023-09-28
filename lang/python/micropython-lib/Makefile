#
# Copyright (C) 2008-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=micropython-lib
PKG_RELEASE:=2

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/micropython/micropython-lib.git
PKG_SOURCE_VERSION:=7128d423c2e7c0309ac17a1e6ba873b909b24fcc
PKG_SOURCE_DATE:=20230522
PKG_MIRROR_HASH:=1f094aac257d2094ee91b457164f845f6461df1cf1d0ed7ee556c98f273f5afb

PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>
PKG_LICENSE:=MIT Python-2.0.1
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=python3/host
PKG_BUILD_PARALLEL:=1

# keep in sync with micropython
MP_VERSION:=1.20.0
MP_MPY_FILE_VERSION:=6

include $(INCLUDE_DIR)/package.mk

define Package/micropython-lib/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=MicroPython package repository
  URL:=https://github.com/micropython/micropython-lib
endef

define Package/micropython-lib
$(call Package/micropython-lib/Default)
  DEPENDS:=+micropython
endef

define Package/micropython-lib-src
$(call Package/micropython-lib/Default)
  TITLE+= (sources)
endef

define Package/micropython-lib-unix
$(call Package/micropython-lib/Default)
  TITLE+= - Unix port packages
  DEPENDS:=+micropython +libpcre2 +librt +libsqlite3
endef

define Package/micropython-lib-unix-src
$(call Package/micropython-lib/Default)
  TITLE+= - Unix port packages (sources)
endef

define Package/micropython-lib/Default/description
This is a repository of packages designed to be useful for writing
MicroPython applications.
endef

define Package/micropython-lib/description
$(call Package/micropython-lib/Default/description)

This contains packages common to all MicroPython ports.
endef

define Package/micropython-lib-src/description
$(call Package/micropython-lib/Default/description)

This contains source files for packages common to all MicroPython ports.
endef

define Package/micropython-lib-unix/description
$(call Package/micropython-lib/Default/description)

This contains packages specific to the MicroPython Unix port.
endef

define Package/micropython-lib-unix-src/description
$(call Package/micropython-lib/Default/description)

This contains source files for packages specific to the MicroPython Unix
port.
endef

MP_INSTALLDEV_PATH:=$(STAGING_DIR)/host/lib/micropython-$(MP_VERSION)

define MicroPythonLib/Compile
	cd "$(PKG_BUILD_DIR)" && python3 tools/build.py \
		--hash-prefix 64 \
		--micropython "$(MP_INSTALLDEV_PATH)" \
		--mpy-cross "$(MP_INSTALLDEV_PATH)/mpy-cross/build/mpy-cross" \
		--output "$(PKG_BUILD_DIR)/$(strip $(1))" \
		$(2)
endef

define MicroPythonLib/Install
	python3 install.py \
		--input "$(PKG_BUILD_DIR)/$(strip $(1))" \
		--output "$(strip $(3))" \
		--version "$(strip $(2))"
endef

define Build/Compile
	$(call MicroPythonLib/Compile)
	$(call MicroPythonLib/Compile,unix-ffi-index,--unix-ffi)
endef

define Package/micropython-lib/install
	$(call MicroPythonLib/Install,,$(MP_MPY_FILE_VERSION),$(1)/usr/lib/micropython)
endef

define Package/micropython-lib-src/install
	$(call MicroPythonLib/Install,,py,$(1)/usr/lib/micropython)
endef

define Package/micropython-lib-unix/install
	$(call MicroPythonLib/Install,unix-ffi-index,$(MP_MPY_FILE_VERSION),$(1)/usr/lib/micropython/unix)

	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/micropython-unix $(1)/usr/bin/
endef

define Package/micropython-lib-unix-src/install
	$(call MicroPythonLib/Install,unix-ffi-index,py,$(1)/usr/lib/micropython/unix)
endef

$(eval $(call BuildPackage,micropython-lib))
$(eval $(call BuildPackage,micropython-lib-src))
$(eval $(call BuildPackage,micropython-lib-unix))
$(eval $(call BuildPackage,micropython-lib-unix-src))
