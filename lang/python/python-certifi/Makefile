#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-certifi
PKG_VERSION:=2026.1.4
PKG_RELEASE:=1

PKG_MAINTAINER:=Eneas U de Queiroz <cotequeiroz@gmail.com>
PKG_LICENSE:=MPL-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:certifi:certifi

PYPI_NAME:=certifi
PKG_HASH:=ac726dd470482006e014ad384921ed6438c457018f4b3d204aea4281258b2120

HOST_BUILD_DEPENDS:= \
	python3/host \
	python-build/host \
	python-installer/host \
	python-wheel/host \
	python-setuptools/host
PKG_BUILD_DEPENDS:=python-setuptools/host

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk
include ../python3-package.mk
include ../python3-host-build.mk

define Package/python3-certifi
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=Python package for Mozilla's CA Bundle
  URL:=https://github.com/certifi/python-certifi
  DEPENDS:=+python3-light +python3-urllib
endef

define Package/python3-certifi/description
Certifi provides Mozilla's carefully curated collection of Root
Certificates for validating the trustworthiness of SSL certificates
while verifying the identity of TLS hosts.
endef

$(eval $(call Py3Package,python3-certifi))
$(eval $(call BuildPackage,python3-certifi))
$(eval $(call BuildPackage,python3-certifi-src))
$(eval $(call HostBuild))
