#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=fastfetch
PKG_VERSION:=2.67.1
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://github.com/fastfetch-cli/fastfetch/archive/refs/tags/
PKG_HASH:=52489550d1fdeac8bde8b3442064e3bc78d28fda752a171dc46a6cd97454f237

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

PKG_MAINTAINER:=Murad Rabadanov <the21.21@mail.ru>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE
PKG_CPE_ID:=cpe:2.3:a:fastfetch:fastfetch

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/fastfetch
  SECTION:=utils
  CATEGORY:=Utilities
  TITLE:=Fast neofetch-like system information tool
  URL:=https://github.com/fastfetch-cli/fastfetch
  DEPENDS:=+zlib
endef

define Package/fastfetch/description
  Fastfetch is a neofetch-like tool for fetching system information and
  displaying it prettily, written mostly in C. It is designed to be fast
  and highly customizable while keeping runtime dependencies minimal.
endef

# Keep the build minimal and deterministic: only zlib and libc-provided
# features (threads, wordexp, wcwidth) are enabled. All optional detectors
# that need desktop/GUI/scripting libraries (X11, Wayland, GPU, DBus,
# ImageMagick, Lua, QuickJS, ZFS, ...) are disabled since they are not
# useful on a router and would otherwise be silently enabled or disabled
# depending on what happens to be present in staging_dir.
CMAKE_OPTIONS += \
	-DENABLE_VULKAN=OFF \
	-DENABLE_WAYLAND=OFF \
	-DENABLE_XCB_RANDR=OFF \
	-DENABLE_XRANDR=OFF \
	-DENABLE_DRM=OFF \
	-DENABLE_VADRM=OFF \
	-DENABLE_VAX11=OFF \
	-DENABLE_VDPAU=OFF \
	-DENABLE_GIO=OFF \
	-DENABLE_DCONF=OFF \
	-DENABLE_EET=OFF \
	-DENABLE_DBUS=OFF \
	-DENABLE_SQLITE3=OFF \
	-DENABLE_RPM=OFF \
	-DENABLE_IMAGEMAGICK7=OFF \
	-DENABLE_IMAGEMAGICK6=OFF \
	-DENABLE_CHAFA=OFF \
	-DENABLE_EGL=OFF \
	-DENABLE_GLX=OFF \
	-DENABLE_OPENCL=OFF \
	-DENABLE_FREETYPE=OFF \
	-DENABLE_PULSE=OFF \
	-DENABLE_DDCUTIL=OFF \
	-DENABLE_ELF=OFF \
	-DENABLE_LUA=OFF \
	-DENABLE_QUICKJS=OFF \
	-DENABLE_LIBZFS=OFF \
	-DENABLE_ZLIB=ON \
	-DENABLE_WORDEXP=ON \
	-DENABLE_WCWIDTH=ON \
	-DBUILD_FLASHFETCH=OFF \
	-DBUILD_TESTS=OFF \
	-DSET_TWEAK=OFF

define Package/fastfetch/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/fastfetch $(1)/usr/bin/
endef

$(eval $(call BuildPackage,fastfetch))
