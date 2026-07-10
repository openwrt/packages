#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=stress-ng
PKG_VERSION:=0.21.03
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/ColinIanKing/stress-ng/tar.gz/refs/tags/V$(PKG_VERSION)?
PKG_HASH:=6db7089ad9cc2c13d0aa1cf8755112adac92858f4582a46c765bb6b7e1c3e1af

PKG_MAINTAINER:=Alexandru Ardelean <ardeleanalex@gmail.com>
PKG_LICENSE:=GPL-2.0-only
PKG_LICENSE_FILES:=COPYING

PKG_INSTALL:=1
PKG_BUILD_PARALLEL:=1
# For MIPS there is some inline assembly, and this won't compile without '-mno-mips16'
PKG_BUILD_FLAGS:=no-mips16

include $(INCLUDE_DIR)/package.mk

define Package/stress-ng
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=stress-ng is a stress test utility
  URL:=https://github.com/ColinIanKing/stress-ng
  DEPENDS:=+libatomic \
	   +USE_GLIBC:libcrypt-compat \
	   +STRESS_NG_LIB_ACL:libacl \
	   +STRESS_NG_LIB_AIO:libaio \
	   +STRESS_NG_LIB_APPARMOR:libapparmor \
	   +STRESS_NG_LIB_BSD:libbsd \
	   +STRESS_NG_LIB_GMP:libgmp \
	   +STRESS_NG_LIB_JPEG:libjpeg \
	   +STRESS_NG_LIB_KMOD:libkmod \
	   +STRESS_NG_LIB_LZMA:liblzma \
	   +STRESS_NG_LIB_MD:libmd \
	   +STRESS_NG_LIB_MPFR:libmpfr \
	   +STRESS_NG_LIB_SCTP:libsctp \
	   +STRESS_NG_LIB_XXHASH:libxxhash \
	   +STRESS_NG_LIB_Z:zlib
  PROVIDES:=stress
endef

define Package/stress-ng/config
	source "$(SOURCE)/Config.in"
endef

define Package/stress-ng/description
stress-ng will stress test a computer system in various selectable ways. It
was designed to exercise various physical subsystems of a computer as well as
the various operating system kernel interfaces.
endef

STRESS_NG_LIBS:=ACL AIO APPARMOR BSD CRYPT GMP JPEG KMOD LZMA MD MPFR SCTP XXHASH Z

MAKE_FLAGS += \
	KERNEL=Linux \
	LIB_ATOMIC=-latomic

# No OpenWrt package provides these, so never probe for them
MAKE_FLAGS += \
	LIB_EGL= \
	LIB_GBM= \
	LIB_GLES2= \
	LIB_IPSEC_MB= \
	LIB_JUDY=

MAKE_FLAGS += $(foreach l,$(STRESS_NG_LIBS),$(if $(CONFIG_STRESS_NG_LIB_$(l)),,LIB_$(l)=))

define Package/stress-ng/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/stress-ng $(1)/usr/bin/
endef

$(eval $(call BuildPackage,stress-ng))
