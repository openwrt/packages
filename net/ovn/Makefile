#
# Copyright (C) 2020 Yousong Zhou <yszhou4tech@gmail.com>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/kernel.mk
include ../openvswitch/openvswitch.mk

PKG_NAME:=ovn
PKG_VERSION:=22.03.5
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/ovn-org/ovn.git
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=2fce32762c4f8f21ba10f2d41924188cd995bea56eb9a09a7a119b15b9c60224

PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:openvswitch:openvswitch

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_BUILD_DEPENDS+=python3/host
PKG_BUILD_FLAGS:=no-mips16 lto
PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf
PKG_INSTALL:=1

PKG_MAINTAINER:=Yousong Zhou <yszhou4tech@gmail.com>

include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python3-host.mk

ovs_libovn_title:=Open vSwitch (libovn.so)
ovs_libovn_hidden:=1
ovs_libovn_depends+=+libatomic +openvswitch-libopenvswitch
ovs_libovn_files:=usr/lib/libovn*.so*
$(eval $(call OvsPackageTemplate,libovn))


ovs_ovn-common_title:=Open Virtual Network (common files)
ovs_ovn-common_hidden:=1
ovs_ovn-common_depends:=+openvswitch-common +openvswitch-libopenvswitch +openvswitch-libovn +openvswitch-libovsdb
ovs_ovn-common_depends+=+libatomic
ovs_ovn-common_files:= \
	usr/share/ovn/scripts/ovn-ctl \
	usr/share/ovn/scripts/ovn-lib \
	$(foreach b,ovn-appctl ovn-nbctl ovn-sbctl,usr/bin/$(b))
define ovs_ovn-common_install
	$$(LN) /usr/share/openvswitch/scripts/ovs-ctl-wrapper $$(1)/usr/bin/ovn-ctl
endef
$(eval $(call OvsPackageTemplate,ovn-common))


ovs_ovn-north_title:=Open Virtual Network (north package)
ovs_ovn-north_hidden:=
ovs_ovn-north_depends:=+openvswitch-ovsdb +openvswitch-ovn-common
ovs_ovn-north_depends+=+libatomic
ovs_ovn-north_files:=\
	usr/share/ovn/ovn-nb.ovsschema \
	usr/share/ovn/ovn-sb.ovsschema \
	usr/bin/ovn-northd
$(eval $(call OvsPackageTemplate,ovn-north))


ovs_ovn-host_title:=Open Virtual Network (chassis package)
ovs_ovn-host_hidden:=
ovs_ovn-host_depends:=+openvswitch +openvswitch-ovn-common
ovs_ovn-host_depends+=+libatomic
ovs_ovn-host_files:=usr/bin/ovn-controller
$(eval $(call OvsPackageTemplate,ovn-host))


CONFIGURE_ARGS+= \
	--enable-ndebug \
	--enable-shared \
	--disable-libcapng \
	--disable-silent-rules \
	--with-ovs-source=$(ovs_builddir) \
	--with-ovs-build=$(ovs_builddir) \

CONFIGURE_VARS += \
	ovs_cv_flake8=no \
	ovs_cv_sphinx=no \
	ovs_cv_python3=$(HOST_PYTHON3_BIN) \


TARGET_CFLAGS += -std=gnu99
# This is needed otherwise libtool --mode=install libovn.la will fail with
# "cannot find -lopenvswitch" when doing libtool --mode=relink.  Likely this
# was caused by libovn now depends on libopenvswitch.la (installed=no) since
# upstream commit 1b587c4f ("controller: add datapath meter capability check")
TARGET_LDFLAGS += -L$(ovs_builddir)/lib/.libs
MAKE_VARS += PYTHONPATH="$(HOST_PYTHON3PATH)"

$(foreach p,$(ovs_packages),\
  $(eval $(call BuildPackage,$(p)))\
)
