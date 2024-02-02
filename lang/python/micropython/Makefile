#
# Copyright (C) 2008-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=micropython
PKG_VERSION:=1.21.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_SOURCE_URL:=https://github.com/micropython/micropython/releases/download/v$(PKG_VERSION)
PKG_HASH:=abd2152613559d3f44728668346e78be9d93458133a03b700baf222c322fd4d5

PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:micropython:micropython

PKG_BUILD_DEPENDS:=python3/host
PKG_BUILD_FLAGS:=no-mips16
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk

define Package/micropython/Default
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=MicroPython
  URL:=https://micropython.org
  DEPENDS:=+libffi
  PROVIDES:=micropython
endef

define Package/micropython-mbedtls
$(call Package/micropython/Default)
  TITLE+= (mbedtls)
  DEPENDS+= +PACKAGE_micropython-mbedtls:libmbedtls
  CONFLICTS:=micropython-nossl
  VARIANT:=mbedtls
  DEFAULT_VARIANT:=1
endef

define Package/micropython-nossl
$(call Package/micropython/Default)
  TITLE+= (nossl)
  VARIANT:=nossl
endef

define Package/micropython/Default/description
MicroPython is a lean and efficient implementation of the Python 3
programming language that includes a small subset of the Python standard
library and is optimised to run on microcontrollers and in constrained
environments.
endef

define Package/micropython-mbedtls/description
$(call Package/micropython/Default/description)

This version uses the Mbed TLS library.
endef

define Package/micropython-nossl/description
$(call Package/micropython/Default/description)

This version is built without TLS and mip.
endef

MAKE_FLAGS += BUILD_VERBOSE=1 STRIP=

ifneq ($(CONFIG_DEBUG),)
  MAKE_FLAGS += DEBUG=1
endif

ifeq ($(BUILD_VARIANT),nossl)
  MAKE_FLAGS += MICROPY_PY_SSL=0 FROZEN_MANIFEST=variants/standard/manifest-nossl.py
endif

# Work around "variable might be clobbered" warning leading to build error
# https://github.com/micropython/micropython/issues/12838
ifeq ($(ARCH),riscv64)
  MAKE_FLAGS += CFLAGS_EXTRA=-Wno-error=clobbered
endif

MAKE_PATH = ports/unix

define Build/Configure
	+$(HOST_MAKE_VARS) \
	$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR)/mpy-cross \
		$(HOST_MAKE_FLAGS) BUILD_VERBOSE=1
endef

define Build/InstallDev
	$(INSTALL_DIR) $(2)/lib/micropython/mpy-cross
	$(CP) \
		$(PKG_BUILD_DIR)/mpy-cross/mpy_cross \
		$(2)/lib/micropython/mpy-cross/

	$(INSTALL_DIR) $(2)/lib/micropython/mpy-cross/build
	$(INSTALL_BIN) \
		$(PKG_BUILD_DIR)/mpy-cross/build/mpy-cross \
		$(2)/lib/micropython/mpy-cross/build/

	$(INSTALL_DIR) $(2)/lib/micropython/tools
	$(INSTALL_DATA) \
		$(PKG_BUILD_DIR)/tools/manifestfile.py \
		$(2)/lib/micropython/tools/
endef

define Package/micropython/Default/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ports/unix/build-standard/micropython $(1)/usr/bin/
endef

Package/micropython-mbedtls/install = $(Package/micropython/Default/install)
Package/micropython-nossl/install = $(Package/micropython/Default/install)

$(eval $(call BuildPackage,micropython-mbedtls))
$(eval $(call BuildPackage,micropython-nossl))
