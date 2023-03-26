#
# Copyright (C) 2023 Julien Malik <julien.malik@paraiso.me>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=borgbackup
PKG_VERSION:=1.2.4
PKG_RELEASE:=1

PYPI_NAME:=borgbackup
PKG_HASH:=a4bd54e9469e81b7a30a6711423115abc818d9cd844ecb1ca0e6104bc5374da8

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Julien Malik <julien.malik@paraiso.me>

include ../pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../python3-package.mk

# see #20462 and #12942: email and urllib shall come with python3-light
define Package/borgbackup
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Deduplicated, encrypted, authenticated and compressed backups
  URL:=https://github.com/borgbackup/borg
  DEPENDS:= \
      +python3-light \
      +python3-codecs \
      +python3-email \
      +python3-logging \
      +python3-lzma \
      +python3-msgpack \
      +python3-packaging \
      +python3-pyfuse3 \
      +python3-readline \
      +python3-unittest \
      +python3-urllib \
      +python3-uuid \
      +libacl \
      +libopenssl \
      +liblz4 \
      +libzstd \
      +libxxhash
endef

define Package/borgbackup/description
  BorgBackup (short: Borg) is a deduplicating backup program.
  Optionally, it supports compression and authenticated encryption.

  The main goal of Borg is to provide an efficient and secure way to backup data.
  The data deduplication technique used makes Borg suitable for daily backups since only changes are stored. The authenticated encryption technique makes it suitable for backups to not fully trusted targets.
endef

HOST_PYTHON3_PACKAGE_BUILD_DEPENDS:=Cython

# borg setup.py shall find these via pkg-config, but depends on python pkgconfig PyPi module
# which quickly becomes a nightmare to build, since it build-depends on poetry which is not
# available in the python package feed, and has a myriad of deps
PYTHON3_PKG_SETUP_VARS:= \
  BORG_OPENSSL_PREFIX="/usr/lib" \
  BORG_LIBLZ4_PREFIX="/usr/lib" \
  BORG_LIBZSTD_PREFIX="/usr/lib" \
  BORG_LIBXXHASH_PREFIX="/usr/lib"

$(eval $(call Py3Package,borgbackup))
$(eval $(call BuildPackage,borgbackup))
$(eval $(call BuildPackage,borgbackup-src))
