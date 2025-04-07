include $(TOPDIR)/rules.mk

PKG_NAME:=enterprise-numbers
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_DATE:=2025-04-04
PKG_SOURCE_VERSION:=v$(PKG_VERSION)
PKG_SOURCE_URL:=https://github.com/TDT-AG/enterprise-numbers.git
PKG_MIRROR_HASH:=2af409df4e1c8528653828b567c53101916b12e5fc5053db074c889f5ada5679

PKG_LICENSE:=CC0-1.0
PKG_MAINTAINER:=Oliver Sedlbauer <osedlbauer@tdt.de>

include $(INCLUDE_DIR)/package.mk

define Package/enterprise-numbers
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=IANA Enterprise Numbers
endef

define Package/enterprise-numbers/description
  A user-space utility to download and store the IANA Enterprise Numbers (PEN).
  These numbers are used by ipmitool to identify vendors.
endef

define Build/Compile
endef

define Package/enterprise-numbers/install
	$(INSTALL_DIR) $(1)/usr/share/misc
	$(INSTALL_DATA) $(PKG_BUILD_DIR)/enterprise-numbers.txt \
		$(1)/usr/share/misc/enterprise-numbers
endef

$(eval $(call BuildPackage,enterprise-numbers))
