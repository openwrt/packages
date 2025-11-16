include $(TOPDIR)/rules.mk

PKG_NAME:=go2rtc
PKG_VERSION:=1.9.12
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/AlexxIT/go2rtc.git
PKG_MIRROR_HASH:=097ddc9a9837c2705c0a7da2ae7dd671673697048955240b82b3db9eb370deb5
PKG_SOURCE_VERSION:=v$(PKG_VERSION)

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Vladimir Ermakov <vooon341@gmail.com>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/AlexxIT/go2rtc
GO_PKG_EXCLUDES:=examples/

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/go2rtc
  SECTION:=multimedia
  CATEGORY:=Multimedia
  TITLE:=go2rtc camera streaming
  URL:=https://github.com/AlexxIT/go2rtc
  DEPENDS:=$(GO_ARCH_DEPENDS) +ffmpeg
  USERID:=go2rtc:go2rtc
endef

define Package/go2rtc/description
  Ultimate camera streaming application with support RTSP, WebRTC, HomeKit, FFmpeg, RTMP, etc.
endef

define Package/go2rtc/conffiles
/etc/go2rtc.yaml
/etc/config/go2rtc
endef

define Package/go2rtc/install
	$(call GoPackage/Package/Install/Bin,$(1))

	$(INSTALL_DIR) $(1)/etc/
	$(INSTALL_CONF) $(CURDIR)/files/go2rtc.yaml $(1)/etc/go2rtc.yaml
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) $(CURDIR)/files/go2rtc.init $(1)/etc/init.d/go2rtc
	$(INSTALL_DIR) $(1)/etc/capabilities/
	$(INSTALL_DATA) $(CURDIR)/files/go2rtc.json $(1)/etc/capabilities/go2rtc.json
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(CURDIR)/files/go2rtc.conf $(1)/etc/config/go2rtc
endef

$(eval $(call BuildPackage,go2rtc))
