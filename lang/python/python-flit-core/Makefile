#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-flit-core
PKG_VERSION:=3.12.0
PKG_RELEASE:=1

PYPI_NAME:=flit-core
PYPI_SOURCE_NAME:=flit_core
PKG_HASH:=18f63100d6f94385c6ed57a72073443e1a71a4acb4339491615d0f16d6ff01b2

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>

PKG_HOST_ONLY:=1
HOST_BUILD_DEPENDS:=python3/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-flit-core
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Distribution-building parts of Flit
  URL:=https://github.com/pypa/flit
  DEPENDS:=+python3-light +python3-email +python3-logging
  BUILDONLY:=1
endef

define Package/python3-flit-core/description
This provides a PEP 517 build backend for packages using Flit. The only
public interface is the API specified by PEP 517, at flit_core.buildapi.
endef

define Py3Host/Install/Installer
	$(call HostPython3/Run, \
		$(HOST_BUILD_DIR), \
		bootstrap_install.py \
			--installdir "$(1)/lib/python$(PYTHON3_VERSION)/site-packages" \
			"$(PYTHON3_HOST_BUILD_DIR)"/openwrt-build/$(PYPI_SOURCE_NAME)-$(PKG_VERSION)-*.whl \
	)
endef

Host/Compile=$(Py3Host/Compile/Bootstrap)

$(eval $(call Py3Package,python3-flit-core))
$(eval $(call BuildPackage,python3-flit-core))
$(eval $(call BuildPackage,python3-flit-core-src))
$(eval $(call HostBuild))
