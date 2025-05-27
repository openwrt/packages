include $(TOPDIR)/rules.mk

PKG_NAME:=luajit
PKG_SOURCE_DATE:=2025-05-27
PKG_REAL_VERSION=2.1
PKG_VERSION:=$(PKG_REAL_VERSION)-$(subst -,,$(PKG_SOURCE_DATE))
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/LuaJIT/LuaJIT.git
PKG_SOURCE_VERSION:=eec7a8016c3381b949b5d84583800d05897fa960
PKG_MIRROR_HASH:=7e9021ce1a34ec3f61e64db9fb15be97130d7ebdb4b033d70a49956bc612309c

PKG_MAINTAINER:=Morteza Milani <milani@pichak.co>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYRIGHT
PKG_CPE_ID:=cpe:/a:luajit:luajit

PKG_BUILD_FLAGS:=no-mips16

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

define Package/luajit
 SUBMENU:=Lua
 SECTION:=lang
 CATEGORY:=Languages
 TITLE:=LuaJIT
 URL:=https://www.luajit.org
 DEPENDS:=@HAS_LUAJIT_ARCH
endef

define Package/luajit/description
 LuaJIT is a Just-In-Time (JIT) compiler for the Lua programming language. *** Requires GCC Multilib on host system to build! ***
endef

define Package/luajit/config
config HAS_LUAJIT_ARCH
	bool
	default y if i386||x86_64||arm||armeb||aarch64||powerpc||mips||mipsel||mips64
endef

ifeq ($(HOST_ARCH),$(filter $(HOST_ARCH), x86_64 mips64))
  ifeq ($(CONFIG_ARCH_64BIT),)
    HOST_BITS := -m32
  endif
endif

define Build/Compile
	$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		HOST_CC="$(HOSTCC) $(HOST_CFLAGS) $(HOST_BITS)" \
		CROSS="$(TARGET_CROSS)" \
		DPREFIX=$(PKG_INSTALL_DIR)/usr \
		PREFIX=/usr \
		TARGET_SYS=Linux \
		TARGET_CFLAGS="$(TARGET_CFLAGS)" \
		BUILDMODE=dynamic
	rm -rf $(PKG_INSTALL_DIR)
	mkdir -p $(PKG_INSTALL_DIR)
	$(MAKE) -C $(PKG_BUILD_DIR) \
		DPREFIX=$(PKG_INSTALL_DIR)/usr \
		PREFIX=/usr \
		TARGET_SYS=Linux \
		install
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/luajit-$(PKG_REAL_VERSION)
	$(CP) $(PKG_INSTALL_DIR)/usr/include/luajit-$(PKG_REAL_VERSION)/*.{h,hpp} $(1)/usr/include/luajit-$(PKG_REAL_VERSION)
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/luajit.pc $(1)/usr/lib/pkgconfig/
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/luajit-$(PKG_REAL_VERSION).* $(1)/usr/bin/$(PKG_NAME)
endef

define Package/luajit/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/luajit-$(PKG_REAL_VERSION).* $(1)/usr/bin/$(PKG_NAME)
endef

define Host/Compile
	$(MAKE) $(HOST_JOBS) -C $(HOST_BUILD_DIR) \
		DPREFIX=$(STAGING_DIR_HOSTPKG) \
		TARGET_CFLAGS="$(HOST_CFLAGS)" \
		TARGET_LDFLAGS="$(HOST_LDFLAGS)"
endef

define Host/Install
	$(MAKE) $(HOST_JOBS) -C $(HOST_BUILD_DIR) \
		DPREFIX=$(STAGING_DIR_HOSTPKG) \
		install
	$(CP) $(STAGING_DIR_HOSTPKG)/bin/luajit-$(PKG_REAL_VERSION) $(STAGING_DIR_HOSTPKG)/bin/$(PKG_NAME)
endef

$(eval $(call HostBuild,luajit))
$(eval $(call BuildPackage,luajit))
