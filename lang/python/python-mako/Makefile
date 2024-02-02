#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-mako
PKG_VERSION:=1.2.4
PKG_RELEASE:=1

PYPI_NAME:=Mako
PKG_HASH:=d60a3903dc3bb01a18ad6a89cdbe2e4eadc69c0bc8ef1e3773ba53d44c3f7a34

PKG_MAINTAINER:=Jeffery To <jeffery.to@gmail.com>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:sqlalchemy:mako

PKG_HOST_ONLY:=1
HOST_BUILD_DEPENDS:= \
	python3/host \
	python-build/host \
	python-installer/host \
	python-wheel/host \
	python-markupsafe/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-mako
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Super-fast templating language
  URL:=https://www.makotemplates.org/
  DEPENDS:=+python3-light +python3-urllib +python3-markupsafe
  BUILDONLY:=1
endef

define Package/python3-mako/description
Mako is a template library written in Python. It provides a familiar,
non-XML syntax which compiles into Python modules for maximum
performance. Mako's syntax and API borrows from the best ideas of many
others, including Django templates, Cheetah, Myghty, and Genshi.
Conceptually, Mako is an embedded Python (i.e. Python Server Page)
language, which refines the familiar ideas of componentized layout and
inheritance to produce one of the most straightforward and flexible
models available, while also maintaining close ties to Python calling
and scoping semantics.
endef

$(eval $(call Py3Package,python3-mako))
$(eval $(call BuildPackage,python3-mako))
$(eval $(call BuildPackage,python3-mako-src))
$(eval $(call HostBuild))
