# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-jinja2
PKG_VERSION:=3.1.6
PKG_RELEASE:=1

PYPI_NAME:=Jinja2
PYPI_SOURCE_NAME:=jinja2
PKG_HASH:=0137fb05990d35f1275a587e9aee6d56da821fc83491a0fb838183be43f66d6d

PKG_MAINTAINER:=Michal Vasilek <michal.vasilek@nic.cz>
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE.rst
PKG_CPE_ID:=cpe:/a:pocoo:jinja2
HOST_BUILD_DEPENDS:= python-markupsafe/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-jinja2
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Very fast and expressive template engine
  URL:=https://palletsprojects.com/p/jinja/
  DEPENDS:= \
      +python3-light \
      +python3-asyncio \
      +python3-logging \
      +python3-urllib \
      +python3-markupsafe
endef

define Package/python3-jinja2/description
Jinja2 is a full featured template engine for Python. It has full
unicode support, an optional integrated sandboxed execution
environment, widely used and BSD licensed.
endef

$(eval $(call Py3Package,python3-jinja2))
$(eval $(call BuildPackage,python3-jinja2))
$(eval $(call BuildPackage,python3-jinja2-src))
$(eval $(call HostBuild))
