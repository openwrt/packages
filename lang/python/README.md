# Python packages folder

:warning: **Python 2 will soon be unsupported and removed from the feed - [see below](#python-2-end-of-life)** :warning:

## Table of contents

1. [Description](#description)
2. [Python 2 end-of-life](#python-2-end-of-life)
    1. [Transition policy / schedule](#transition-policy--schedule)
3. [Introduction](#introduction)
4. [Using Python[3] in external/other package feeds](#using-python3-in-externalother-package-feeds)
5. [Build considerations](#build-considerations)
6. [General folder structure](#general-folder-structure)
7. [Building a Python[3] package](#building-a-python3-package)
    1. [Include python[3]-package.mk](#include-python3-packagemk)
    2. [Add Package/<PKG_NAME> OpenWrt definitions](#add-packagepkg_name-openwrt-definitions)
    3. [Wrapping things up so that they build](#wrapping-things-up-so-that-they-build)
    4. [Customizing things](#customizing-things)
    5. [Host-side Python packages for build](#host-side-python-packages-for-build)

## Description

This section describes specifics for the Python packages that are present in this repo, and how things are structured.

In terms of license, contributing guide, etc, all of that information is described in the top [README.md](README.md) file, and it applies here as well. This document attempts to cover only technical aspects of Python/Python3 packages, and maybe some explanations about how things are (and why they are as they are).

## Python 2 end-of-life

Python 2 will not be maintained past [1 January 2020](https://pythonclock.org/). As such, we will be transitioning Python 2 programs and libraries to Python 3, and Python 2 packages will be removed in early 2020.

(Discussion for how to handle this transition can be found in [#8520](https://github.com/openwrt/packages/issues/8520).)

### Transition policy / schedule

A mass removal event ("The Snap") will occur on 31 March 2020, or 2 weeks before the freeze for a 20.x release, whichever is sooner. The exact date will be confirmed when the 20.x release schedule is known, or by 15 March 2020.

All Python 2 packages (the Python 2 interpreter, programs that depend on Python 2, and Python 2-only libraries) will be removed during this event.

Leading up to "The Snap":

* In general, new Python 2 packages are no longer accepted
  * Exceptions can be made on a case-by-case basis, given extraordinary circumstances or reasons, until 31 May 2019
  * From 31 May 2019 onward, absolutely no new Python 2 packages will be accepted

* The Python 2 interpreter will remain in the feed until "The Snap"
  * The interpreter will continue to be updated, including the last release in January 2020 (if there is one)

* Programs that depend on Python 2 will be transitioned to Python 3 (see [#8893](https://github.com/openwrt/packages/issues/8893))
  * If a program cannot be transitioned, a suitable replacement will be found
  * If a replacement cannot be found, the program will be removed during "The Snap"

* Python 2 libraries will remain in the feed until "The Snap"
  * For any Python 2-only libraries, a Python 3 version will be added (or a suitable replacement found), if its Python 3 version is a dependency of another package in the feed
  * Python 2 libraries will receive normal updates until 31 October 2019
  * From 31 October 2019 onward:
    * Python 2-only libraries will receive security updates only
    * Python 2 libraries that share the same Makefile as their Python 3 version will continue to receive normal updates

## Introduction

This sub-tree came to exist after a number of contributions (Python packages) were made to this repo, and the [lang](lang) subtree grew to a point where a decision was made to move all Python packages under [lang/python](lang/python).

It contains the 2 Python interpreters (Python & Python3) and Python packages. Most of the Python packages are downloaded from [pypi.org](https://pypi.org/). Python packages from [pypi.org](https://pypi.org/) are typically preferred when adding new packages.

If more packages (than the ones packaged here) are needed, they can be downloaded via [pip or pip3](https://pip.pypa.io). Note that the versions of `pip` & `setuptools` [available in this repo] are the ones that are packaged inside the Python & Python3 packages (yes, Python & Python3 come packaged with `pip` & `setuptools`).

## Using Python[3] in external/other package feeds

In the feeds.conf (or feeds.conf.default file, whatever is preferred), the packages repo should be present.

Example
```
src-git packages https://git.openwrt.org/feed/packages.git
src-git luci https://git.openwrt.org/project/luci.git
src-git routing https://git.openwrt.org/feed/routing.git
src-git telephony https://git.openwrt.org/feed/telephony.git
#
#
src-git someotherfeed https://github.com/<github-user>/<some-other-package>
```

Assuming that there are Python packages in the `<some-other-package>`, they should include `python[3]-package.mk` like this:
```
include $(TOPDIR)/feeds/packages/lang/python/python-package.mk
include $(TOPDIR)/feeds/packages/lang/python/python3-package.mk
```

Same rules apply for `python[3]-package.mk` as the Python packages in this repo.
And if only 1 of `python-package.mk` or `python3-package.mk` is needed, then only the needed mk file should be included (though it's not an issue if both are included).

**One important consideration:**: if the local name is not `packages`, it's something else, like `openwrt-packages`. And in `feeds.conf[.default]` it's:
```
src-git openwrt-packages https://git.openwrt.org/feed/packages.git
```

Then, the inclusions also change:
```
include $(TOPDIR)/feeds/openwrt-packages/lang/python/python-package.mk
include $(TOPDIR)/feeds/openwrt-packages/lang/python/python3-package.mk
```

Each maintainer[s] of external packages feeds is responsible for the local name, and relative inclusion path back to this feed (which is named `packages` by default).

In case there is a need/requirement such that the local package feed is named something else than `packages`, one approach to make the package flexible to change is:

```
PYTHON_PACKAGE_MK:=$(wildcard $(TOPDIR)/feeds/*/lang/python/python-package.mk)

# verify that there is only one single file returned
ifneq (1,$(words $(PYTHON_PACKAGE_MK)))
ifeq (0,$(words $(PYTHON_PACKAGE_MK)))
$(error did not find python-package.mk in any feed)
else
$(error found multiple python-package.mk files in the feeds)
endif
else
$(info found python-package.mk at $(PYTHON_PACKAGE_MK))
endif

include $(PYTHON_PACKAGE_MK)
```

Same can be done for `python3-package.mk`.
This should solve the corner-case where the `python[3]-package.mk` can be in some other feed, or if the packages feed will be named something else locally.

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

### Include pypi.mk (optional)

If the package source code will be downloaded from [pypi.org](https://pypi.org/), including `pypi.mk` can help simplify the package Makefile.

To use `pypi.mk`, add this **before** `include $(INCLUDE_DIR)/package.mk`:
```
include ../pypi.mk
```

`pypi.mk` has several `PYPI_*` variables that must/can be set (see below); these should be set before `pypi.mk` is included, i.e. before the `include ../pypi.mk` line.

`pypi.mk` also provides default values for `PKG_SOURCE` and `PKG_SOURCE_URL`, so these variables may be omitted.

One variable is required:

* `PYPI_NAME`: Package name on pypi.org. This should match the PyPI name exactly.

  For example (from the `python-yaml` package):
  ```
  PYPI_NAME:=PyYAML
  ```

These variables are optional:

* `PYPI_SOURCE_NAME`: Package name component of the source tarball filename  
  Default: Same value as `PYPI_NAME`

* `PYPI_SOURCE_EXT`: File extension of the source tarball filename  
  Default: `tar.gz`

`pypi.mk` constructs the default `PKG_SOURCE` value from these variables (and `PKG_VERSION`):
```
PKG_SOURCE?=$(PYPI_SOURCE_NAME)-$(PKG_VERSION).$(PYPI_SOURCE_EXT)
```

The `PYPI_SOURCE_*` variables allow this default `PKG_SOURCE` value to be customized as necessary.

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
* be sure to make sure that `DEPENDS` are correct for both variants; as seen in the example above, `python-codecs` is needed only for `python-lxml` (see **[note-encodings](#note-encodings)**)
* consider adding conditional DEPENDS for each variant ; so for each Python[3] package add `+PACKAGE_python-lxml:<dep>` as seen in the above example ; the reason for this is build-time reduction ; if you want to build Python3 only packages, this won't build Python & Python packages + dependencies ; this is a known functionality of OpenWrt build deps
  * this should not happen anymore, but if adding `+PACKAGE_python-lxml` conditional deps creates circular dependencies, then open an issue so this can be resolved again.
* `VARIANT=python` or `VARIANT=python3` must be added
* typically each variant package is named `Package/python-<something>` & `Package/python3-<something>` ; this convention makes things easier to follow, though it could work without naming things this way
* `TITLE` can be something a bit more verbose/neat ; typically the name is short as seen above

<a name="note-encodings">**note-encodings**</a>: That's because some character encodings are needed, which are present in `python3-base` but not in `python-light` (but are present in `python-codecs`) ; this is because Python3 is designed to be more Unicode friendly than Python2 (it's one of the fundamental differences between the 2), and Python3 won't start without those encodings being present.


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
$(eval $(call BuildPackage,python-lxml))
$(eval $(call BuildPackage,python-lxml-src))

$(eval $(call Py3Package,python3-lxml))
$(eval $(call BuildPackage,python3-lxml))
$(eval $(call BuildPackage,python3-lxml-src))
```

The name `*-src` must be the Python package name; so for `python-lxml-src` a equivalent `python-lxml` name must exist.

### Customizing things

Some packages need custom build rules (because they do).

The default package build and install processes are defined in `python[3]-package.mk`.

#### Building

The default build process calls `setup.py install` inside the directory where the Python source package is extracted (`PKG_BUILD_DIR`). This "installs" the Python package to an intermediate location (`PKG_INSTALL_DIR`) where it is used by the default install process.

There are several Makefile variables that can be used to customize this process (all optional):

* `PYTHON_PKG_SETUP_DIR` / `PYTHON3_PKG_SETUP_DIR`: Path where `setup.py` can be found, relative to the package directory (`PKG_BUILD_DIR`).  
  Default: empty value (`setup.py` is in the package directory)
* `PYTHON_PKG_SETUP_VARS` / `PYTHON3_PKG_SETUP_VARS`: Additional environment variables to set for the call to `setup.py`. Should be in the form of `VARIABLE1=value VARIABLE2=value ...`.  
  Default: empty value
* `PYTHON_PKG_SETUP_GLOBAL_ARGS` / `PYTHON3_PKG_SETUP_GLOBAL_ARGS`: Additional command line arguments to pass to `setup.py`, before / in front of the `install` command.  
  Default: empty value
* `PYTHON_PKG_SETUP_ARGS` / `PYTHON3_PKG_SETUP_ARGS`: Additional command line arguments to pass to `setup.py`, after the `install` command.  
  Default: `--single-version-externally-managed`

Conceptually, these variables are used in this way (using a Python 2 package as an example):

```
cd $(PKG_BUILD_DIR)/$(PYTHON_PKG_SETUP_DIR)
$(PYTHON_PKG_SETUP_VARS) python setup.py $(PYTHON_PKG_SETUP_GLOBAL_ARGS) install $(PYTHON_PKG_SETUP_ARGS)
```

The default build process can be completely overridden by defining custom `PyBuild/Compile` & `Py3Build/Compile` rules in the package Makefile.

#### Installing

The default install process copies some/all of the files from `PKG_INSTALL_DIR`, placed there by the build process, to a location passed to the install rule as the first argument (`$(1)`). The OpenWrt build system will then take those files and create the actual .ipk package archives.

This default process uses 2 build rules:
* `PyPackage/<package>/filespec` & `Py3Package/<package>/filespec` which are Python library files relative to `/usr/lib/pythonX.Y` ; by default this is `/usr/lib/python$(PYTHON[3]_VERSION)/site-packages` (`PYTHON[3]_PKG_DIR`) ; most Python[3] packages generate files that get installed in this sub-folder
* `PyPackage/<package>/install` & `Py3Package/<package>/install` is similar to `Package/<package>/install` ; these allow binary (or other files) to be installed on the target

Both the 2 above rules generate a `Package/<package>/install` build rule, which gets picked up by the build system. Both can be used together (they are not mutually exclusive), and provide a good enough flexibility for specifying Python[3] packages.

The `PyPackage/<package>/filespec` & `Py3Package/<package>/filespec` rules contain one or more lines of the following format (whitespace added for clarity):

```
<one of: +-=> | <file/directory path> | <file permissions>
```

The initial character controls the action that will be taken:

* `+`: Install the given path. If the path is a directory, all files and subdirectories inside are installed.
  * If file permissions is specified (optional), then the file or directory (and all files and subdirectories) are assigned the given permissions; if omitted, then the file or directory retains its original permissions.
* `-`: Remove the given path. Useful when most of a directory should be installed except for a few files or subdirectories.
  * File permissions is not used / ignored in this case.
* `=`: Assign the given file permissions to the given path. File permissions is required in this case.

As mentioned, the default `PyPackage/<package>/filespec` & `Py3Package/<package>/filespec` install `PYTHON[3]_PKG_DIR`:

```
define PyPackage/python-example/filespec
+|$(PYTHON_PKG_DIR)
endef
```

If the package installs a `example_package` directory inside `PYTHON_PKG_DIR`, and there is an `examples` directory and `test_*.py` files that can be omitted to save space, this can be specified as:

```
define PyPackage/python-example/filespec
+|$(PYTHON_PKG_DIR)
-|$(PYTHON_PKG_DIR)/example_package/examples
-|$(PYTHON_PKG_DIR)/example_package/test_*.py
endef
```

### Host-side Python packages for build

These can be installed via pip and ideally they should only be installed like this, because it's a bit simpler than running them through the OpenWrt build system. Build variants on the host-side build are more complicated (and nearly impossible to do sanely) in the current OpenWrt build system.

Which is why [for example] if you need python cffi on the host build, it's easier to just add it via:
```
HOST_PYTHON_PACKAGE_BUILD_DEPENDS:="cffi==$(PKG_VERSION)"
HOST_PYTHON3_PACKAGE_BUILD_DEPENDS:="cffi==$(PKG_VERSION)"
```
[cffi is one of those packages that needs a host-side package installed for both Python & Python3].

This works reasonably well in the current OpenWrt build system, as binaries get built for this package and get installed in the staging-dir `$(STAGING_DIR)/usr/lib/pythonX.Y/site-packages`.
