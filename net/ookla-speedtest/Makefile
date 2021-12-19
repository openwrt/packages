include $(TOPDIR)/rules.mk

PKG_NAME:=ookla-speedtest
PKG_VERSION:=1.1.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-linux-x86_64.tgz
PKG_SOURCE_URL:=https://install.speedtest.net/app/cli/
PKG_HASH:=970477fdfee4d741e75f088faf648f9b51c7be04313fb88ffb5de07eb1a3040c

PKG_MAINTAINER:=James White <james@jmwhite.co.uk>

include $(INCLUDE_DIR)/package.mk

define Package/ookla-speedtest
    SECTION=:net
    CATEGORY:=Network
    DEPENDS:=@TARGET_x86_64
    TITLE:=Ookla Speedtest CLI
    URL:=https://www.speedtest.net/apps/cli
endef

define Package/speedtest-cli/description
    Speedtest CLI brings the trusted technology and global server network behind
    Speedtest to the command line. Built for software developers, system
    administrators and computer enthusiasts alike, Speedtest CLI is the first
    official Linux-native Speedtest application backed by Ookla.
endef

define Build/Prepare
    $(Build/Prepare/Default)
endef

define Build/Compile
endef

define Package/ookla-speedtest/install
    $(INSTALL_DIR) $(1)/usr/bin
    $(INSTALL_BIN) $(BUILD_DIR)/speedtest $(1)/usr/bin/speedtest
endef

$(eval $(call BuildPackage,ookla-speedtest))
