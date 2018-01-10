#
# Copyright (C) 2016 Yousong Zhou <yszhou4tech@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=python-packages
PKG_VERSION:=1.0
PKG_RELEASE:=1

PKG_MAINTAINER:=Yousong Zhou <yszhou4tech@gmail.com>

#
# NOTE: move the host module installation to Host/Compile when
# HOST_CONFIG_DEPENDS is supported
#
# NOTE: PKG_CONFIG_DEPENDS cannot correctly track changes of string type config
# options, so you may want to do manual cleanup on config change.
#
PKG_CONFIG_DEPENDS:= \
	CONFIG_PACKAGE_python-packages-list-host \
	CONFIG_PACKAGE_python-packages-list \
	CONFIG_PACKAGE_python-packages-list-cleanup \
	CONFIG_PACKAGE_python-packages-envs \
	CONFIG_PACKAGE_python-packages-extra-deps \
	CONFIG_PACKAGE_python-packages-index-url \
	CONFIG_PACKAGE_python-packages-pip-opts \

PKG_BUILD_DEPENDS:=python python/host

include $(INCLUDE_DIR)/package.mk
include ../python-package.mk

define Package/python-packages
  SUBMENU:=Python
  SECTION:=lang
  CATEGORY:=Languages
  TITLE:=A dummy package for packaging python modules with pip
  DEPENDS:=@DEVEL +python
endef

define Package/python-packages/config
if PACKAGE_python-packages
config PACKAGE_python-packages-list-host
	string "List of python packages to install on host"
config PACKAGE_python-packages-list
	string "List of python packages to install on target"
config PACKAGE_python-packages-list-cleanup
	string "List of python packages to cleanup to avoid clash with existing packages"
config PACKAGE_python-packages-envs
	string "Extra environment variables to pass on to pip and its children on target build"
config PACKAGE_python-packages-extra-deps
	string "List of deps fulfilled but not tracked by the build system"
config PACKAGE_python-packages-index-url
	string "Index URL passed to pip with --index-url"
config PACKAGE_python-packages-pip-opts
	string "Additional arguments to pip command line"
endif
endef

CONFIG_PACKAGE_python-packages-list-host:=$(call qstrip,$(CONFIG_PACKAGE_python-packages-list-host))
CONFIG_PACKAGE_python-packages-list:=$(call qstrip,$(CONFIG_PACKAGE_python-packages-list))
CONFIG_PACKAGE_python-packages-list-cleanup:=$(call qstrip,$(CONFIG_PACKAGE_python-packages-list-cleanup))
CONFIG_PACKAGE_python-packages-envs:=$(call qstrip,$(CONFIG_PACKAGE_python-packages-envs))
CONFIG_PACKAGE_python-packages-extra-deps:=$(call qstrip,$(CONFIG_PACKAGE_python-packages-extra-deps))
CONFIG_PACKAGE_python-packages-pip-opts:=$(call qstrip,$(CONFIG_PACKAGE_python-packages-pip-opts))

HOST_PYTHON_PIP:=$(STAGING_DIR_HOSTPKG)/bin/pip$(PYTHON_VERSION)

decr=$(word $(1),0 1 2 3 4 5 6 7 8 9 10)
recur=$(if $(subst 0,,$(2)),$(call recur,$(1),$(call decr,$(2)),$(call $(1)$(2),$(3))),$(3))
_req2dir1=$(subst >,gt,$(1))
_req2dir2=$(subst <,lt,$(1))
_req2dir3=$(subst >=,geq,$(1))
_req2dir4=$(subst <=,leq,$(1))
_req2dir5=$(subst ://,:::,$(1))
_req2dir6=$(subst *,_,$(1))
_req2dir7=$(subst ?,_,$(1))
req2dir=$(call recur,_req2dir,7,$(1))

# --ignore-installed, it may happen that host pip will ignore target install if
#  it was already installed as host module, e.g. cffi deps of cryptograph
HOST_PYTHON_PIP_INSTALL=$(HOST_PYTHON_PIP) install \
	--root=$(1) \
	--prefix=$(2) \
	--ignore-installed \
	--no-compile \
	$(if $(CONFIG_PACKAGE_python-packages-index-url), --index-url $(CONFIG_PACKAGE_python-packages-index-url)) \
	$(if $(CONFIG_PACKAGE_python-packages-pip-opts), $(CONFIG_PACKAGE_python-packages-pip-opts)) \

HOST_PYTHON_PIP_INSTALL_HOST:=$(call HOST_PYTHON_PIP_INSTALL,$(STAGING_DIR_HOSTPKG),"")
HOST_PYTHON_PIP_INSTALL_TARGET=$(call HOST_PYTHON_PIP_INSTALL,$(PKG_INSTALL_DIR)/$(call req2dir,$(pkg)),/usr)
HOST_PYTHON_PIP_INSTALL_CLEANUP:=$(call HOST_PYTHON_PIP_INSTALL,$(PKG_INSTALL_DIR)/_cleanup,/usr)

define Build/Compile
	$(foreach pkg,$(CONFIG_PACKAGE_python-packages-list-host),
		$(call Build/Compile/HostPyRunHost,,$(HOST_PYTHON_PIP_INSTALL_HOST) $(pkg))
	)
	$(foreach pkg,$(CONFIG_PACKAGE_python-packages-list),
		$(call Build/Compile/HostPyRunTarget,,$(call HOST_PYTHON_PIP_INSTALL_TARGET,$(pkg)) $(pkg),$(CONFIG_PACKAGE_python-packages-envs))
	)
	$(foreach pkg,$(CONFIG_PACKAGE_python-packages-list-cleanup),
		$(call Build/Compile/HostPyRunTarget,,$(HOST_PYTHON_PIP_INSTALL_CLEANUP) $(pkg),$(CONFIG_PACKAGE_python-packages-envs))
	)
endef

define Package/python-packages/install
	$(foreach pkg,$(CONFIG_PACKAGE_python-packages-list),
		$(CP) "$(PKG_INSTALL_DIR)/$(call req2dir,$(pkg))"/* $(1)
	)

	find "$(PKG_INSTALL_DIR)/_cleanup" -mindepth 1 -depth | while read sf; do \
		tf="$$$${sf#$(PKG_INSTALL_DIR)/_cleanup/}"; \
		tf="$(1)/$$$$tf"; \
		if [ -f "$$$$tf" -o -L "$$$$tf" ]; then \
			rm -vf "$$$$tf"; \
		elif [ -d "$$$$tf" ]; then \
			rmdir -v -p "$$$$tf" || true; \
		fi \
	done
endef

define Package/python-packages/extra_provides
	echo $(CONFIG_PACKAGE_python-packages-extra-deps) | tr ' ' '\n'
endef

$(eval $(call BuildPackage,python-packages))
