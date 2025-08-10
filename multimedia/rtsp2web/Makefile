# SPDX-License-Identifier: Unlicense

include $(TOPDIR)/rules.mk

PKG_NAME:=rtsp2web
PKG_VERSION:=0.0.5
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/mpromonet/rtsp2web
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_MIRROR_HASH:=fb2fef69acd61482af1f09ce1b9e29b6735595136305e420a29a27ba8fea134c

PKG_BUILD_FLAGS:=gc-sections lto

LIVE555_VERSION:=2025.07.19
LIVE555_HASH:=1eaf6d468b51baa8bb8c4cf9197a5b02fb852cfa5937e44f7bbce99cb03ded3d
LIVE555_FILE:=live.$(LIVE555_VERSION).tar.gz

PKG_MAINTAINER:=Michel Promonet <michel.promonet@free.fr>
PKG_LICENSE:=Unlicense
PKG_LICENSE_FILES:=LICENCE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/rtsp2web
	SECTION:=multimedia
	CATEGORY:=Multimedia
	TITLE:=rtsp2web
	DEPENDS:=+libstdcpp +alsa-lib +libopenssl
	URL:=https://github.com/mpromonet/rtsp2web
endef

define Package/rtsp2web/description
	RTSP to websocket proxy
endef

define Package/rtsp2web/conffiles
/etc/config/rtsp2web
endef

TARGET_CFLAGS += -DVERSION=\\\"$(PKG_VERSION)\\\"

define Download/live555
	URL:=https://download.videolan.org/pub/contrib/live555/
	FILE:=$(LIVE555_FILE)
	HASH:=$(LIVE555_HASH)
endef

define Build/Prepare
	# download live555
	$(eval $(call Download,live555))
	mkdir -p $(PKG_BUILD_DIR)/live
	$(TAR) -xf $(DL_DIR)/$(LIVE555_FILE) --strip=1 -C $(PKG_BUILD_DIR)/live
	$(Build/Prepare/Default)
endef

define Package/rtsp2web/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/rtsp2ws $(1)/usr/bin/$(PKG_NAME)

	$(INSTALL_DIR) $(1)/usr/share/$(PKG_NAME)
	$(CP) $(PKG_INSTALL_DIR)/usr/share/rtsp2ws/* $(1)/usr/share/$(PKG_NAME)

	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) files/$(PKG_NAME).init $(1)/etc/init.d/$(PKG_NAME)
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) files/$(PKG_NAME).config $(1)/etc/config/$(PKG_NAME)
endef

$(eval $(call BuildPackage,rtsp2web))
