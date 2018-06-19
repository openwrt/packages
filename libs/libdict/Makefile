include $(TOPDIR)/rules.mk

PKG_NAME:=libdict
PKG_RELEASE=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL=https://github.com/fmela/libdict.git
PKG_SOURCE_DATE:=2018-05-20
PKG_SOURCE_VERSION:=95f6d27f277932272578b2554104e1e4414cfaac
PKG_MIRROR_HASH:=6231b7d874807b333f8b1f2821f450a554c002b07d2248d04b9cfed40e2adec4

PKG_LICENSE:=BSD
PKG_INSTALL:=1

PKG_MAINTAINER:=Rosy Song <rosysong@rosinson.com>

include $(INCLUDE_DIR)/package.mk

define Package/libdict
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=C library of key-value data structures
endef

MAKE_INSTALL_FLAGS += \
	INSTALL_USER="$(shell whoami)" \
	INSTALL_GROUP="$(shell whoami)" \
	INSTALL_PREFIX="$(PKG_INSTALL_DIR)" \
	INSTALL_EXTRA_ARGS="-s --strip-program=$(TARGET_CROSS)strip"

define Package/libdict/InstallDEV
	$(INSTALL_DIR) $(1)/include
	$(CP) $(PKG_INSTALL_DIR)/include/dict $(1)/include/
	$(INSTALL_DIR) $(1)/lib
	$(CP) $(PKG_INSTALL_DIR)/lib/libdict* $(1)/lib/
endef

define Package/libdict/install
	$(INSTALL_DIR) $(1)/lib
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/lib/libdict.so* $(1)/lib/
endef

$(eval $(call BuildPackage,libdict))
