#
# Copyright (C) 2019 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-posix_ipc
PKG_VERSION:=1.0.4
PKG_RELEASE:=1

PKG_SOURCE:=posix_ipc-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://semanchuk.com/philip/posix_ipc/
PKG_HASH:=ff6c9077633fc62a491d6997c43b094d885bb45a7ca1f36c9a0d647c54b74b14

PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-posix_ipc-$(PKG_VERSION)

PKG_LICENSE:=BSD License
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Jakub Piotr Cłapa <jpc@loee.pl>

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk
include ../python3-package.mk

PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)

define Package/python-posix_ipc/Default
  SECTION:=lang-python
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=http://www.pycrypto.org/
endef

define Package/python-posix_ipc
$(call Package/python-posix_ipc/Default)
  TITLE:=python-posix_ipc
  DEPENDS:=+python-light
  VARIANT:=python
endef

define Package/python3-posix_ipc
$(call Package/python-posix_ipc/Default)
  TITLE:=python3-posix_ipc
  DEPENDS:=+python3-light
  VARIANT:=python3
endef

define Package/python-posix_ipc/description
The Python extension module posix_ipc gives Python access to POSIX inter-process
semaphores, shared memory and message queues
endef

define Package/python3-posix_ipc/description
$(call Package/python-posix_ipc/description)
.
(Variant for Python3)
endef

$(eval $(call PyPackage,python-posix_ipc))
$(eval $(call BuildPackage,python-posix_ipc))
$(eval $(call BuildPackage,python-posix_ipc-src))

$(eval $(call Py3Package,python3-posix_ipc))
$(eval $(call BuildPackage,python3-posix_ipc))
$(eval $(call BuildPackage,python3-posix_ipc-src))
