#
# Copyright (C) 2013 Julius Schulz-Zander <julius@net.t-labs.tu-berlin.de>
# Copyright (C) 2014-2017 OpenWrt.org
# Copyright (C) 2018-2019 Yousong Zhou <yszhou4tech@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

# Checklist on version bump
#
#  - Check acinclude.m4 for range of supported kernel versions: "but version newer than .* is not supported"
#  - Check and update kmod dependencies when necessary (runtime module load check in the least)
#
PKG_NAME:=openvswitch
PKG_VERSION:=2.12.0
PKG_RELEASE:=2
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.openvswitch.org/releases/
PKG_HASH:=13fd42703180b4b1146c7e97926d09225485868cc2fbbd58dc0c421b4b8fe8f8

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:openvswitch:openvswitch

PKG_BUILD_DEPENDS+=python3/host python-six/host
PKG_USE_MIPS16:=0
PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

PKG_MAINTAINER:=Yousong Zhou <yszhou4tech@gmail.com>

include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python3-host.mk
include ../../lang/python/python-package.mk
include ../../lang/python/python3-package.mk


ovs_kmod_packages:=
ovs_kmod_intree_kernel_patchver_min:=3.10
ovs_kmod_intree_kernel_patchver_max:=5.0
ovs_kmod_intree_not_supported:=$(strip $(call kernel_patchver_lt,$(ovs_kmod_intree_kernel_patchver_min))$(call kernel_patchver_gt,$(ovs_kmod_intree_kernel_patchver_max)))
ovs_kmod_intree_dir:=$(PKG_BUILD_DIR)/datapath/linux
ovs_kmod_upstream_dir:=$(LINUX_DIR)/net/openvswitch
ovs_kmod_package_name=$(if $(filter openvswitch,$(1)),openvswitch,$(1))
ovs_kmod_is_intree=$(filter %-intree,$(1))
ovs_kmod_upstream_name=kmod-$(call ovs_kmod_package_name,$(patsubst %-intree,%,$(1)))
ovs_kmod_package_provides=$(call ovs_kmod_upstream_name,$(1))
define OvsKmodPackageTemplate
ifeq ($(if $(call ovs_kmod_is_intree,$(1)),$(ovs_kmod_intree_not_supported)),)
  define KernelPackage/$(call ovs_kmod_package_name,$(1))
     SECTION:=kernel
     CATEGORY:=Kernel modules
     SUBMENU:=Network Support
     TITLE:=$(ovs_kmod_$(1)_title)
     DEPENDS:=$(ovs_kmod_$(1)_depends) $(if $(call ovs_kmod_is_intree,$(1)),@DEVEL)
     PROVIDES:=$(call ovs_kmod_package_provides,$(1))
     KCONFIG:=$(ovs_kmod_$(1)_kconfig)
     FILES:=$(ovs_kmod_$(1)_files)
     AUTOLOAD:=$(call AutoProbe,$(foreach m,$(ovs_kmod_$(1)_files),$(patsubst %.ko,%,$(basename $(m)))))
  endef

  ovs_kmod_packages+=$(call ovs_kmod_package_name,$(1))
endif
endef

ovs_kmod_openvswitch_title:=Open vSwitch kernel datapath (upstream)
ovs_kmod_openvswitch_kconfig:=CONFIG_OPENVSWITCH
ovs_kmod_openvswitch_depends:=\
	  +kmod-lib-crc32c \
	  +kmod-nf-nat \
	  +IPV6:kmod-nf-nat6 \
	  +kmod-nf-conntrack \
	  +IPV6:kmod-nf-conntrack6 \
	  +(!LINUX_4_9&&!LINUX_4_14):kmod-nsh \
	  +(!LINUX_4_9&&!LINUX_4_14):kmod-ipt-conntrack-extra \

ovs_kmod_openvswitch_files:=$(ovs_kmod_upstream_dir)/openvswitch.ko
$(eval $(call OvsKmodPackageTemplate,openvswitch))

ovs_kmod_openvswitch-gre_title:=Open vSwitch GRE tunneling support (upstream)
ovs_kmod_openvswitch-gre_kconfig:= CONFIG_OPENVSWITCH_GRE
ovs_kmod_openvswitch-gre_depends:= +kmod-openvswitch +kmod-gre
ovs_kmod_openvswitch-gre_files:= $(ovs_kmod_upstream_dir)/vport-gre.ko
$(eval $(call OvsKmodPackageTemplate,openvswitch-gre))

ovs_kmod_openvswitch-vxlan_title:=Open vSwitch VXLAN tunneling support (upstream)
ovs_kmod_openvswitch-vxlan_kconfig:= CONFIG_OPENVSWITCH_VXLAN
ovs_kmod_openvswitch-vxlan_depends:= +kmod-openvswitch +kmod-vxlan
ovs_kmod_openvswitch-vxlan_files:= $(ovs_kmod_upstream_dir)/vport-vxlan.ko
$(eval $(call OvsKmodPackageTemplate,openvswitch-vxlan))

ovs_kmod_openvswitch-geneve_title:=Open vSwitch Geneve tunneling support (upstream)
ovs_kmod_openvswitch-geneve_kconfig:= CONFIG_OPENVSWITCH_GENEVE
ovs_kmod_openvswitch-geneve_depends:= +kmod-openvswitch +kmod-geneve
ovs_kmod_openvswitch-geneve_files:= $(ovs_kmod_upstream_dir)/vport-geneve.ko
$(eval $(call OvsKmodPackageTemplate,openvswitch-geneve))

# NOTE depends
#
#  - kmod-gre: with linux-4.14, ovs-2.10, when ovs decides to not
#    USE_UPSTREAM_TUNNEL, it requires kmod-gre to be enabled so that
#    CONFIG_NET_IPGRE_DEMUX is enabled and ovs will have rpl_gre_init()
#    compiled in.
#
#  - kmod-gre6: with linux-4.14, ovs-2.10, when ovs decides to not
#    USE_UPSTREAM_TUNNEL, it requires xfrm6_tunnel_register() from
#    net/ipv6/tunnel6.ko, which will be pulled in by kmod-ip6-tunnel, which
#    will be pulled in by kmod-gre6.  NOTE that tunnel6.ko itself cannot be
#    enabled and selected on its own
#
#  - kmod-ipt-conntrack-extra: required for nf_conncount.ko
#
ovs_kmod_openvswitch-intree_title:=Open vSwitch kernel datapath (in tree)
ovs_kmod_openvswitch-intree_depends:=\
	  +kmod-lib-crc32c \
	  +kmod-nf-nat \
	  +IPV6:kmod-nf-nat6 \
	  +kmod-nf-conntrack \
	  +(IPV6&&(LINUX_4_9||LINUX_4_14)):kmod-nf-conntrack6 \
	  +(LINUX_4_9||LINUX_4_14):kmod-gre \
	  +(IPV6&&(LINUX_4_9||LINUX_4_14)):kmod-gre6 \
	  +(!LINUX_4_9&&!LINUX_4_14):kmod-udptunnel4 \
	  +(!LINUX_4_9&&!LINUX_4_14):kmod-ipt-conntrack-extra \

ovs_kmod_openvswitch-intree_files:= $(ovs_kmod_intree_dir)/openvswitch.ko
$(eval $(call OvsKmodPackageTemplate,openvswitch-intree))

ovs_kmod_openvswitch-gre-intree_title:=Open vSwitch GRE tunneling support (in tree)
ovs_kmod_openvswitch-gre-intree_depends:= +kmod-openvswitch-intree +kmod-gre
ovs_kmod_openvswitch-gre-intree_files:= $(ovs_kmod_intree_dir)/vport-gre.ko
$(eval $(call OvsKmodPackageTemplate,openvswitch-gre-intree))

ovs_kmod_openvswitch-vxlan-intree_title:=Open vSwitch VXLAN tunneling support (in tree)
ovs_kmod_openvswitch-vxlan-intree_depends:= +kmod-openvswitch-intree +kmod-vxlan
ovs_kmod_openvswitch-vxlan-intree_files:= $(ovs_kmod_intree_dir)/vport-vxlan.ko
$(eval $(call OvsKmodPackageTemplate,openvswitch-vxlan-intree))

ovs_kmod_openvswitch-geneve-intree_title:=Open vSwitch Geneve tunneling support (in tree)
ovs_kmod_openvswitch-geneve-intree_depends:= +kmod-openvswitch-intree +kmod-geneve
ovs_kmod_openvswitch-geneve-intree_files:= $(ovs_kmod_intree_dir)/vport-geneve.ko
$(eval $(call OvsKmodPackageTemplate,openvswitch-geneve-intree))

ovs_kmod_openvswitch-stt-intree_title:=Open vSwitch STT tunneling support (in tree)
ovs_kmod_openvswitch-stt-intree_depends:= +kmod-openvswitch-intree
ovs_kmod_openvswitch-stt-intree_files:= $(ovs_kmod_intree_dir)/vport-stt.ko
$(eval $(call OvsKmodPackageTemplate,openvswitch-stt-intree))

ovs_kmod_openvswitch-lisp-intree_title:=Open vSwitch LISP tunneling support (in tree)
ovs_kmod_openvswitch-lisp-intree_depends:= +kmod-openvswitch-intree
ovs_kmod_openvswitch-lisp-intree_files:= $(ovs_kmod_intree_dir)/vport-lisp.ko
$(eval $(call OvsKmodPackageTemplate,openvswitch-lisp-intree))


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
     DEPENDS:=$(ovs_$(1)_depends) +libatomic +libunbound
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
	usr/share/openvswitch/scripts/ovs-kmod-ctl \
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
	$$(LN) /usr/share/openvswitch/scripts/ovs-ctl-wrapper $$(1)/usr/bin/ovs-kmod-ctl
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


ovs_python3_title:=Open vSwitch (Python3 library)
ovs_python3_hidden:=
ovs_python3_depends:=+PACKAGE_openvswitch-python3:python3 +PACKAGE_openvswitch-python3:python3-six
define ovs_python3_install
	$$(INSTALL_DIR) $$(1)$$(PYTHON3_PKG_DIR)
	$$(CP) $$(PKG_INSTALL_DIR)/usr/share/openvswitch/python/ovs $$(1)$$(PYTHON3_PKG_DIR)
endef
$(eval $(call OvsPackageTemplate,python3))


CONFIGURE_ARGS+= \
	--enable-ndebug \
	--enable-shared \
	--disable-libcapng \

CONFIGURE_VARS += \
	ovs_cv_flake8=no \
	ovs_cv_python=$(PYTHON3) \
	ovs_cv_python_host=$(HOST_PYTHON3_BIN) \
	ovs_cv_sphinx=no \
	ovs_cv_python2=no \
	KARCH=$(LINUX_KARCH) \

ovs_intree_kmod_configs:=CONFIG_PACKAGE_kmod-openvswitch-intree
ovs_intree_kmod_enabled:=$(strip $(foreach c,$(ovs_intree_kmod_configs),$($(c))))
PKG_CONFIG_DEPENDS+=$(ovs_intree_kmod_configs)
ifneq ($(ovs_intree_kmod_enabled),)
  ifeq ($(ovs_kmod_intree_not_supported),)
    CONFIGURE_ARGS += --with-linux=$(LINUX_DIR)
  else
    $(warning XXX: openvswitch: intree kmods selected but not supported)
  endif
endif

TARGET_CFLAGS += -flto -std=gnu99
MAKE_VARS += PYTHONPATH="$(HOST_PYTHON3PATH)"

$(foreach p,$(ovs_kmod_packages),\
  $(eval $(call KernelPackage,$(p)))\
)
$(foreach p,$(ovs_packages),\
  $(eval $(call BuildPackage,$(p)))\
)
