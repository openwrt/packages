include $(TOPDIR)/rules.mk

PKG_NAME:=owncast
PKG_VERSION:=0.0.10
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/owncast/owncast/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=b0d869cfe86e60a321b1c186fd626fe03d92835a260ec765510bc68ab22eaa3d

PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Nick Hainke <vincent@systemli.org>

HOST_BUILD_DEPENDS:=golang/host
HOST_BUILD_PARALLEL:=1

PKG_BUILD_DEPENDS:=golang/host
PKG_BUILD_PARALLEL:=1
PKG_USE_MIPS16:=0

GO_PKG:=github.com/owncast/owncast
GO_PKG_BUILD_PKG:=github.com/owncast/owncast/

include $(INCLUDE_DIR)/host-build.mk
include $(INCLUDE_DIR)/package.mk
include ../../lang/golang/golang-host-build.mk
include ../../lang/golang/golang-package.mk

define Package/owncast
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Streaming + chat out of the box.
  URL:=https://github.com/owncast/owncast
  DEPENDS:=$(GO_ARCH_DEPENDS)
endef

define Package/owncast/description
  Owncast is an open source, self-hosted, decentralized, single user
  live video streaming and chat server for running your own live
  streams similar in style to the large mainstream options. It offers
  complete ownership over your content, interface, moderation and
  audience.
endef

$(eval $(call GoBinHostBuild))
$(eval $(call HostBuild))
$(eval $(call GoBinPackage,owncast))
$(eval $(call BuildPackage,owncast))
