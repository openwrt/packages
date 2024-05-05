include $(TOPDIR)/rules.mk

PKG_NAME:=ply
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/iovisor/ply
PKG_MIRROR_HASH:=88b13091060c304ea7ecd3471d3889cf9daf6c0e524f6f810e56502fe46a4803
PKG_SOURCE_DATE:=2023-05-19
PKG_SOURCE_VERSION:=1b57943db56692924bccb61c271de24a8264d8df

PKG_LICENSE:=GPL-2.0
PKG_LICENSE_FILES:=COPYING
PKG_FIXUP:=autoreconf
PKG_MAINTAINER:=Jianhui Zhao <zhaojh329@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/ply
  SECTION:=base
  CATEGORY:=Base system
  TITLE:=A dynamic tracer for Linux
  DEPENDS:=@(aarch64||arm||powerpc||x86_64||riscv64) +@KERNEL_BPF_EVENTS +@KERNEL_FTRACE_SYSCALLS \
			+@KERNEL_ENABLE_DEFAULT_TRACERS +@KERNEL_FUNCTION_TRACER +@KERNEL_FUNCTION_GRAPH_TRACER \
			+@KERNEL_DYNAMIC_FTRACE +@KERNEL_FUNCTION_PROFILER +@KERNEL_IRQSOFF_TRACER \
			+@KERNEL_PREEMPT_TRACER
  URL:=https://github.com/iovisor/ply
endef

define Package/ply/description
  A light-weight dynamic tracer for Linux that leverages the
  kernel's BPF VM in concert with kprobes and tracepoints to
  attach probes to arbitrary points in the kernel.
endef

define Package/ply/install
	$(call Build/Install/Default)

	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libply.so* $(1)/usr/lib

	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/ply $(1)/usr/sbin
endef

$(eval $(call BuildPackage,ply))
