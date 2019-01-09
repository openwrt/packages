# Python packages folder

## Table of contents

1. [Description](#description)
2. [Introduction](#introduction)
3. [Build considerations](#build-considerations)
4. [General folder structure](#general-folder-structure)
5. [Building a Python[3] package](#building-a-python3-package)
    1. [PKG_BUILD_DIR](#pkg_build_dir)
    2. [PKG_UNPACK](#pkg_unpack)
    3. [Include python[3]-package.mk](#include-python3-packagemk)
    4. [Add Package/<PKG_NAME> OpenWrt definitions](#add-packagepkg_name-openwrt-definitions)
    5. [Wrapping things up so that they build](#wrapping-things-up-so-that-they-build)
    6. [Customizing things](#customizing-things)
    7. [Host-side Python packages for build](#host-side-python-packages-for-build)

## Description

This section describes specifics for the Python packages that are present in this repo, and how things are structured.

In terms of license, contributing guide, etc, all of that information is described in the top [README.md](README.md) file, and it applies here as well. This document attempts to cover only technical aspects of Python/Python3 packages, and maybe some explanations about how things are (and why they are as they are).

## Introduction

This sub-tree came to exist after a number of contributions (Python packages) were made to this repo, and the [lang](lang) subtree grew to a point where a decision was made to move all Python packages under [lang/python](lang/python).

It contains the 2 Python interpreters (Python & Python3) and Python packages. Most of the Python packages are downloaded from [pypi.org](https://pypi.org/). Python packages from [pypi.org](https://pypi.org/) are typically preferred when adding new packages.

If more packages (than the ones packaged here) are needed, they can be downloaded via [pip or pip3](https://pip.pypa.io). Note that the versions of `pip` & `setuptools` [available in this repo] are the ones that are packaged inside the Python & Python3 packages (yes, Python & Python3 come packaged with `pip` & `setuptools`).

## Build considerations

In order to build the Python[3] interpreters, a host Python/Python3 interpreter needs to be built, in order to process some of the build for the target Python/Python3 build. The host Python[3] interpreters are also needed so that Python bytecodes are generated, so the host interpreters need to be the exact versions as on the target. And finally, the host Python[3] interpreters also provide pip & pip3, so that they may be used to install some Python[3] packages that are required to build other Python[3] packages.
That's why you'll also see a Python/Python3 build & staging directories.

As you're probably thinking, this sounds [and is] somewhat too much complication [just for packaging], but the status of things is-as-it-is, and it's probably much worse than what's currently visible on the surface [with respect to packaging Python[3] & packages].

As mentioned earlier, Python[3] packages are shipped with bytecodes, and the reason for this is simply performance & size.
The thought/discussion matrix derives a bit like this:
* shipping both Python source-code & bytecodes takes too much space on some devices ; Python source code & byte-code take about similar disk-size
* shipping only Python source code has a big performance penalty [on some lower end systems] ; something like 500 msecs (Python source-only) -> 70 msecs (Python byte-codes) time reduction for a simple "Hello World" script
* shipping only Python byte-codes seems like a good trade-off, and this means that `python-src` & `python3-src` can be provided for people that want the source code

By default, automatic Python[3] byte-code generation is disabled when running a Python script, in order to prevent a disk from accidentally filling up. Since some disks reside in RAM, this also means not filling up the RAM. If someone wants to convert Python source to byte-code then he/she is free to compile it [directly on the device] manually via the Python interpreter & library.

## General folder structure

The basis of all these packages are:
* [lang/python/python](lang/python/python) - The Python 2.7.y interpreter (supposedly, there won't ever by a 2.8.y)
* [lang/python/python3](lang/python/python3) - The Python 3.x.y interpreter

These 2 are normal OpenWrt packages, which will build the Python interpreters. They also provide `python[3]-pip` & `python[3]-setuptools`. Each Python or Python3 package is actually split into multiple sub-packages [e.g. python-email, python-sqlite3, etc]. This can be viewed inside [lang/python/python/files](lang/python/python/files) & [lang/python/python3/files](lang/python/python3/files).

The reason for this splitting, is purely to offer a way for some people to package Python/Python3 in as-minimal-as-possible-and-still-runable way, and also to be somewhat maintainable when packaging. A standard Python[3] installation can take ~20-30 MBs of disk, which can be somewhat big for some people, so there are the `python[3]-base` packages which bring that down to ~5 MBs. This seems to be good enough (and interesting) for a number of people.

The Python[3] interpreters are structured like this:
* `python-base` (and `python3-base`), which is just the minimal package to startup Python[3] and run basic commands
* `python` (and `python3`) are meta-packages, which install almost everything (python[3]-base [plus] Python[3] library [minus] some unit-tests & some windows-y things)
* `python-light` (and `python3-light`) are `python` (and `python3`) [minus] packages that are in [lang/python/python/files](lang/python/python/files) or [lang/python/python3/files](lang/python/python3/files) ; the size of these 2 packages may be sensible (and interesting) to another group of people

All other Python & Python3 packages (aside from the 2 intepreters) typically use these files:
* **python[3]-host.mk** - this file contains paths and build rules for running the Python[3] interpreters on the host-side; they also provide paths to host interprete, host Python lib-dir & so on
* **python[3]-package.mk**
  * includes **python[3]-host.mk**
  * contains all the default build rules for Python[3] packages; these will be detailed below in the [Building a Python[3] package](#Building a Python[3] package) section

**Note** that Python/Python3 packages don't need to use these files (i.e. `python[3]-package.mk` & `python[3]-host.mk`), but they do provide some ease-of-use & reduction of duplicate code, especially when packaging for both Python & Python3. And they do contain some learned-lessons about packaging Python/Python3 packages, so it's a good idea to use them.

## Building a Python[3] package

A Python package can be packaged for either Python or Python3 or both.

This section will describe both, and then it can be inferred which is for which.

Packaging for both Python & Python3 uses the `VARIANT` mechanism for packaging inside OpenWrt. (#### FIXME: find a link for this later if it exists)

### PKG_BUILD_DIR

It's important when packaging for both Python & Python3 to override this variable, so that the build directory differs for each variant.

Typically it's just something like:
```
PKG_BUILD_DIR:=$(BUILD_DIR)/$(BUILD_VARIANT)-pyasn1-$(PKG_VERSION)
```
Where `pyasn1` should be some other name, or maybe `PKG_NAME`

This should be added before this include:
```
include $(INCLUDE_DIR)/package.mk
```

### PKG_UNPACK

In many cases, this needs to be overriden. This is usually because the way Python packages are archived, don't follow the convention of other `tar.gz` packages.

So, something like:
```
PKG_UNPACK=$(HOST_TAR) -C $(PKG_BUILD_DIR) --strip-components=1 -xzf $(DL_DIR)/$(PKG_SOURCE)
```
should be added.

It's not important whether this is after or before `include $(INCLUDE_DIR)/package.mk`

### Include python[3]-package.mk

If packaging for Python, add this after  `include $(INCLUDE_DIR)/package.mk`
```
include ../python-package.mk
```

If packaging for Python3, add this after  `include $(INCLUDE_DIR)/package.mk`
```
include ../python3-package.mk
```

Order doesn't matter between `python-package.mk` & `python3-package.mk`.

These will make sure that build rules for Python or Python3 can be specified and picked up for build.

### Add Package/<PKG_NAME> OpenWrt definitions

This part is similar to default OpenWrt packages.
It's usually recommended to have a `Package/<PKG_NAME>/Default` section that's common for both Python & Python3.

Example:
```
define Package/python-lxml/Default
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  URL:=https://lxml.de
  DEPENDS:=+libxml2 +libxslt +libexslt
endef
```

Then for each variant do something like:
```
define Package/python-lxml
$(call Package/python-lxml/Default)
  TITLE:=python-lxml
  DEPENDS+=+PACKAGE_python-lxml:python-light +PACKAGE_python-lxml:python-codecs
  VARIANT:=python
endef

define Package/python3-lxml
$(call Package/python-lxml/Default)
  TITLE:=python3-lxml
  DEPENDS+=+PACKAGE_python3-lxml:python3-light
  VARIANT:=python3
endef
```

Some considerations here (based on the example above):
* be sure to make sure that `DEPENDS` are correct for both variants; as seen in the example above, `python-codecs` is needed only for `python-lxml` ; that's because `python3-codecs` doesn't exist and is included in `python3-base` ; most of the times they are similar, sometimes they are not
* consider adding conditional DEPENDS for each variant ; so for each Python[3] package add `+PACKAGE_python-lxml:<dep>` as seen in the above example ; the reason for this is build-time reduction ; if you want to build Python3 only packages, this won't build Python & Python packages + dependencies ; this is a known functionality of OpenWrt build deps
  * there is an exception to the above consideration: if adding `+PACKAGE_python-lxml` conditional deps creates circular dependencies [for some weird reason], then this can be omitted
* `VARIANT=python` or `VARIANT=python3` must be added
* typically each variant package is named `Package/python3-<something>` & `Package/python3-<something>` ; this convention makes things easier to follow, though it could work without naming things this this
* `TITLE` can be something a bit more verbose/neat ; typically the name is short as seen above

Following these, 2 more definitions are required:
```
define Package/python-lxml/description
The lxml XML toolkit is a Pythonic binding
for the C libraries libxml2 and libxslt.
endef

define Package/python3-lxml/description
$(call Package/python-lxml/description)
.
(Variant for Python3)
endef
```

Typically, the description is the same for both, so just mentioning that one is a variant of the other is sufficient.

### Wrapping things up so that they build

If all the above prerequisites have been met, all that's left is:

```
$(eval $(call PyPackage,python-lxml))
$(eval $(call BuildPackage,python-lxml))

$(eval $(call Py3Package,python3-lxml))
$(eval $(call BuildPackage,python3-lxml))
```

The `$(eval $(call PyPackage,python-lxml))` part will instantiate all the default Python build rules so that the final Python package is packaged into an OpenWrt.
And `$(eval $(call BuildPackage,python-lxml))` will bind all the rules generated with `$(eval $(call PyPackage,python-lxml))` into the OpenWrt build system.

These packages will contain byte-codes and binaries (shared libs & other stuff).

If a user wishes to ship source code, adding 2 more lines creates 2 more packages that ship Python source code:
```
$(eval $(call PyPackage,python-lxml))
$(eval $(call PyPackage,python-lxml-src))
$(eval $(call BuildPackage,python-lxml))

$(eval $(call Py3Package,python3-lxml))
$(eval $(call Py3Package,python3-lxml-src))
$(eval $(call BuildPackage,python3-lxml))
```

The name `*-src` must be the Python package name; so for `python-lxml-src` a equivalent `python-lxml` name must exist.

### Customizing things

Some packages need custom build rules (because they do).

For building, if a user specifies a `PyBuild/Compile` & `Py3Build/Compile` rule, this will be used to build/compile the package, instead of the default one defined in `python[3]-package.mk`.

For installing files on the target, 2 build rules are used:
* `PyPackage/$(1)/filespec` & `Py3Package/$(1)/filespec` which are Python library files relative to `/usr/lib/pythonX.Y` ; by default this is `/usr/lib/python$(PYTHON[3]_VERSION)/site-packages` ; most Python[3] packages generate files that get installed in this sub-folder
* `PyPackage/$(1)/install` & `Py3Package/$(1)/install` is similar to `Package/$(1)/install` ; these allow binary (or other files) to be installed on the target

Both the 2 above rules generate a `Package/$(1)/install` build rule, which gets picked up by the build system. Both can be used together (they are not mutually exclusive), and provide a good enough flexibility for specifying Python[3] packages.

### Host-side Python packages for build

These can be installed via pip and ideally they should only be installed like this, because it's a bit simpler than running them through the OpenWrt build system. Build variants on the host-side build are more complicated (and nearly impossible to do sanely) in the current OpenWrt build system.

Which is why [for example] if you need python cffi on the host build, it's easier to just add it via:
```
HOST_PYTHON_PACKAGE_BUILD_DEPENDS:="cffi==$(PKG_VERSION)"
HOST_PYTHON3_PACKAGE_BUILD_DEPENDS:="cffi==$(PKG_VERSION)"
```
[cffi is one of those packages that needs a host-side package installed for both Python & Python3].

This works reasonably well in the current OpenWrt build system, as binaries get built for this package and get installed in the staging-dir `$(STAGING_DIR)/usr/lib/pythonX.Y/site-packages`.
