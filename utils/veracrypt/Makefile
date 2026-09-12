include $(TOPDIR)/rules.mk

PKG_NAME:=veracrypt
PKG_VERSION:=1.26.29
PKG_RELEASE:=1

PKG_SOURCE:=VeraCrypt_$(PKG_VERSION)_Source.tar.bz2
PKG_SOURCE_URL:=https://github.com/veracrypt/VeraCrypt/releases/download/VeraCrypt_$(PKG_VERSION)
PKG_HASH:=60826731e2982b4bd231e3930e85a44391169638671a1b200c518f8c8b46cb2a

PKG_MAINTAINER:=Ville Takio <ville+git@takio.fi>
PKG_LICENSE:=Apache-2.0 AND LicenseRef-TrueCrypt-3.0
PKG_LICENSE_FILES:=src/License.txt License.txt
PKG_CPE_ID:=cpe:/a:idrix:veracrypt

PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16
PKG_BUILD_DEPENDS:=fuse3

WX_VERSION:=3.2.10
WX_FILE:=wxWidgets-$(WX_VERSION).tar.bz2
WX_HASH:=d66e929569947a4a5920699539089a9bda83a93e5f4917fb313a61f0c344b896

include $(INCLUDE_DIR)/package.mk

define Package/veracrypt
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Encryption
  TITLE:=VeraCrypt disk encryption (console)
  URL:=https://www.veracrypt.fr/
  DEPENDS:=+libstdcpp +libatomic +fuse3-utils +losetup
endef

define Package/veracrypt/description
  Console-only VeraCrypt. Mounts encrypted volumes via FUSE3.
  Uses statically linked wxBase (no GUI). Crypto is portable C
  (no x86 assembler).
endef

define Download/wxwidgets
  URL:=https://github.com/wxWidgets/wxWidgets/releases/download/v$(WX_VERSION)
  FILE:=$(WX_FILE)
  HASH:=$(WX_HASH)
endef
$(eval $(call Download,wxwidgets))

# Official source tarball has no top-level directory.
PKG_UNPACK:=$(HOST_TAR) -C $(PKG_BUILD_DIR) $(TAR_OPTIONS)

define Build/Prepare
	$(call Build/Prepare/Default)
	$(TAR) -C $(PKG_BUILD_DIR) -xjf $(DL_DIR)/$(WX_FILE)
endef

# VeraCrypt's Makefile enables SIMD from the *host* GCC version.
# Force portable C for every target so cross-builds stay valid.
VC_MAKE_FLAGS = \
	AR="$(TARGET_AR)" \
	CC="$(TARGET_CC)" \
	CXX="$(TARGET_CXX)" \
	AS="$(TARGET_CC)" \
	RANLIB="$(TARGET_RANLIB)" \
	PKG_CONFIG="$(PKG_CONFIG)" \
	PKG_CONFIG_PATH="$(STAGING_DIR)/usr/lib/pkgconfig:$(STAGING_DIR)/usr/share/pkgconfig" \
	PKG_CONFIG_LIBDIR="$(STAGING_DIR)/usr/lib/pkgconfig:$(STAGING_DIR)/usr/share/pkgconfig" \
	WX_ROOT="$(PKG_BUILD_DIR)/wxWidgets-$(WX_VERSION)" \
	WX_BUILD_DIR="$(PKG_BUILD_DIR)/wxBuildConsole" \
	WX_CONFIGURE_EXTRA_FLAGS="--target=$(GNU_TARGET_NAME) --host=$(GNU_TARGET_NAME) --build=$(GNU_HOST_NAME) --prefix=/usr --exec-prefix=/usr --disable-rpath --with-libiconv=no --disable-gui --disable-shared" \
	TC_EXTRA_CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" \
	TC_EXTRA_CXXFLAGS="$(TARGET_CXXFLAGS) $(TARGET_CPPFLAGS)" \
	TC_EXTRA_LFLAGS="$(TARGET_LDFLAGS) -latomic" \
	CPU_ARCH=unknown \
	NOASM=1 \
	NOGUI=1 \
	WITHFUSE3=1 \
	WXSTATIC=1 \
	NOTEST=1 \
	NOSTRIP=1 \
	GCC_GTEQ_430=0 \
	GCC_GTEQ_440=0 \
	GCC_GTEQ_470=0 \
	GCC_GTEQ_500=0 \
	SIMD_SUPPORTED=0

define Build/Compile
	+$(MAKE) -C $(PKG_BUILD_DIR)/src $(VC_MAKE_FLAGS) wxbuild
	+$(MAKE) -C $(PKG_BUILD_DIR)/src $(PKG_JOBS) $(VC_MAKE_FLAGS)
endef

define Package/veracrypt/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/Main/veracrypt $(1)/usr/bin/veracrypt
	$(INSTALL_BIN) ./files/mount.veracrypt $(1)/sbin/mount.veracrypt
endef

$(eval $(call BuildPackage,veracrypt))
