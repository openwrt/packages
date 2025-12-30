# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pypubsub
PKG_VERSION:=4.0.7
PKG_RELEASE:=1

PYPI_NAME:=Pypubsub
PYPI_SOURCE_NAME:=pypubsub
PKG_HASH:=ec8b5cb147624958320e992602380cc5d0e4b36b1c59844d05e425a3003c09dc

PKG_BUILD_DEPENDS:=python-setuptools/host

PKG_MAINTAINER:=Austin Lane <vidplace7@gmail.com>
PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=src/pubsub/LICENSE_BSD_Simple.txt

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

define Package/python3-pypubsub
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Python Publish-Subscribe Package
  URL:=https://pypi.org/project/pypubsub
  DEPENDS:=+python3-light +python3-xml
endef

define Package/python3-pypubsub/description
Provides a publish-subscribe API to facilitate event-based or
message-based architecture in a single-process application.
endef

$(eval $(call Py3Package,python3-pypubsub))
$(eval $(call BuildPackage,python3-pypubsub))
