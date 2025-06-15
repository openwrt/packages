include $(TOPDIR)/rules.mk

PKG_NAME:=earlyoom
PKG_VERSION:=1.8.2
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/rfjakob/earlyoom/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=13869413dc0d973e454854077be7a2049d350f77a97f6911b654e88dc4b20346

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Alice H. <alice.hall0451+github@gmail.com>

include $(INCLUDE_DIR)/package.mk

define Package/earlyoom
	SECTION:=admin
	CATEGORY:=Administration
	TITLE:=Early OOM Daemon for Linux
	URL:=https://github.com/rfjakob/earlyoom
endef

define Package/earlyoom/description
	earlyoom checks the amount of available memory and swap at
	an adaptive rate for up to 10 times per second. When both
	available memory and swap are below threshold, it'll send
	SIGTERM or SIGKILL to the process with highest oom_score.
endef

MAKE_VARS += \
	VERSION=v$(PKG_VERSION)

define Package/earlyoom/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/earlyoom $(1)/usr/sbin/earlyoom
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_CONF) $(CURDIR)/files/earlyoom.config $(1)/etc/config/earlyoom
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(CURDIR)/files/earlyoom.init $(1)/etc/init.d/earlyoom
endef

$(eval $(call BuildPackage,earlyoom))
