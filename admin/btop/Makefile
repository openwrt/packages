include $(TOPDIR)/rules.mk

PKG_NAME:=btop
PKG_VERSION:=1.2.12
PKG_RELEASE:=$(AUTORELEASE)

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL=https://codeload.github.com/aristocratos/btop/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=158112184372ff93de68700ad7de12f91be0542c0ecf75ffb002326ecbb3ca76

PKG_MAINTAINER:=Tianling Shen <cnsztl@immortalwrt.org>
PKG_LICENSE:=Apache-2.0
PKG_LICENSE_FILES:=LICENSE

PKG_BUILD_PARALLEL:=1
PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk

define Package/btop
  SECTION:=admin
  CATEGORY:=Administration
  TITLE:=A monitor of resources
  URL:=https://github.com/aristocratos/btop
  DEPENDS:=+libstdcpp
endef

define Package/btop/description
  Resource monitor that shows usage and stats for processor, memory,
  disks, network and processes.

  C++ version and continuation of bashtop and bpytop.
endef

MAKE_FLAGS+= \
	PLATFORM=Linux \
	OPTFLAGS="$(TARGET_CXXFLAGS)" \
	LDCXXFLAGS="$(TARGET_LDFLAGS) -pthread"

define Package/btop/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/local/bin/btop $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/usr/share
	$(CP) $(PKG_INSTALL_DIR)/usr/local/share/btop $(1)/usr/share/
endef

$(eval $(call BuildPackage,btop))
