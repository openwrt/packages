include $(TOPDIR)/rules.mk

PKG_NAME:=ratelimit
PKG_RELEASE:=1

PKG_LICENSE:=MIT
PKG_MAINTAINER:=Thibaut VARÈNE <hacks@slashdirt.org>

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/f00b4r0/ratelimit.git
PKG_SOURCE_DATE:=2025-06-07
PKG_SOURCE_VERSION:=4ef5917170b544fffcb1f3be92c73331321c7f0c
PKG_MIRROR_HASH:=95292fa86e2652c5a7665c14ae83806ca8ef9ad3ee1826f5b20663ae8987d59a

include $(INCLUDE_DIR)/package.mk
define Package/ratelimit
  SECTION:=net
  CATEGORY:=Network
  TITLE:=client devices ratelimiting daemon
  DEPENDS:=+tc +kmod-ifb +ucode-mod-log
  PKGARCH:=all
endef

define Package/ratelimit/description
  This daemon provides a stateful interface to the HTB traffic shaper,
  enabling per-client bandwidth limits assignment.
endef

define Package/ratelimit/conffiles
/etc/config/ratelimit
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile/Default

endef
Build/Compile = $(Build/Compile/Default)

define Package/ratelimit/install
	$(CP) ./files/* $(1)
endef

$(eval $(call BuildPackage,ratelimit))
