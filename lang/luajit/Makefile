include $(TOPDIR)/rules.mk

PKG_NAME:=luajit
PKG_VERSION:=2016-06-05-8e5d7be
PKG_RELEASE:=1
PKG_MAINTAINER:=Morteza Milani <milani@pichak.co>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=COPYRIGHT

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/LuaJIT/LuaJIT.git
PKG_SOURCE_VERSION:=8e5d7bec0d110aa4ccd7e8492f697ff2a88a55ed
PKG_SOURCE_SUBDIR:=$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.xz
PKG_BUILD_DIR=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_USE_MIPS16:=0

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/host-build.mk

define Package/luajit
 SUBMENU:=Lua
 SECTION:=lang
 CATEGORY:=Languages
 TITLE:=LuaJIT
 URL:=http://www.luajit.org
 DEPENDS:=@(i386||x86_64||arm||armeb||powerpc||mips||mipsel)
endef

define Package/luajit/description
 LuaJIT is a Just-In-Time (JIT) compiler for the Lua programming language.
endef

TARGET_CFLAGS += $(FPIC) -std=gnu99
HOST_CFLAGS += $(FPIC) -std=gnu99

ifeq ($(HOST_ARCH),x86_64)
  ifeq ($(CONFIG_x86_64),)
    HOST_BITS := -m32
  endif
endif

define Build/Compile
	$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR) \
		HOST_CC="$(HOSTCC) $(HOST_CFLAGS) $(HOST_BITS)" \
		CROSS="$(TARGET_CROSS)" \
		DPREFIX=$(PKG_INSTALL_DIR)/usr \
		PREFIX=/usr \
		TARGET_CFLAGS="$(TARGET_CFLAGS)"
	rm -rf $(PKG_INSTALL_DIR)
	mkdir -p $(PKG_INSTALL_DIR)
	$(MAKE) -C $(PKG_BUILD_DIR) \
		DPREFIX=$(PKG_INSTALL_DIR)/usr \
		PREFIX=/usr \
		install
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/luajit-2.1
	$(CP) $(PKG_INSTALL_DIR)/usr/include/luajit-2.1/*.h $(1)/usr/include/luajit-2.1
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.{a,so*} $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/luajit.pc $(1)/usr/lib/pkgconfig/
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/luajit-2.1.0-beta2 $(PKG_INSTALL_DIR)/usr/bin/$(PKG_NAME)
endef

define Package/luajit/install
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/*.so $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/luajit-2.1.0-beta2 $(1)/usr/bin/$(PKG_NAME)
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
	$(CP) $(STAGING_DIR_HOSTPKG)/bin/luajit-2.1.0-beta2 $(STAGING_DIR_HOSTPKG)/bin/$(PKG_NAME)
endef

$(eval $(call HostBuild,luajit))
$(eval $(call BuildPackage,luajit))
