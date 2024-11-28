include $(TOPDIR)/rules.mk

PKG_NAME:=shonenjump
PKG_VERSION:=0.8.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/suzaku/$(PKG_NAME)/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=ff02e0872c96dbaecdb64e8ad977a98260ec1a105869d8cf4b988ac579dcf789

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=John Audia <therealgraysky@proton.me>

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_BUILD_FLAGS:=no-mips16

GO_PKG:=github.com/suzaku/shonenjump

include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-package.mk

define Package/shonenjump
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Lightweight autojump clone written in Go
  URL:=https://github.com/suzaku/shonenjump
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/shonenjump/description
Quote from the description of autojump:

autojump is a faster way to navigate your filesystem. It works by maintaining a database of the directories you use the most from the command line.

Directories must be visited first before they can be jumped to.
endef

define Package/shonenjump/install
	$(call GoPackage/Package/Install/Bin,$(1))
	$(INSTALL_DIR) $(1)/usr/share/shonenjump
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/scripts/shonenjump.bash $(1)/usr/share/shonenjump
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/scripts/shonenjump.fish $(1)/usr/share/shonenjump
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/scripts/shonenjump.zsh $(1)/usr/share/shonenjump
	$(INSTALL_DIR) $(1)/usr/share/zsh/site-functions
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/scripts/_j $(1)/usr/share/zsh/site-functions
endef

$(eval $(call GoBinPackage,shonenjump))
$(eval $(call BuildPackage,shonenjump))
