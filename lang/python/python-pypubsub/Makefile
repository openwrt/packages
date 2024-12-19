# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-pypubsub
PKG_VERSION:=4.0.3
PKG_RELEASE:=1

PYTHON3_PKG_WHEEL_NAME:=Pypubsub

PKG_SOURCE:=pypubsub-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/schollii/pypubsub/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=0df83daa1cb0021bab858ff6812d836c9712dea59a5172be1888bb554c3a89a2
PKG_BUILD_DIR:=$(BUILD_DIR)/pypubsub-$(PKG_VERSION)

PKG_MAINTAINER:=Austin Lane <vidplace7@gmail.com>
PKG_LICENSE:=BSD-2-Clause
PKG_LICENSE_FILES:=src/pubsub/LICENSE_BSD_Simple.txt

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
