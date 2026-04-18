include $(TOPDIR)/rules.mk

PKG_NAME:=ipq-art-editor
PKG_VERSION:=1.0.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/gvvsnrnaveen/ipq-art-editor/archive/refs/tags/
PKG_HASH:=a6cb8191f9f06c7538c5ee7328c850a8ecd085573460e1afeae4e3b82f7b559e
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_LICENSE:=GPL-3.0-only
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=G. Naveen Kumar <naveenkumar.gvvsnr@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/ipq-art-editor
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=IPQ ART partition editor utility
  URL:=https://github.com/gvvsnrnaveen/ipq-art-editor
endef

define Package/ipq-art-editor/description
  Utility to update MAC addresses, customer data, and raw bytes in
  Qualcomm IPQ ART partitions/files and recalculate ART checksum.
  Supports IPQ60xx and IPQ80xx platforms
endef

TARGET_CFLAGS += -Wall -Wextra

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR)/src \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)"
endef

define Package/ipq-art-editor/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/ipq_art_editor $(1)/usr/sbin/ipq-art-editor
endef

$(eval $(call BuildPackage,ipq-art-editor))
