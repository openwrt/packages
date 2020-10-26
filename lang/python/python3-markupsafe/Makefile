# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=MarkupSafe
PKG_VERSION:=1.1.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://files.pythonhosted.org/packages/source/M/MarkupSafe
PKG_HASH:=29872e92839765e546828bb7754a68c418d927cd064fd4708fab9fe9c8bb116b
PKG_BUILD_DEPENDS:=python python3
PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=John Crispin <john@phrozen.org>

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-$(PKG_NAME)-$(PKG_VERSION)
PKG_UNPACK=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)
HOST_BUILD_DEPENDS:=python3/host

include $(TOPDIR)/feeds/packages/lang/python/pypi.mk
include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include $(TOPDIR)/feeds/packages/lang/python/python3-package.mk

define Package/python3-markupsafe
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://github.com/pallets/markupsafe/
  TITLE:=python3-markupsafe
endef

define Package/python3-markupsafe/description
MarkupSafe implements a XML/HTML/XHTML Markup safe string for Python
endef

define Host/Compile
	$(call HostPython3/ModSetup,,install --prefix="" --root="$(STAGING_DIR_HOSTPKG)")
endef

Host/Install:=

$(eval $(call HostBuild))

$(eval $(call Py3Package,python3-markupsafe))
$(eval $(call BuildPackage,python3-markupsafe))
