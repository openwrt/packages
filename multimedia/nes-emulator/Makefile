include $(TOPDIR)/rules.mk

PKG_NAME:=nes-emulator
PKG_VERSION:=1.0.0
PKG_RELEASE:=1

PKG_SOURCE:=openwrt-nes-emulator-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/communism420/openwrt-nes-emulator/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=a47435bd02c5610144a105d39c8e2d0f4a9940ee9eff02452353accec038feba
PKG_BUILD_DIR:=$(BUILD_DIR)/openwrt-nes-emulator-$(PKG_VERSION)

# The main repository intentionally does not vendor this large upstream core.
# Keep the full commit so downloads and compiled provenance use the same pin.
PKG_FCEUMM_VERSION:=76f68314ce4213703174108f461c431001dcc204

PKG_LICENSE:=MIT GPL-2.0-only
PKG_LICENSE_FILES:=LICENSE third_party/libretro-fceumm/Copying
PKG_BUILD_FLAGS:=no-mips16 gc-sections
PKG_BUILD_PARALLEL:=1
PKG_ASLR_PIE_REGULAR:=1

PKG_MAINTAINER:=Yaroslav Vereshchagin <yarik.vereshchagin1996@gmail.com>

include $(INCLUDE_DIR)/package.mk

FCEUMM_BUILD_DIR:=$(PKG_BUILD_DIR)/third_party/libretro-fceumm

define Download/fceumm
  FILE:=libretro-fceumm-$(PKG_FCEUMM_VERSION).tar.gz
  URL:=https://codeload.github.com/libretro/libretro-fceumm/tar.gz/$(PKG_FCEUMM_VERSION)?
  HASH:=b067ebd0a973751e9b5af56f5b54d74d0a6e67349549b392a4615d3f0d44f031
endef
$(eval $(call Download,fceumm))

define Package/nes-emulator
  SECTION:=multimedia
  CATEGORY:=Multimedia
  TITLE:=NES emulator service with built-in FCEUmm
  URL:=https://github.com/communism420/openwrt-nes-emulator
  DEPENDS:=+libatomic +libpthread
  USERID:=nesd:nesd
endef

define Package/nes-emulator/description
  Lightweight NES emulator service for OpenWrt with HTTP and WebSocket
  streaming. The pinned FCEUmm libretro core is linked into nesd, so no
  separate emulator-core package or shared object is required at run time.
endef

define Package/nes-emulator/conffiles
/etc/config/nes-emulator
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	$(INSTALL_DIR) $(FCEUMM_BUILD_DIR)
	gzip -dc $(DL_DIR)/libretro-fceumm-$(PKG_FCEUMM_VERSION).tar.gz | \
		$(HOST_TAR) --strip-components=1 \
			-C $(FCEUMM_BUILD_DIR) $(TAR_OPTIONS)
	$(call PatchDir,$(FCEUMM_BUILD_DIR),\
		$(CURDIR)/patches-fceumm,)
	$(if $(QUILT),touch $(FCEUMM_BUILD_DIR)/.quilt_used)
endef

define Quilt/Refresh/Package
	$(call Quilt/RefreshDir,$(FCEUMM_BUILD_DIR),\
		$(CURDIR)/patches-fceumm)
endef

# The only downstream patch stack belongs to the separately unpacked core.
Build/Quilt=$(call Quilt/Template,$(FCEUMM_BUILD_DIR),,,Package)

define Build/Compile
	+$(MAKE) $(PKG_JOBS) -C $(PKG_BUILD_DIR)/package/nes-emulator/src \
		BUILD_DIR="$(PKG_BUILD_DIR)/.nesd-build" \
		TARGET="$(PKG_BUILD_DIR)/nesd" \
		FCEUMM_DIR="$(FCEUMM_BUILD_DIR)" \
		FCEUMM_GIT_VERSION="$(PKG_FCEUMM_VERSION)" \
		FCEUMM_ENDIAN_CPPFLAGS="$(if $(filter y,$(CONFIG_BIG_ENDIAN)),-DMSB_FIRST)" \
		CC="$(TARGET_CC)" \
		AR="$(TARGET_AR)" \
		RANLIB="$(TARGET_RANLIB)" \
		CPPFLAGS="$(TARGET_CPPFLAGS)" \
		CFLAGS="$(TARGET_CFLAGS) -std=c11" \
		LDFLAGS="$(TARGET_LDFLAGS) -Wl,-z,stack-size=2097152" \
		LDLIBS="-ldl -lpthread -lm -latomic"
endef

define Package/nes-emulator/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/nesd $(1)/usr/bin/nesd

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(CURDIR)/files/nes-emulator.init \
		$(1)/etc/init.d/nes-emulator

	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(CURDIR)/files/nes-emulator.config \
		$(1)/etc/config/nes-emulator
endef

$(eval $(call BuildPackage,nes-emulator))
