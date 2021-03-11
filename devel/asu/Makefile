# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=asu
PKG_VERSION:=0.2.3
PKG_RELEASE:=3

PKG_LICENSE:=GPL-3.0

PYPI_NAME:=$(PKG_NAME)
PKG_HASH:=e60027cd531cc5b9b20d3321acc06fdf0cdd894004919800575b8235343ba8ef

PKG_BUILD_DEPENDS:=python3

include ../../lang/python/pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python3-package.mk

IMAGEBUILDER_DEPENDS:= \
    @x86_64 +bash +bzip2 +coreutils +coreutils-stat +diffutils +file \
    +gawk +gcc +getopt +git +git-http +libncurses +make +patch +perl \
    +perlbase-attributes +perlbase-findbin +perlbase-getopt \
    +perlbase-thread +python3-light +tar +unzip +wget +xz +xzdiff \
    +xzgrep +xzless +xz-utils +zlib-dev

define Package/asu
    SECTION:=devel
    CATEGORY:=Development
    TITLE:=attended sysupgrade image server
    MAINTAINER:=Paul Spooren <paul@spooren.de>
    URL:=http://github.com/aparcar/gsoc17-attended-sysupgrade/
    DEPENDS:=$(IMAGEBUILDER_DEPENDS) +pgsql-server +psqlodbcw \
             +python3-ctypes +python3-distutils +python3-flask \
             +gunicorn3 +python3-openssl +python3-pyodbc +python3-yaml \
             +libustream-mbedtls +ca-certificates +gnupg
    USERID:=asu:asu
endef

define Package/asu/description
   Build server to deliver OpenWrt/LEDE sysupgrade images
endef

define Py3Package/asu/install
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./files/asu.defaults $(1)/etc/uci-defaults/99-asu
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/asu.init $(1)/etc/init.d/asu
	$(INSTALL_DIR) $(1)/etc/asu
	$(INSTALL_CONF) $(PKG_BUILD_DIR)/asu/utils/config.yml.default $(1)/etc/asu/config.yml
endef

$(eval $(call Py3Package,asu))
$(eval $(call BuildPackage,asu))
