#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=selinux-python
PKG_VERSION:=3.9
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/SELinuxProject/selinux/releases/download/$(PKG_VERSION)
PKG_HASH:=dcfa5f1919dcb7e7b775851994eb5c83b7580dc496cd2d1f73867dfa074d2339

PKG_MAINTAINER:=Thomas Petazzoni <thomas.petazzoni@bootlin.com>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1
PYTHON3_PKG_BUILD:=0

include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python3-package.mk

#
# common definitions
#

define Package/selinux-python/Default
  URL:=https://github.com/selinuxproject
  DEPENDS:=+python3-light
endef

define Package/selinux-python/Default/python
$(call Package/selinux-python/Default)
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
endef

define Package/selinux-python/Default/util
$(call Package/selinux-python/Default)
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=SELinux management utility
endef

define Package/selinux-python/Default/description
A set of SELinux tools written in Python that help with managing a
system with SELinux enabled.
endef

MAKE_VARS = \
	$(PYTHON3_VARS) \
	$(HOST_PYTHON3_PIP_VARS) \
	PYTHON_SETUP_ARGS=--no-compile

define Build/Compile
	$(call Build/Compile/Default,all)
endef

#
# python3-seobject
#

define Package/python3-seobject
$(call Package/selinux-python/Default/python)
  TITLE:=SELinux seobject library
  DEPENDS+= +python3-selinux +python3-semanage +python3-sepolicy +python3-setools
endef

define Package/python3-seobject/description
$(call Package/selinux-python/Default/description)

This package contains the seobject library.
endef

define Py3Package/python3-seobject/filespec
+|$(PYTHON3_PKG_DIR)/seobject.py
endef

Py3Package/python3-seobject/install:=:

#
# python3-sepolgen
#

define Package/python3-sepolgen
$(call Package/selinux-python/Default/python)
  TITLE:=SELinux policy generation library
  DEPENDS+= +python3-selinux
endef

define Package/python3-sepolgen/description
$(call Package/selinux-python/Default/description)

This package contains the SELinux policy generation Python library.
endef

define Package/python3-sepolgen/conffiles
/etc/sepolgen/
endef

define Py3Package/python3-sepolgen/filespec
+|$(PYTHON3_PKG_DIR)/sepolgen
endef

define Py3Package/python3-sepolgen/install
	$(INSTALL_DIR) $(1)/etc/sepolgen
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/var/lib/sepolgen/perm_map $(1)/etc/sepolgen/
endef

#
# python3-sepolicy
#

define Package/python3-sepolicy
$(call Package/selinux-python/Default/python)
  TITLE:=SELinux Policy Analyses binding
  DEPENDS+= +python3-selinux +python3-sepolgen +python3-xml +python3-setools
endef

define Package/python3-sepolicy/description
$(call Package/selinux-python/Default/description)

This package contains a Python binding for SELinux Policy Analyses.
endef

define Py3Package/python3-sepolicy/filespec
+|$(PYTHON3_PKG_DIR)/sepolicy
-|$(PYTHON3_PKG_DIR)/sepolicy/gui.py
-|$(PYTHON3_PKG_DIR)/sepolicy/sedbus.py
+|$(PYTHON3_PKG_DIR)/sepolicy-$(PKG_VERSION).dist-info
endef

Py3Package/python3-sepolicy/install:=:

#
# selinux-audit2allow
#

define Package/selinux-audit2allow
$(call Package/selinux-python/Default/util)
  TITLE+= audit2allow
  DEPENDS+= +python3-selinux +python3-sepolgen
endef

define Package/selinux-audit2allow/description
$(call Package/selinux-python/Default/description)

This package contains the audit2allow and audit2why tools.
endef

define Package/selinux-audit2allow/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/audit2allow $(1)/usr/bin/
	$(LN) audit2allow $(1)/usr/bin/audit2why
endef

#
# selinux-chchat
#

define Package/selinux-chcat
$(call Package/selinux-python/Default/util)
  TITLE+= chcat
  DEPENDS+= +python3-selinux +python3-seobject +selinux-semanage
endef

define Package/selinux-chcat/description
$(call Package/selinux-python/Default/description)

This package contains the chcat tool.
endef

define Package/selinux-chcat/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/chcat $(1)/usr/bin/
endef

#
# selinux-python
#

define Package/selinux-python
$(call Package/selinux-python/Default/util)
  TITLE+= meta-package
  DEPENDS:= \
    +selinux-audit2allow \
    +selinux-chcat \
    +selinux-semanage \
    +selinux-sepolgen-ifgen \
    +selinux-sepolicy
endef

define Package/selinux-python/description
$(call Package/selinux-python/Default/description)

This is a meta-package that installs all of the SELinux management
utilities.
endef

Package/selinux-python/install:=:

#
# selinux-semanage
#

define Package/selinux-semanage
$(call Package/selinux-python/Default/util)
  TITLE+= semanage
  DEPENDS+= +python3-seobject
endef

define Package/selinux-semanage/description
$(call Package/selinux-python/Default/description)

This package contains the semanage tool.
endef

define Package/selinux-semanage/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/semanage $(1)/usr/sbin/
endef

#
# selinux-sepolgen-ifgen
#

define Package/selinux-sepolgen-ifgen
$(call Package/selinux-python/Default/util)
  TITLE+= sepolgen-ifgen
  DEPENDS+= +python3-selinux +python3-sepolgen +libselinux
endef

define Package/selinux-sepolgen-iften/description
$(call Package/selinux-python/Default/description)

This package contains the sepolgen-ifgen tool.
endef

define Package/selinux-sepolgen-ifgen/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/sepolgen-ifgen $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/sepolgen-ifgen-attr-helper $(1)/usr/bin/
endef

#
# selinux-sepolicy
#

define Package/selinux-sepolicy
$(call Package/selinux-python/Default/util)
  TITLE+= sepolicy
  DEPENDS+= +python3-multiprocessing +python3-selinux +python3-sepolicy
endef

define Package/selinux-sepolicy/description
$(call Package/selinux-python/Default/description)

This package contains the sepolicy and sepolgen tools.
endef

define Package/selinux-sepolicy/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/sepolicy $(1)/usr/bin/
	$(LN) sepolicy $(1)/usr/bin/sepolgen
endef

$(eval $(call Py3Package,python3-seobject))
$(eval $(call Py3Package,python3-sepolgen))
$(eval $(call Py3Package,python3-sepolicy))

$(eval $(call BuildPackage,python3-seobject))
$(eval $(call BuildPackage,python3-sepolgen))
$(eval $(call BuildPackage,python3-sepolicy))

$(eval $(call BuildPackage,python3-seobject-src))
$(eval $(call BuildPackage,python3-sepolgen-src))
$(eval $(call BuildPackage,python3-sepolicy-src))

$(eval $(call BuildPackage,selinux-audit2allow))
$(eval $(call BuildPackage,selinux-chcat))
$(eval $(call BuildPackage,selinux-python))
$(eval $(call BuildPackage,selinux-semanage))
$(eval $(call BuildPackage,selinux-sepolgen-ifgen))
$(eval $(call BuildPackage,selinux-sepolicy))
