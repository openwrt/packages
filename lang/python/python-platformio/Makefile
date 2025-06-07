# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-platformio
PKG_VERSION:=6.1.18
PKG_RELEASE:=1

PYPI_NAME:=platformio
PKG_HASH:=6ea19c66fba3c5272378afa6ae11abbf883243dd8e503ac5f4ff8ac277ccc7c6

PKG_MAINTAINER:=Austin Lane <vidplace7@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_HOST_ONLY:=1
HOST_BUILD_DEPENDS:= \
	python3/host \
	python-build/host \
	python-installer/host \
	python-pyserial/host \
	python-click/host \
	python-semantic-version/host \
	python-requests/host \
	python-tabulate/host \
	python-pyelftools/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-platformio
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=PlatformIO Host Tools
  URL:=https://github.com/platformio/platformio-core
  BUILDONLY:=1
  DEPENDS:= \
	+python3-light \
	+python3-pyserial \
	+python3-click \
	+python3-semantic-version \
	+python3-requests \
	+python3-tabulate \
	+python3-pyelftools
endef

define Package/python3-platformio/description
PlatformIO is an open-source build system for embedded development,
supporting multiple platforms, frameworks, and boards
with features like dependency management and IDE integration.
endef

$(eval $(call Py3Package,python3-platformio))
$(eval $(call BuildPackage,python3-platformio))
$(eval $(call HostBuild))
