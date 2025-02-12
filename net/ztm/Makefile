include $(TOPDIR)/rules.mk

PKG_NAME:=ztm
PKG_VERSION:=1.5.9
PKG_RELEASE:=1

PKG_SOURCE_PROTO:=git
PKG_SOURCE_URL:=https://github.com/flomesh-io/pipy.git
PKG_MIRROR_HASH:=bab44ce1fa8aff613e71fee6b3e0621163764df97739c41175af01511a1ca3a8
PKG_SOURCE_VERSION:=ddd5f55915eaca575ac782c4a12c0e3110d3d5e2
PKG_SOURCE_DATE:=2025-01-16
PKG_MAINTAINER:=Flomesh <contact@flomesh.io>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

CMAKE_OPTIONS += -DCMAKE_BUILD_TYPE=Release
CMAKE_OPTIONS += -DPIPY_GUI=OFF
CMAKE_OPTIONS += -DPIPY_CODEBASES=ON
CMAKE_OPTIONS += -DPIPY_DEFAULT_OPTIONS="repo://ztm/cli --args"
CMAKE_OPTIONS += -DPIPY_USE_SYSTEM_ZLIB=ON
CMAKE_OPTIONS += -DPIPY_USE_SYSTEM_OPENSSL=ON
CMAKE_OPTIONS += -DCMAKE_EXE_LINKER_FLAGS="-static-libstdc++ -Wl,--no-as-needed -latomic -lpthread"

ifdef CONFIG_OPENSSL_VERSION_1_1
  CMAKE_OPTIONS += -DPIPY_USE_OPENSSL1=ON
endif

define Package/ztm
  SECTION:=net
  CATEGORY:=Network
  TITLE:=ZTM:Privacy first open-source decentralized network mesh
  URL:=https://github.com/flomesh-io/ztm
  DEPENDS:=+libstdcpp +zlib +libopenssl +libpthread +libatomic
endef

define Package/ztm/description
ZTM (Zero Trust Mesh) is a privacy-first open-source decentralized network software based on HTTP/2 tunnels. Experience boundless connectivity and mesh the globe!
endef

define Build/Configure
	$(call Build/Configure/Default)
endef

define Build/Prepare
	$(call Build/Prepare/Default)
	cp ./files/codebases.tar.gz.h $(PKG_BUILD_DIR)/codebases.tar.gz.h
	echo '#ifndef __VERSION_H__' > $(PKG_BUILD_DIR)/version.h
	echo '#define __VERSION_H__' >> $(PKG_BUILD_DIR)/version.h
	echo '#define PIPY_VERSION "$(PKG_VERSION)"' >> $(PKG_BUILD_DIR)/version.h
	echo '#define PIPY_COMMIT "$(PKG_SOURCE_VERSION)"' >> $(PKG_BUILD_DIR)/version.h
	echo '#define PIPY_COMMIT_DATE "$(PKG_SOURCE_DATE)"' >> $(PKG_BUILD_DIR)/version.h
	echo '#endif // __VERSION_H__' >> $(PKG_BUILD_DIR)/version.h	
endef

define Build/Compile
	$(call Build/Compile/Default)
endef

define Package/ztm/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bin/pipy $(1)/usr/bin/ztm
endef

$(eval $(call BuildPackage,ztm))

