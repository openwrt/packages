include $(TOPDIR)/rules.mk

PKG_NAME:=conmon
PKG_VERSION:=2.1.7
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/containers/$(PKG_NAME)/archive/v$(PKG_VERSION)
PKG_HASH:=7d0f9a2f7cb8a76c51990128ac837aaf0cc89950b6ef9972e94417aa9cf901fe

PKG_MAINTAINER:=Oskari Rauta <oskari.rauta@gmail.com>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_DEPENDS:=libseccomp

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/nls.mk
include $(INCLUDE_DIR)/meson.mk

define Package/conmon
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Podman conmon
  URL:=https://podman.io
  DEPENDS:=@!arc +glib2 $(INTL_DEPENDS) $(ICONV_DEPENDS)
endef

define Package/conmon/description
  An OCI container runtime monitor.

  Conmon is a monitoring program and communication tool between
  a container manager (like Podman or CRI-O) and an OCI runtime
  (like runc or crun) for a single container.
endef

define Package/conmon/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/libexec/podman/conmon $(1)/usr/bin
endef

$(eval $(call BuildPackage,conmon))
