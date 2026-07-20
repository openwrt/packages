#
# Copyright (C) 2025 Dengfeng Liu
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=aw-bpf
PKG_VERSION:=1.04.7
PKG_RELEASE:=2

PKG_SOURCE:=aw-bpf-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/liudf0716/$(PKG_NAME)/tar.gz/$(PKG_VERSION)?
PKG_HASH:=7665e73f91a987f841d681f0a851f8669bc0fc8ce5890324f629b035117d7246
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=Dengfeng Liu <liudf0716@gmail.com>
PKG_LICENSE:=GPL-2.0-or-later
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=bpf-headers

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk
include $(INCLUDE_DIR)/bpf.mk
include $(INCLUDE_DIR)/kernel.mk

define Package/aw-bpf
  SECTION:=net
  CATEGORY:=Network
  TITLE:=ApFree eBPF programs and tools
  DEPENDS:=+libbpf +libelf +libjson-c +libuci +libmnl +libnftnl +tc-full +kmod-xdpi $(BPF_DEPENDS)
  URL:=https://github.com/liudf0716/aw-bpf
endef

define Package/aw-bpf/description
	ApFree eBPF provides eBPF programs for session tracking, xDPI, DNS monitoring
	and user-space tools: aw-bpfctl (control CLI) and event_daemon (session / access
	logging daemon that consumes session_events_map and writes JSON syslog).
endef


define KernelPackage/xdpi
  SECTION:=kernel
  SUBMENU:=Network Support
  TITLE:=xdpi ebpf module
  FILES:=$(PKG_BUILD_DIR)/xdpi-bpf.ko
  AUTOLOAD:=$(call AutoProbe,xdpi)
endef

# Build cmake userspace first (aw-bpfctl, event_daemon), then BPF objects and kmod.
define Build/Compile
	$(call Build/Compile/Default)
	$(call CompileBPF,$(PKG_BUILD_DIR)/aw-bpf.c,$(if $(filter arm aarch64 x86_64 i386,$(ARCH)),-DENABLE_XDPI_FEATURE))
	$(call CompileBPF,$(PKG_BUILD_DIR)/dns-bpf.c,$(if $(filter arm aarch64 x86_64 i386,$(ARCH)),-DENABLE_XDPI_FEATURE))
	$(KERNEL_MAKE) M=$(PKG_BUILD_DIR) modules
endef

define Package/aw-bpf/conffiles
/etc/config/aw-bpf
endef

define Package/aw-bpf/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/aw-bpfctl $(1)/usr/bin/aw-bpfctl
	# event_daemon: session event consumer for access logging (上网日志)
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/event_daemon $(1)/usr/bin/event_daemon
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/aw-bpf.init $(1)/etc/init.d/aw-bpf
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) ./files/aw-bpf.conf $(1)/etc/config/aw-bpf
	$(INSTALL_DIR) $(1)/lib/bpf
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/aw-bpf.o $(1)/lib/bpf/aw-bpf.o
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/dns-bpf.o $(1)/lib/bpf/dns-bpf.o
endef

$(eval $(call BuildPackage,aw-bpf))
$(eval $(call KernelPackage,xdpi))
