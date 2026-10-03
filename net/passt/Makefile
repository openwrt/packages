include $(TOPDIR)/rules.mk

PKG_NAME:=passt
PKG_VERSION:=2026.09.25
PKG_REV:=df90211
PKG_REALVERSION:=$(subst .,_,$(PKG_VERSION)).$(PKG_REV)
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_REALVERSION).tar.xz
PKG_SOURCE_URL:=https://passt.top/passt/snapshot
PKG_HASH:=cdf655b5677ce219108cf3df93a55e0ae98a376887be110fe35303ea900d5d68

PKG_MAINTAINER:=Gary Dotzler <geldot@protonmail.com>
PKG_LICENSE:=GPL-2.0-or-later BSD-3-Clause
PKG_LICENSE_FILES:=LICENSES/GPL-2.0-or-later.txt LICENSES/BSD-3-Clause.txt

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_REALVERSION)
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk

define Package/passt
  SECTION:=net
  CATEGORY:=Network
  TITLE:=User-mode networking for virtual machines and namespaces
  DEPENDS:=+kmod-tun
  URL:=https://passt.top
endef

define Package/passt/description
  passt provides user-mode networking for virtual machines.
  It also includes pasta for unprivileged network namespaces,
  typically used for rootless container networking.
endef

MAKE_FLAGS += \
	FORTIFY_FLAG= \
	VERSION="$(PKG_REALVERSION)"

define Build/Compile
	$(call Build/Compile/Default,passt pasta)
endef

define Package/passt/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/passt $(1)/usr/bin/
	$(LN) passt $(1)/usr/bin/pasta
endef

$(eval $(call BuildPackage,passt))
