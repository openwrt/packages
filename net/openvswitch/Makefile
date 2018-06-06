#
# Copyright (C) 2013 Julius Schulz-Zander <julius@net.t-labs.tu-berlin.de>
# Copyright (C) 2014-2017 OpenWrt.org
# Copyright (C) 2018 Yousong Zhou <yszhou4tech@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=openvswitch
PKG_VERSION:=2.9.2
PKG_RELEASE:=2
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.openvswitch.org/releases/
PKG_HASH:=90f084dc282fdb588a2cfff351fea359492f69600f1e4a1286e24e44901de113

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=python/host python-six/host
PKG_USE_MIPS16:=0
PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

PKG_MAINTAINER:=Yousong Zhou <yszhou4tech@gmail.com>

include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python-host.mk
include ../../lang/python/python-package.mk


CONFIGURE_ARGS+= \
	--enable-ndebug \
	--enable-shared \
	--disable-libcapng \

CONFIGURE_VARS += \
	ovs_cv_flake8=no \
	ovs_cv_python3=no \
	ovs_cv_sphinx=no \
	ovs_cv_python=$(PYTHON) \
	ovs_cv_python_host=$(HOST_PYTHON_BIN) \

TARGET_CFLAGS += -flto -std=gnu99
MAKE_VARS += PYTHONPATH="$(HOST_PYTHONPATH)"


define KernelPackage/openvswitch
  SECTION:=kernel
  CATEGORY:=Kernel modules
  SUBMENU:=Network Support
  TITLE:=Open vSwitch kernel datapath
  KCONFIG:=CONFIG_OPENVSWITCH
  DEPENDS:= \
	+kmod-lib-crc32c +kmod-mpls \
	+kmod-nf-nat +IPV6:kmod-nf-nat6
  FILES:= $(LINUX_DIR)/net/openvswitch/openvswitch.ko
  AUTOLOAD:=$(call AutoProbe,openvswitch)
endef

define KernelPackage/openvswitch-gre
  SECTION:=kernel
  CATEGORY:=Kernel modules
  SUBMENU:=Network Support
  TITLE:=Open vSwitch GRE tunneling support
  KCONFIG:= CONFIG_OPENVSWITCH_GRE
  DEPENDS:= +kmod-openvswitch +kmod-gre
  FILES:= $(LINUX_DIR)/net/openvswitch/vport-gre.ko
  AUTOLOAD:=$(call AutoProbe,vport-gre)
endef

define KernelPackage/openvswitch-vxlan
  SECTION:=kernel
  CATEGORY:=Kernel modules
  SUBMENU:=Network Support
  TITLE:=Open vSwitch VXLAN tunneling support
  KCONFIG:= CONFIG_OPENVSWITCH_VXLAN
  DEPENDS:= +kmod-openvswitch +kmod-vxlan
  FILES:= $(LINUX_DIR)/net/openvswitch/vport-vxlan.ko
  AUTOLOAD:=$(call AutoProbe,vport-vxlan)
endef

define KernelPackage/openvswitch-geneve
  SECTION:=kernel
  CATEGORY:=Kernel modules
  SUBMENU:=Network Support
  TITLE:=Open vSwitch Geneve tunneling support
  KCONFIG:= CONFIG_OPENVSWITCH_GENEVE
  DEPENDS:= +kmod-openvswitch +kmod-geneve
  FILES:= $(LINUX_DIR)/net/openvswitch/vport-geneve.ko
  AUTOLOAD:=$(call AutoProbe,vport-geneve)
endef


ovs_packages:=
ovs_package_name=$(if $(filter openvswitch,$(1)),openvswitch,openvswitch-$(1))
define OvsPackageTemplate
  define Package/$(call ovs_package_name,$(1))
     SECTION:=net
     SUBMENU:=Open vSwitch
     CATEGORY:=Network
     URL:=https://www.openvswitch.org
     TITLE:=$(ovs_$(1)_title)
     HIDDEN:=$(ovs_$(1)_hidden)
     DEPENDS:=$(ovs_$(1)_depends)
  endef

  define Package/$(call ovs_package_name,$(1))/install
	$(foreach f,$(ovs_$(1)_files),
		$(INSTALL_DIR) $$(1)/$(dir $(f))
		$(CP) $(PKG_INSTALL_DIR)/$(f) $$(1)/$(dir $(f))
	)
	$(ovs_$(1)_install)
  endef

  ovs_packages+=$(call ovs_package_name,$(1))
endef

# Dependency review
#
#	for f in sbin/*;   do echo $f; readelf -d $f | grep -i shared; done
#	for f in bin/*;    do echo $f; readelf -d $f | grep -i shared; done
#	for f in lib/*.so; do echo $f; readelf -d $f | grep -i shared; done
#
ovs_libopenvswitch_title:=Open vSwitch (libopenvswitch.so)
ovs_libopenvswitch_hidden:=1
ovs_libopenvswitch_depends:=+libopenssl +librt
ovs_libopenvswitch_files:=usr/lib/libopenvswitch*.so*
$(eval $(call OvsPackageTemplate,libopenvswitch))


ovs_libofproto_title:=Open vSwitch (libofproto.so libsflow.so)
ovs_libofproto_hidden:=1
ovs_libofproto_depends:=+librt
ovs_libofproto_files:=usr/lib/libofproto*.so* usr/lib/libsflow*.so*
$(eval $(call OvsPackageTemplate,libofproto))


ovs_libovsdb_title:=Open vSwitch (libovsdb.so)
ovs_libovsdb_hidden:=1
ovs_libovsdb_depends:=+librt
ovs_libovsdb_files:=usr/lib/libovsdb*.so*
$(eval $(call OvsPackageTemplate,libovsdb))


ovs_libovn_title:=Open vSwitch (libovn.so)
ovs_libovn_hidden:=1
ovs_libovn_depends:=+librt
ovs_libovn_files:=usr/lib/libovn*.so*
$(eval $(call OvsPackageTemplate,libovn))


ovs_vswitchd_title:=Open vSwitch (ovs-vswitchd)
ovs_vswitchd_hidden:=1
ovs_vswitchd_depends:=+librt +openvswitch-libopenvswitch +openvswitch-libofproto
ovs_vswitchd_files:=usr/sbin/ovs-vswitchd
$(eval $(call OvsPackageTemplate,vswitchd))


ovs_ovsdb_title:=Open vSwitch (ovsdb-server)
ovs_ovsdb_hidden:=1
ovs_ovsdb_depends:=+librt +openvswitch-libopenvswitch +openvswitch-libovsdb
ovs_ovsdb_files:=usr/sbin/ovsdb-server
$(eval $(call OvsPackageTemplate,ovsdb))


ovs_common_title:=Open vSwitch (common files)
ovs_common_hidden:=1
ovs_common_depends:=+librt +openvswitch-libopenvswitch +openvswitch-libofproto +openvswitch-libovsdb
ovs_common_files:= \
	usr/share/openvswitch/scripts/ovs-lib \
	usr/share/openvswitch/scripts/ovs-ctl \
	usr/share/openvswitch/scripts/ovs-save \
	$(foreach b,ovs-appctl ovs-dpctl ovs-ofctl ovs-vsctl ovsdb-client ovsdb-tool,usr/bin/$(b))
define ovs_common_install
	$$(INSTALL_DIR) $$(1)/etc/openvswitch
	$$(INSTALL_DIR) $$(1)/etc/init.d
	$$(INSTALL_BIN) ./files/openvswitch.init $$(1)/etc/init.d/openvswitch
	$$(INSTALL_DIR) $$(1)/etc/config
	$$(INSTALL_DATA) ./files/openvswitch.config $$(1)/etc/config/openvswitch
	$$(INSTALL_DIR) $$(1)/usr/share/openvswitch/scripts
	$$(INSTALL_BIN) ./files/ovs-ctl-wrapper $$(1)/usr/share/openvswitch/scripts/
	$$(LN) /usr/share/openvswitch/scripts/ovs-ctl-wrapper $$(1)/usr/bin/ovs-ctl
endef
define Package/openvswitch-common/conffiles
/etc/openvswitch
endef
$(eval $(call OvsPackageTemplate,common))


# coreutils-sleep is required by ovs-lib for sleeping a fraction of second
#
# uuidgen is required for generating system-id
ovs_openvswitch_title:=Open vSwitch
ovs_openvswitch_hidden:=
ovs_openvswitch_depends:=+librt +coreutils +coreutils-sleep +uuidgen \
	+openvswitch-common +openvswitch-vswitchd +openvswitch-ovsdb +kmod-openvswitch
ovs_openvswitch_files:= usr/share/openvswitch/vswitch.ovsschema
$(eval $(call OvsPackageTemplate,openvswitch))


ovs_ovn-common_title:=Open Virtual Network (common files)
ovs_ovn-common_hidden:=1
ovs_ovn-common_depends:=+librt +openvswitch-common +openvswitch-libopenvswitch +openvswitch-libovn +openvswitch-libovsdb
ovs_ovn-common_files:= \
	usr/share/openvswitch/scripts/ovn-ctl \
	$(foreach b,ovn-nbctl ovn-sbctl ovn-trace ovn-detrace,usr/bin/$(b))
define ovs_ovn-common_install
	$$(INSTALL_DIR) $$(1)/usr/share/openvswitch/scripts
	$$(LN) /usr/share/openvswitch/scripts/ovs-ctl-wrapper $$(1)/usr/bin/ovn-ctl
endef
$(eval $(call OvsPackageTemplate,ovn-common))


ovs_ovn-north_title:=Open Virtual Network (north package)
ovs_ovn-north_hidden:=
ovs_ovn-north_depends:=+openvswitch-ovsdb +openvswitch-ovn-common
ovs_ovn-north_files:=\
	usr/share/openvswitch/ovn-nb.ovsschema \
	usr/share/openvswitch/ovn-sb.ovsschema \
	usr/bin/ovn-northd
$(eval $(call OvsPackageTemplate,ovn-north))


ovs_ovn-host_title:=Open Virtual Network (chassis package)
ovs_ovn-host_hidden:=
ovs_ovn-host_depends:=+openvswitch +openvswitch-ovn-common
ovs_ovn-host_files:=usr/bin/ovn-controller
$(eval $(call OvsPackageTemplate,ovn-host))


ovs_python_title:=Open vSwitch (Python library)
ovs_python_hidden:=
ovs_python_depends:=+PACKAGE_openvswitch-python:python +PACKAGE_openvswitch-python:python-six
define ovs_python_install
	$$(INSTALL_DIR) $$(1)$$(PYTHON_PKG_DIR)
	$$(CP) $$(PKG_INSTALL_DIR)/usr/share/openvswitch/python/ovs $$(1)$$(PYTHON_PKG_DIR)
endef
$(eval $(call OvsPackageTemplate,python))


$(foreach p,$(ovs_packages),\
  $(eval $(call BuildPackage,$(p)))\
)

$(eval $(call KernelPackage,openvswitch))
$(eval $(call KernelPackage,openvswitch-gre))
$(eval $(call KernelPackage,openvswitch-vxlan))
$(eval $(call KernelPackage,openvswitch-geneve))
