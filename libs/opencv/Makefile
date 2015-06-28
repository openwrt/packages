#
# Copyright (C) 2013-2014 wrtnode.com
# Copyright (C) 2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=opencv
PKG_VERSION:=2.4.11
PKG_RELEASE:=3

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).zip
PKG_SOURCE_URL:=http://sourceforge.net/projects/opencvlibrary/files/opencv-unix/$(PKG_VERSION)/
PKG_MD5SUM:=32f498451bff1817a60e1aabc2939575

PKG_LICENSE:=BSD-3-Clause
PKG_LICENSE_FILES:=LICENSE

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk


define Package/opencv/Default/description
 OpenCV (Open Source Computer Vision Library) is an open source computer
 vision and machine learning software library. OpenCV was built to provide
 a common infrastructure for computer vision applications and to accelerate
 the use of machine perception in the commercial products. Being a
 BSD-licensed product, OpenCV makes it easy for businesses to utilize
 and modify the code.
endef

define Package/opencv
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=opencv-2.4.11
  URL:=http://opencv.org/
  MAINTAINER:=WRTnode Team <pub@wrtnode.com>
  DEPENDS:=+libpthread +librt +libstdcpp +zlib +libjpeg
endef


PKG_INSTALL:=1

CMAKE_OPTIONS += -DBUILD_opencv_gpu:BOOL=OFF \
	-DWITH_1394:BOOL=OFF -DBUILD_opencv_stitching:BOOL=OFF \
	-DBUILD_opencv_superres:BOOL=OFF -DBUILD_opencv_ts:BOOL=OFF \
	-DBUILD_opencv_highgui:BOOL=OFF \
	-DBUILD_opencv_videostab:BOOL=OFF \
	-DWITH_FFMPEG:BOOL=OFF \
	-DWITH_GSTREAMER:BOOL=OFF \
	-DWITH_LIBV4L:BOOL=OFF \
	-DWITH_PNG:BOOL=OFF \
	-DWITH_TIFF:BOOL=OFF \

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/opencv $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/opencv2 $(1)/usr/include/
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libopencv* $(1)/usr/lib/
endef

define Package/opencv/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libopencv* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,opencv))
