include $(TOPDIR)/rules.mk

PKG_NAME:=libcgroup
PKG_VERSION:=0.41
PKG_RELEASE:=1
PKG_LICENSE:=LGPL
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.bz2
PKG_SOURCE_URL:=@SF/libcg
PKG_HASH:=e4e38bdc7ef70645ce33740ddcca051248d56b53283c0dc6d404e17706f6fb51
PKG_MAINTAINER:=Daniel Danzberger <daniel@dd-wrt.com>

PKG_BUILD_PARALLEL:=1
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/libcgroup
  TITLE:=CGroup config and exec library
  SECTION:=libs
  CATEGORY:=Libraries
  DEPENDS:=+musl-fts +@KERNEL_CGROUPS
endef

define Package/cgroup-tools
  TITLE:=CGroup config and exec tools
  DEPENDS:=+libcgroup
  CATEGORY:=Utilities
endef

define Package/libcgroup/description
  Helpers utils for working with cgroups.
endef

CONFIGURE_ARGS += --enable-tools \
		--enable-shared \
		--disable-daemon \
		--disable-pam

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include $(1)/usr/lib $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_BUILD_DIR)/include/libcgroup.h $(1)/usr/include
	$(CP) $(PKG_BUILD_DIR)/include/libcgroup $(1)/usr/include
	$(CP) $(PKG_BUILD_DIR)/src/.libs/libcgroup.so* $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libcgroup.pc $(1)/usr/lib/pkgconfig/
endef

define Package/libcgroup/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/src/.libs/libcgroup.so* $(1)/usr/lib
endef

define Package/cgroup-tools/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/tools/.libs/* $(1)/usr/bin
endef

$(eval $(call BuildPackage,libcgroup))
$(eval $(call BuildPackage,cgroup-tools))
