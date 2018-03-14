#
# Copyright (C) 2013 Julius Schulz-Zander <julius@net.t-labs.tu-berlin.de>
# Copyright (C) 2014-2017 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# $Id: Makefile $

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk

PKG_NAME:=openvswitch

PKG_VERSION:=2.8.2
PKG_RELEASE:=1
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=COPYING
PKG_USE_MIPS16:=0

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://www.openvswitch.org/releases/
PKG_HASH:=87b4a7e7134a44ce1f808d3415a2244b4518c2b0b2a42fa2f8231e592f13103d

PKG_BUILD_DEPENDS:=python/host python-six/host

PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

PKG_MAINTAINER:=Yousong Zhou <yszhou4tech@gmail.com>

include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python-host.mk
include ../../lang/python/python-package.mk

define Package/openvswitch/Default
  SECTION:=net
  SUBMENU:=Open vSwitch
  CATEGORY:=Network
  URL:=http://openvswitch.org/
endef

define Package/openvswitch/Default/description
  Open vSwitch is a production quality, multilayer, software-based, Ethernet
  virtual switch. It is designed to enable massive network automation through
  programmatic extension, while still supporting standard management interfaces
  and protocols (e.g. NetFlow, sFlow, SPAN, RSPAN, CLI, LACP, 802.1ag). In
  addition, it is designed to support distribution across multiple physical
  servers similar to VMware's vNetwork distributed vswitch or Cisco's Nexus
  1000V.
endef

define Package/openvswitch-base
  $(call Package/openvswitch/Default)
  TITLE:=Open vSwitch Userspace Package (base)
  DEPENDS:=+libpcap +libopenssl +librt +kmod-openvswitch
endef

define Package/openvswitch-base/description
  Provides the main userspace components required for Open vSwitch to function.
  The main OVS tools (ovs-vsctl, ovs-ofctl, etc) are packaged separately
  to conserve some room and allow more configurability.
endef

define Package/openvswitch-ovn-base
  $(call Package/openvswitch/Default)
  TITLE:=Open Virtual Networking (base)
  DEPENDS:=+openvswitch-base
endef

define Package/openvswitch-ovn-base/description
  Provides the main userspace components required for Open Virtual Networking
  over Open vSwitch.
endef

OVN_BIN_TOOLS:=ovn-controller ovn-controller-vtep ovn-detrace \
	ovn-docker-overlay-driver ovn-docker-underlay-driver \
	ovn-nbctl ovn-sbctl ovn-trace
define Package/openvswitch-ovn
  $(call Package/openvswitch/Default)
  TITLE:=Open Virtual Networking (base)
  DEPENDS:=+openvswitch-ovn-base $(foreach t,$(OVN_BIN_TOOLS),+openvswitch-$(t))
endef

define Package/openvswitch-ovn/description
  Provides all the components required for Open Virtual Networking
  (including the tools)
endef

define Package/openvswitch-vtep
  $(call Package/openvswitch/Default)
  TITLE:=Open vSwitch VXLAN Tunnel End Point
  DEPENDS:=+openvswitch-base
endef

define Package/openvswitch-vtep/description
  This schema specifies relations that a VTEP can use to integrate physi‐
  cal ports into logical switches maintained by a network  virtualization
  controller such as NSX.
endef

define Package/openvswitch-python
  $(call Package/openvswitch/Default)
  TITLE:=Open vSwitch Python Support
  DEPENDS:=+PACKAGE_openvswitch-python:python +PACKAGE_openvswitch-python:python-six
endef

define Package/openvswitch-python/description
  Provides bindings and libraries for using Python to manipulate/work with Open vSwitch.
endef

OVS_BIN_TOOLS:= \
	ovsdb-client ovs-l3ping ovs-dpctl-top \
	ovs-tcpdump ovs-tcpundump ovs-pcap ovs-parse-backtrace
define Package/openvswitch
  $(call Package/openvswitch/Default)
  TITLE:=Open vSwitch Userspace Package
  DEPENDS:=+openvswitch-base $(foreach t,$(OVS_BIN_TOOLS),+openvswitch-$(t))
endef

define Package/openvswitch/description
  Provides the main userspace components required for Open vSwitch to function.
  Includes also most of  OVS utilities.
endef

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

CONFIGURE_ARGS += --enable-ndebug
CONFIGURE_ARGS += --enable-shared

TARGET_CFLAGS += -flto -std=gnu99

CONFIGURE_VARS += \
	ovs_cv_flake8=no \
	ovs_cv_python3=no \
	ovs_cv_sphinx=no \
	ovs_cv_python=$(PYTHON) \
	ovs_cv_python_host=$(HOST_PYTHON_BIN) \
	KARCH=$(LINUX_KARCH)

MAKE_VARS += PYTHONPATH="$(HOST_PYTHONPATH)"
MAKE_FLAGS += ARCH="$(LINUX_KARCH)"

define OvsBinUtility
  define Package/openvswitch-$(2)
     $(call Package/openvswitch/Default)
     TITLE:=$(3)
     DEPENDS:=+$(1) $(4)
  endef

  define Package/openvswitch-$(2)/description
    $(3)
  endef

  define Package/openvswitch-$(2)/install
    $(INSTALL_DIR) $$(1)/usr/bin/ ;\
    $(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/$(2) $$(1)/usr/bin/
  endef
endef

define Package/openvswitch-base/install
	$(INSTALL_DIR) $(1)/etc/openvswitch

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/etc/init.d/openvswitch.init $(1)/etc/init.d/openvswitch

	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libofproto*.so*  $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libopenvswitch*.so*  $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libovsdb*.so*  $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libsflow*.so*  $(1)/usr/lib/

	$(INSTALL_DIR) $(1)/usr/bin/
	$(foreach bin,ovsdb-tool ovs-appctl ovs-ofctl ovs-dpctl ovs-vsctl ovs-pki, \
		$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/$(bin) $(1)/usr/bin/ ; )

	$(INSTALL_DIR) $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ovs-vswitchd $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ovsdb-server $(1)/usr/sbin/

	$(INSTALL_DIR) $(1)/usr/share/openvswitch/scripts
	$(INSTALL_CONF) \
		$(PKG_INSTALL_DIR)/usr/share/openvswitch/vswitch.ovsschema \
		$(1)/usr/share/openvswitch/
	$(INSTALL_DATA) \
		$(PKG_INSTALL_DIR)/usr/share/openvswitch/scripts/ovs-lib \
		$(1)/usr/share/openvswitch/scripts
	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/share/openvswitch/scripts/ovs-ctl \
		$(1)/usr/share/openvswitch/scripts
endef

define Package/openvswitch-ovn-base/install
	$(INSTALL_DIR) $(1)/usr/lib/ $(1)/usr/bin/ $(1)/usr/share/openvswitch/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libovn*.so* $(1)/usr/lib/

	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/ovn-northd $(1)/usr/bin/

	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/usr/share/openvswitch/ovn-nb.ovsschema $(1)/usr/share/openvswitch/
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/usr/share/openvswitch/ovn-sb.ovsschema $(1)/usr/share/openvswitch/
endef

define Package/openvswitch-vtep/install
	$(INSTALL_DIR) $(1)/usr/lib/ $(1)/usr/bin/ $(1)/usr/share/openvswitch/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/vtep-ctl $(1)/usr/bin/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libvtep*.so* $(1)/usr/lib/
	$(INSTALL_CONF) $(PKG_INSTALL_DIR)/usr/share/openvswitch/vtep.ovsschema $(1)/usr/share/openvswitch/
endef

define Package/openvswitch-python/install
	$(INSTALL_DIR) $(1)/usr/lib/python$(PYTHON_VERSION)/ovs
	$(CP) $(PKG_INSTALL_DIR)/usr/share/openvswitch/python/ovs/* $(1)/usr/lib/python$(PYTHON_VERSION)/ovs
endef

define Package/openvswitch-ovn/install
	:
endef

define Package/openvswitch/install
	:
endef

$(eval $(call OvsBinUtility,openvswitch-base,ovs-appctl,Open vSwitch app control utility))
$(eval $(call OvsBinUtility,openvswitch-base,ovs-ofctl,Open vSwitch OpenFlow control utility))
$(eval $(call OvsBinUtility,openvswitch-base,ovs-dpctl,Open vSwitch datapath management utility))
$(eval $(call OvsBinUtility,openvswitch-base,ovs-vsctl,Open vSwitch ovs-vswitchd management utility))
$(eval $(call OvsBinUtility,openvswitch-base,ovsdb-client,Open vSwitch database JSON-RPC client))
$(eval $(call OvsBinUtility,openvswitch-base,ovs-l3ping,Check network deployment for L3 tunneling problems))
$(eval $(call OvsBinUtility,openvswitch-base,ovs-docker,Open vSwitch docker tool))
$(eval $(call OvsBinUtility,openvswitch-base,ovs-dpctl-top,Top like behavior for ovs-dpctl dump-flows))
$(eval $(call OvsBinUtility,openvswitch-base,ovs-pki,OpenFlow public key infrastructure management utility))
$(eval $(call OvsBinUtility,openvswitch-base,ovs-tcpdump,Dump traffic from an Open vSwitch port using tcpdump))
$(eval $(call OvsBinUtility,openvswitch-base,ovs-tcpundump,Convert ``tcpdump -xx`` output to hex strings))
$(eval $(call OvsBinUtility,openvswitch-base,ovs-pcap,Print packets from a pcap file as hex))
$(eval $(call OvsBinUtility,openvswitch-base,ovs-parse-backtrace,parses ovs-appctl backtrace output))

$(eval $(call OvsBinUtility,openvswitch-ovn-base,ovn-controller,Open Virtual Network local controller))
$(eval $(call OvsBinUtility,openvswitch-ovn-base,ovn-controller-vtep,Open Virtual Network local controller for vtep enabled physical switches,+openvswitch-vtep))
$(eval $(call OvsBinUtility,openvswitch-ovn-base,ovn-detrace,Convert ``ovs-appctl ofproto/trace`` output to combine OVN logical flow information))
$(eval $(call OvsBinUtility,openvswitch-ovn-base,ovn-docker-overlay-driver,OVN Docker overlay driver utility))
$(eval $(call OvsBinUtility,openvswitch-ovn-base,ovn-docker-underlay-driver,OVN Docker underlay driver utility))
$(eval $(call OvsBinUtility,openvswitch-ovn-base,ovn-nbctl,Open Virtual Network northbound db management utility))
$(eval $(call OvsBinUtility,openvswitch-ovn-base,ovn-sbctl,Utility for querying and configuring OVN_Southbound data‐base))
$(eval $(call OvsBinUtility,openvswitch-ovn-base,ovn-trace,Open Virtual Network logical network tracing utility))

$(foreach t,$(OVS_BIN_TOOLS),$(eval $(call BuildPackage,openvswitch-$(t))))
$(foreach t,$(OVN_BIN_TOOLS),$(eval $(call BuildPackage,openvswitch-$(t))))

$(eval $(call BuildPackage,openvswitch-base))
$(eval $(call BuildPackage,openvswitch-ovn-base))
$(eval $(call BuildPackage,openvswitch-ovn))
$(eval $(call BuildPackage,openvswitch-vtep))
$(eval $(call BuildPackage,openvswitch-python))
$(eval $(call BuildPackage,openvswitch))

$(eval $(call KernelPackage,openvswitch))
$(eval $(call KernelPackage,openvswitch-gre))
$(eval $(call KernelPackage,openvswitch-vxlan))
$(eval $(call KernelPackage,openvswitch-geneve))
