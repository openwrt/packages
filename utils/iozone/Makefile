include $(TOPDIR)/rules.mk

PKG_NAME:=iozone
PKG_REAL_VERSION:=3_510
PKG_VERSION:=$(subst _,.,$(PKG_REAL_VERSION))
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)$(PKG_REAL_VERSION).tar
PKG_SOURCE_URL:=https://www.iozone.org/src/current/
PKG_HASH:=9284601c4665a1bb171307e8b9e1d62360d6598e4b0e7a5641320966d9a6a5f7

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)$(PKG_REAL_VERSION)
MAKE_PATH:=src/current

PKG_MAINTAINER:=John Audia <therealgraysky@proton.me>
PKG_LICENSE:=LicenseRef-CUSTOM
PKG_LICENSE_FILES:=docs/License.txt

include $(INCLUDE_DIR)/package.mk

define Package/iozone
  SECTION:=utils
  SUBMENU:=Filesystem
  CATEGORY:=Utilities
  TITLE:=A filesystem benchmark tool
  URL:=https://www.iozone.org
endef


define Package/iozone/description
 IOzone is a filesystem benchmark tool. The benchmark generates and
 measures a variety of file operations. Iozone has been ported to
 many machines and runs under many operating systems.
 Iozone is useful for performing a broad filesystem analysis of a vendors
 computer platform. The benchmark tests file I/O performance for the following
 operations: Read, write, re-read, re-write, read backwards, read strided,
 fread, fwrite, random read, pread ,mmap, aio_read, aio_write.
endef

define Build/Compile
	$(call Build/Compile/Default,linux-generic)
endef

define Package/iozone/install
	$(INSTALL_DIR) $(1)/usr/bin/
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/$(MAKE_PATH)/iozone $(1)/usr/bin/
endef

$(eval $(call BuildPackage,iozone))
