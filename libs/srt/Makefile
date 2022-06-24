#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=srt
PKG_VERSION:=1.5.0
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_SOURCE_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/Haivision/$(PKG_NAME)/archive/refs/tags/v$(PKG_VERSION).tar.gz?
PKG_HASH:=99e3625a6285b3b429af26abb1ec0a4bd0072db144bc4d617a83154d99a5dd1e

PKG_MAINTAINER:=Han Han <hanhanzhiyeqianke@gmail.com>
PKG_LICENSE:=MPL-2.0
PKG_LICENSE_FILES:=LICENSE

CMAKE_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS += -DBUILD_SHARED_LIBS=ON
CMAKE_OPTIONS += -DENABLE_GETNAMEINFO=ON
CMAKE_OPTIONS += -DUSE_ENCLIB=gnutls

define Package/srt/Default
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=Secure Reliable Transport
  URL:=https://github.com/Haivision/srt
  DEPENDS:=+libgnutls +libstdcpp
endef

define Package/srt/Default/description
  Secure Reliable Transport (SRT) is a transport protocol for ultra low (sub-second)
  latency live video and audio streaming, as well as for generic bulk data transfer1.
endef

define Package/srt-utils
$(call Package/srt/Default)
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE+= (srt utility)
  DEPENDS+= +libsrt
endef

define Package/srt-utils/description
$(call Package/srt/Default/description)
 This package contains the srt utility.
endef

define Package/srt-utils/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/srt-* $(1)/usr/bin/
endef

define Package/libsrt
$(call Package/srt/Default)
  TITLE+= (library)
endef

define Package/libsrt/description
$(call Package/srt/Default/description)
 This package contains the srt libraries.
endef

define Package/libsrt/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libsrt.so* $(1)/usr/lib/
endef

define Build/InstallDev
	$(call Build/InstallDev/cmake,$(1))
	$(SED) 's,/usr/include,$$$${prefix}/include,g' $(1)/usr/lib/pkgconfig/srt.pc
	$(SED) 's,/usr/lib,$$$${exec_prefix}/lib,g' $(1)/usr/lib/pkgconfig/srt.pc
endef

$(eval $(call BuildPackage,srt-utils))
$(eval $(call BuildPackage,libsrt))
