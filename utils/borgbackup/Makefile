#
# Copyright (C) 2023 Julien Malik <julien.malik@paraiso.me>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=borgbackup
PKG_VERSION:=1.4.0
PKG_RELEASE:=1

PYPI_NAME:=borgbackup
PKG_HASH:=c54c45155643fa66fed7f9ff2d134ea0a58d0ac197c18781ddc2fb236bf6ed29

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=Julien Malik <julien.malik@paraiso.me>

include ../../lang/python/pypi.mk
include $(INCLUDE_DIR)/package.mk
include ../../lang/python/python3-package.mk

# see #20462 and #12942: email and urllib shall come with python3-light
define Package/borgbackup
  SECTION:=utils
  CATEGORY:=Utilities
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

PKG_BUILD_DEPENDS:=python-cython/host python-pkgconfig/host python-setuptools-scm/host

$(eval $(call Py3Package,borgbackup))
$(eval $(call BuildPackage,borgbackup))
$(eval $(call BuildPackage,borgbackup-src))
