include $(TOPDIR)/rules.mk

PKG_NAME:=libucontext
PKG_VERSION:=1.2
PKG_RELEASE:=1
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).zip
PKG_SOURCE_URL:=https://codeload.github.com/kaniini/libucontext/zip/v$(PKG_VERSION)?
PKG_HASH:=77878849d938bfac041702b38e34aac2c09e90b3c94d13388c751b4e434ddc79
PKG_BUILD_DIR:=$(BUILD_DIR)/libucontext-$(PKG_VERSION)

PKG_MAINTAINER:=Volker Christian <me@vchrist.at>
PKG_LICENSE:=ISC
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk

# Do not use mips16 as the assempler code of libucontext did not support it
ifdef CONFIG_USE_MIPS16
  TARGET_CFLAGS+=-mno-mips16 -mno-interlink-mips16
endif

# Map/translate openwrt architectures to libucontext architectures
UC_ARCH=$(ARCH)
ifneq ($(findstring mips,$(UC_ARCH)),)
  ifneq ($(findstring mips64,$(UC_ARCH)),)
   UC_ARCH:=mips64
  else
   UC_ARCH:=mips
  endif
endif
ifeq (powerpc,$(UC_ARCH))
  UC_ARCH:=ppc
endif
ifeq (powerpc64,$(UC_ARCH))
  UC_ARCH:=ppc64
endif
ifeq (i386,$(UC_ARCH))
  UC_ARCH:=x86
endif

define Package/libucontext
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=libucontext is a library which provides the ucontext.h C API
  URL:=https://github.com/kaniini/libucontext
endef

define Package/libucontext/description
  Thie package is a development package aimed to be linked to
  libraries/applications which need the SYS-V ucontext API.
endef

define Build/Compile
	$(call Build/Compile/Default,ARCH=$(UC_ARCH))
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/libucontext_posix.a $(1)/usr/lib/
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/libucontext.a $(1)/usr/lib/
endef

$(eval $(call BuildPackage,libucontext))
