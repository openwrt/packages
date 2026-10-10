include $(TOPDIR)/rules.mk

PKG_NAME:=veracrypt
PKG_VERSION:=1.26.29
PKG_RELEASE:=1

PKG_SOURCE:=VeraCrypt_$(PKG_VERSION)_Source.tar.bz2
PKG_SOURCE_URL:=https://github.com/veracrypt/VeraCrypt/releases/download/VeraCrypt_$(PKG_VERSION)
PKG_HASH:=60826731e2982b4bd231e3930e85a44391169638671a1b200c518f8c8b46cb2a

PKG_MAINTAINER:=Ville Takio <ville+git@takio.fi>
PKG_LICENSE:=Apache-2.0 AND LicenseRef-TrueCrypt-3.0
PKG_LICENSE_FILES:=License.txt
PKG_CPE_ID:=cpe:/a:idrix:veracrypt

PKG_BUILD_PARALLEL:=1
PKG_BUILD_DEPENDS:=pcsc-lite

include $(INCLUDE_DIR)/package.mk

# The release tarball has no top-level directory.
TAR_CMD=$(HOST_TAR) -C $(1) $(TAR_OPTIONS)

define Package/veracrypt
  SECTION:=utils
  CATEGORY:=Utilities
  SUBMENU:=Encryption
  TITLE:=VeraCrypt disk encryption (console)
  URL:=https://www.veracrypt.fr/
  DEPENDS:=+libstdcpp +libwxbase +libfuse3 +fuse3-utils +losetup +kmod-loop
endef

define Package/veracrypt/description
  Console-only VeraCrypt. Mounts encrypted volumes via FUSE3 and a
  loop device.
  x86 builds use portable C crypto without assembler (no AES-NI);
  other targets use the C/intrinsics code, including ARMv8 AES.
  dmsetup (lvm2) is not a dependency: without it volumes are mounted
  and formatted through FUSE. With lvm2 installed, VeraCrypt uses
  kernel dm-crypt, which on OpenWrt needs kmod-crypto-xts (built in on
  x86_64) and supports AES only; for other ciphers and cascades pass
  --mount-options=nokernelcrypto (mount.veracrypt: -o nokernelcrypto).
  PKCS #11 security tokens work with --token-lib; EMV smart card
  keyfiles are not supported. --filesystem=ext4 needs e2fsprogs
  (mkfs.ext4). /etc/config/veracrypt holds the settings and volumes
  used by luci-app-veracrypt.
endef

MAKE_PATH:=src

MAKE_FLAGS += \
	$(if $(filter i386 x86_64,$(ARCH)),NOASM=1) \
	NOGUI=1 \
	WITHFUSE3=1 \
	NOTEST=1 \
	NOSTRIP=1 \
	WX_CONFIG="$(STAGING_DIR)/host/bin/wx-config" \
	$(if $(findstring s,$(OPENWRT_VERBOSE)),VERBOSE=1) \
	TC_EXTRA_CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS)" \
	TC_EXTRA_CXXFLAGS="$(TARGET_CXXFLAGS) $(TARGET_CPPFLAGS)" \
	TC_EXTRA_LFLAGS="$(TARGET_LDFLAGS)"

define Package/veracrypt/conffiles
/etc/config/veracrypt
endef

define Package/veracrypt/install
	$(INSTALL_DIR) $(1)/usr/bin $(1)/sbin $(1)/etc/config $(1)/usr/share/doc/veracrypt
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/Main/veracrypt $(1)/usr/bin/veracrypt
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/Setup/Linux/mount.veracrypt $(1)/sbin/mount.veracrypt
	$(INSTALL_CONF) ./files/veracrypt.config $(1)/etc/config/veracrypt
	# TrueCrypt License 3.0 requires a copy with every distributed binary.
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/License.txt $(1)/usr/share/doc/veracrypt/License.txt
endef

$(eval $(call BuildPackage,veracrypt))
