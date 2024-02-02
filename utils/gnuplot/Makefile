include $(TOPDIR)/rules.mk

PKG_NAME:=gnuplot
PKG_VERSION:=5.4.2
PKG_RELEASE:=2
PKG_MAINTAINER:=Matteo Cicuttin <datafl4sh@toxicnet.eu>
PKG_CPE_ID:=cpe:/a:gnuplot_project:gnuplot

PKG_BUILD_DIR:=$(BUILD_DIR)/gnuplot-$(PKG_VERSION)
PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=@SF/gnuplot
PKG_HASH:=e57c75e1318133951d32a83bcdc4aff17fed28722c4e71f2305cfc2ae1cae7ba
PKG_CAT:=zcat
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/gnuplot
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+zlib +libgd +libncursesw +libreadline
  TITLE:=A portable command-line driven graphing utility
  URL:=http://www.gnuplot.info/
endef

CONFIGURE_ARGS += \
    --without-cairo \
    --with-qt=no \
    --without-lua \
    --without-latex \
    --without-libcerf

CONFIGURE_VARS += ac_cv_have_x="have_x=no"

# Since Qt is disabled there is no C++ code, so CXX is forced
# to CC in order to avoid dependency on libstdcpp. This is 
# horrible, but 'DEPENDS:=+libstdcpp' does not work for some
# reason. 
define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		CXX="$(TARGET_CC_NOCACHE)"  
endef

define Package/gnuplot/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/gnuplot $(1)/usr/bin
endef

$(eval $(call BuildPackage,gnuplot))

