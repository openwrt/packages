#
# Copyright (C) 2018 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=open-vm-tools
PKG_VERSION:=13.0.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-24696409.tar.gz
PKG_SOURCE_URL:=https://github.com/vmware/open-vm-tools/releases/download/stable-$(PKG_VERSION)
PKG_HASH:=ce855a7d9a0a6561e6009784eb2a34f6a1d98b2a883afce5290cd426f78e7a6d
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)-24696409

PKG_LICENSE:=LGPL-2.1-or-later
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:/a:vmware:open-vm-tools

PKG_FIXUP:=autoreconf
PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
PKG_BUILD_DEPENDS:=glib2/host rpcsvc-proto/host

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk

define Package/open-vm-tools/Default
  SECTION:=utils
  CATEGORY:=Utilities
  URL:=https://github.com/vmware/open-vm-tools
endef

define Package/open-vm-tools
$(call Package/open-vm-tools/Default)
  DEPENDS:=@TARGET_x86 \
	+glib2 \
	+libpthread \
	+libtirpc \
	+libmspack \
	+libdnet
  TITLE:=open-vm-tools
  URL:=https://github.com/vmware/open-vm-tools
  MAINTAINER:=Yuhei OKAWA <tochiro.srchack@gmail.com>
endef

define Package/open-vm-tools/description
	Open Virtual Machine Tools for VMware guest OS
endef

define Package/open-vm-tools-fuse
$(call Package/open-vm-tools/Default)
  DEPENDS:=+open-vm-tools +libfuse3
  TITLE:=open-vm-tools-fuse
  MAINTAINER:=Kagurazaka Kotori <kagurazakakotori@gmail.com>
endef

define Package/open-vm-tools-fuse/description
	Shared Folders user mode FUSE client support for VMware guest OS
endef

CONFIGURE_ARGS+= \
	--without-icu \
	--disable-containerinfo \
	--disable-multimon \
	--disable-docs \
	--disable-tests \
	--without-gtkmm \
	--without-gtkmm3 \
	--without-xerces \
	--without-pam \
	--disable-grabbitmqproxy \
	--disable-vgauth \
	--without-root-privileges \
	--without-kernel-modules \
	--with-tirpc \
	--without-x \
	--without-gtk2 \
	--without-gtk3 \
	--without-xerces \
	--enable-resolutionkms=no \
	--disable-glibc-check

TARGET_LDFLAGS+=$(if $(ICONV_FULL),-liconv)

define Build/Prepare
	$(call Build/Prepare/Default)
	mv $(PKG_BUILD_DIR)/lib/include/poll.h $(PKG_BUILD_DIR)/lib/include/vm_poll.h
endef

define Package/open-vm-tools/install
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/vmtoolsd.init $(1)/etc/init.d/vmtoolsd

	$(INSTALL_DIR) $(1)/etc/vmware-tools/
	$(INSTALL_DATA) ./files/tools.conf $(1)/etc/vmware-tools/
	$(CP) $(PKG_INSTALL_DIR)/etc/vmware-tools $(1)/etc/

	$(INSTALL_DIR) $(1)/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/vmtoolsd $(1)/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/vmware-checkvm $(1)/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/vmware-hgfsclient $(1)/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/vmware-namespace-cmd $(1)/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/vmware-rpctool $(1)/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/vmware-toolbox-cmd $(1)/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/vmware-xferlogs $(1)/bin/

	$(INSTALL_DIR) $(1)/sbin/
	$(INSTALL_BIN) ./files/shutdown $(1)/sbin/
	$(INSTALL_BIN) ./files/telinit $(1)/sbin/

	$(INSTALL_DIR) $(1)/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libguestlib.so* $(1)/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libhgfs.so* $(1)/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libvmtools.so* $(1)/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libDeployPkg.so* $(1)/lib/

	$(INSTALL_DIR) $(1)/usr/lib/open-vm-tools/plugins/common/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/open-vm-tools/plugins/common/libhgfsServer.so $(1)/usr/lib/open-vm-tools/plugins/common/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/open-vm-tools/plugins/common/libvix.so $(1)/usr/lib/open-vm-tools/plugins/common/

	$(INSTALL_DIR) $(1)/usr/lib/open-vm-tools/plugins/vmsvc/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/open-vm-tools/plugins/vmsvc/libguestInfo.so $(1)/usr/lib/open-vm-tools/plugins/vmsvc/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/open-vm-tools/plugins/vmsvc/libpowerOps.so $(1)/usr/lib/open-vm-tools/plugins/vmsvc/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/open-vm-tools/plugins/vmsvc/libtimeSync.so $(1)/usr/lib/open-vm-tools/plugins/vmsvc/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/open-vm-tools/plugins/vmsvc/libvmbackup.so $(1)/usr/lib/open-vm-tools/plugins/vmsvc/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/open-vm-tools/plugins/vmsvc/libdeployPkgPlugin.so $(1)/usr/lib/open-vm-tools/plugins/vmsvc/

	$(INSTALL_DIR) $(1)/etc/hotplug.d/block/
	$(INSTALL_BIN) ./files/vmware-scsi.hotplug $(1)/etc/hotplug.d/block/80-vmware-scsi

	$(INSTALL_DIR) $(1)/usr/share/open-vm-tools/messages/fr/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/open-vm-tools/messages/fr/toolboxcmd.vmsg $(1)/usr/share/open-vm-tools/messages/fr/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/open-vm-tools/messages/fr/vmtoolsd.vmsg $(1)/usr/share/open-vm-tools/messages/fr/
	$(INSTALL_DIR) $(1)/usr/share/open-vm-tools/messages/ja/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/open-vm-tools/messages/ja/toolboxcmd.vmsg $(1)/usr/share/open-vm-tools/messages/ja/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/open-vm-tools/messages/ja/vmtoolsd.vmsg $(1)/usr/share/open-vm-tools/messages/ja/
	$(INSTALL_DIR) $(1)/usr/share/open-vm-tools/messages/en/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/open-vm-tools/messages/en/toolboxcmd.vmsg $(1)/usr/share/open-vm-tools/messages/en/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/open-vm-tools/messages/en/vmtoolsd.vmsg $(1)/usr/share/open-vm-tools/messages/en/
	$(INSTALL_DIR) $(1)/usr/share/open-vm-tools/messages/es/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/open-vm-tools/messages/es/toolboxcmd.vmsg $(1)/usr/share/open-vm-tools/messages/es/
	$(CP) $(PKG_INSTALL_DIR)/usr/share/open-vm-tools/messages/es/vmtoolsd.vmsg $(1)/usr/share/open-vm-tools/messages/es/
endef

define Package/open-vm-tools-fuse/install
	$(INSTALL_DIR) $(1)/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/vmhgfs-fuse $(1)/bin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/vmware-vmblock-fuse $(1)/bin/
endef

$(eval $(call BuildPackage,open-vm-tools))
$(eval $(call BuildPackage,open-vm-tools-fuse))
