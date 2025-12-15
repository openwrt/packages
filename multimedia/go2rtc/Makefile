include $(TOPDIR)/rules.mk

PKG_NAME:=go2rtc
PKG_VERSION:=1.9.13
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/AlexxIT/go2rtc.git
PKG_MIRROR_HASH:=74ee944e3b3855d9afc0d60f833b99f3378f78d20714e4b759da41c98126fa57
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

# NOTE: Since version 1.9.9 project contains some arch-dependent code,
#       which should be selected by magic go comments or file endings,
#       which unfortunately sometimes breaks on openwrt for some targets.
#	So I mark package as broken for some of known bad targets.
#
#       MIPS - only mipsel variant supported
#       RV64 - currently selection broken
#
GO2RTC_DEPENDS:=@mips:BROKEN @mips64:BROKEN @riscv64:BROKEN

define Package/go2rtc
  SECTION:=multimedia
  CATEGORY:=Multimedia
  TITLE:=go2rtc camera streaming
  URL:=https://github.com/AlexxIT/go2rtc
  DEPENDS:=$(GO_ARCH_DEPENDS) $(GO2RTC_DEPENDS) +ffmpeg
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
