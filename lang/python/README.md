# Python packages folder

## Table of contents

1. [Description](#description)
2. [Introduction](#introduction)
3. [Python 2 end-of-life](#python-2-end-of-life)
4. [Using Python in external/other package feeds](#using-python-in-externalother-package-feeds)
5. [Build considerations](#build-considerations)
6. [General folder structure](#general-folder-structure)
7. [Building a Python package](#building-a-python-package)
    1. [Include python3-package.mk](#include-python3-packagemk)
    2. [Add Package/<PKG_NAME> OpenWrt definitions](#add-packagepkg_name-openwrt-definitions)
    3. [Python package dependencies](#python-package-dependencies)
    4. [Wrapping things up so that they build](#wrapping-things-up-so-that-they-build)
    5. [Customizing things](#customizing-things)
    6. [Host-side Python packages for build](#host-side-python-packages-for-build)

## Description

This section describes specifics for the Python packages that are present in this repo, and how things are structured.

In terms of license, contributing guide, etc, all of that information is described in the top [README.md](../../README.md) file, and it applies here as well. This document attempts to cover only technical aspects of Python packages, and maybe some explanations about how things are (and why they are as they are).

## Introduction

This sub-tree came to exist after a number of contributions (Python packages) were made to this repo, and the [lang](../) subtree grew to a point where a decision was made to move all Python packages under [lang/python](./).

It contains the Python 3 interpreter and Python packages. Most of the Python packages are downloaded from [pypi.org](https://pypi.org/). Python packages from pypi.org are typically preferred when adding new packages.

If more packages (than the ones packaged here) are needed, they can be downloaded via [pip](https://pip.pypa.io). Note that the versions of `pip` & `setuptools` [available in this repo] are the ones that are packaged inside the Python package (yes, Python comes packaged with `pip` & `setuptools`).

## Python 2 end-of-life

Python 2 [will not be maintained past 2020](https://www.python.org/dev/peps/pep-0373/). All Python 2 packages have been removed from the packages feed (this repo) and archived in the [abandoned packages feed](https://github.com/openwrt/packages-abandoned).

## Using Python in external/other package feeds

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

Assuming that there are Python packages in the `<some-other-package>`, they should include `python3-package.mk` like this:
```
include $(TOPDIR)/feeds/packages/lang/python/python3-package.mk
```

Same rules apply for `python3-package.mk` as the Python packages in this repo.

**One important consideration:**: if the local name is not `packages`, it's something else, like `openwrt-packages`. And in `feeds.conf[.default]` it's:
```
src-git openwrt-packages https://git.openwrt.org/feed/packages.git
```

Then, the inclusions also change:
```
include $(TOPDIR)/feeds/openwrt-packages/lang/python/python3-package.mk
```

Each maintainer[s] of external packages feeds is responsible for the local name, and relative inclusion path back to this feed (which is named `packages` by default).

In case there is a need/requirement such that the local package feed is named something else than `packages`, one approach to make the package flexible to change is:

```
PYTHON3_PACKAGE_MK:=$(wildcard $(TOPDIR)/feeds/*/lang/python/python3-package.mk)

# verify that there is only one single file returned
ifneq (1,$(words $(PYTHON3_PACKAGE_MK)))
ifeq (0,$(words $(PYTHON3_PACKAGE_MK)))
$(error did not find python3-package.mk in any feed)
else
$(error found multiple python3-package.mk files in the feeds)
endif
else
$(info found python3-package.mk at $(PYTHON3_PACKAGE_MK))
endif

include $(PYTHON3_PACKAGE_MK)
```

This should solve the corner-case where the `python3-package.mk` can be in some other feed, or if the packages feed will be named something else locally.

## Build considerations

In order to build the Python interpreter, a host Python interpreter needs to be built, in order to process some of the build for the target Python build. The host Python interpreter is also needed so that Python bytecodes are generated, so the host interpreter needs to be the exact version as on the target. And finally, the host Python interpreter also provides pip, so that it may be used to install some Python packages that are required to build other Python packages.
That's why you'll also see a Python build & staging directories.

As you're probably thinking, this sounds [and is] somewhat too much complication [just for packaging], but the status of things is-as-it-is, and it's probably much worse than what's currently visible on the surface [with respect to packaging Python & packages].

As mentioned earlier, Python packages are shipped with bytecodes, and the reason for this is simply performance & size.
The thought/discussion matrix derives a bit like this:
* shipping both Python source-code & bytecodes takes too much space on some devices ; Python source code & byte-code take about similar disk-size
* shipping only Python source code has a big performance penalty [on some lower end systems] ; something like 500 msecs (Python source-only) -> 70 msecs (Python byte-codes) time reduction for a simple "Hello World" script
* shipping only Python byte-codes seems like a good trade-off, and this means that `python3-src` can be provided for people that want the source code

By default, automatic Python byte-code generation is disabled when running a Python script, in order to prevent a disk from accidentally filling up. Since some disks reside in RAM, this also means not filling up the RAM. If someone wants to convert Python source to byte-code then he/she is free to compile it [directly on the device] manually via the Python interpreter & library.

## General folder structure

The basis of all these packages is:
* [lang/python/python3](./python3) - The Python 3.x.y interpreter

This is a normal OpenWrt package, which will build the Python interpreter. This also provides `python3-pip` & `python3-setuptools`. Each Python package is actually split into multiple sub-packages [e.g. python3-email, python3-sqlite3, etc]. This can be viewed inside [lang/python/python3/files](./python3/files).

The reason for this splitting, is purely to offer a way for some people to package Python in as-minimal-as-possible-and-still-runable way, and also to be somewhat maintainable when packaging. A standard Python installation can take ~20-30 MBs of disk, which can be somewhat big for some people, so there is the `python3-base` package which brings that down to ~5 MBs. This seems to be good enough (and interesting) for a number of people.

The Python interpreter is structured like this:
* `python3-base`, which is just the minimal package to startup Python and run basic commands
* `python3` is a meta-package, which installs almost everything (python3-base [plus] Python library [minus] some unit-tests & some windows-y things)
* `python3-light` is `python3` [minus] packages that are in [lang/python/python3/files](./python3/files) ; the size of this package may be sensible (and interesting) to another group of people

All other Python packages (aside from the intepreter) typically use these files:
* **python3-host.mk** - this file contains paths and build rules for running the Python interpreter on the host-side; they also provide paths to host interprete, host Python lib-dir & so on
* **python3-package.mk**
  * includes **python3-host.mk**
  * contains all the default build rules for Python packages; these will be detailed below in the [Building a Python package](#building-a-python-package) section

**Note** that Python packages don't need to use these files (i.e. `python3-package.mk` & `python3-host.mk`), but they do provide some ease-of-use & reduction of duplicate code. And they do contain some learned-lessons about packaging Python packages, so it's a good idea to use them.

## Building a Python package

### Include python3-package.mk

Add this after  `include $(INCLUDE_DIR)/package.mk`
```
include ../python3-package.mk
```

This will make sure that build rules for Python can be specified and picked up for build.

### Include pypi.mk (optional)

`pypi.mk` is an include file that makes downloading package source code from [pypi.org](https://pypi.org/) simpler.

To use `pypi.mk`, add this **before** `include $(INCLUDE_DIR)/package.mk`:
```
include ../pypi.mk
```

`pypi.mk` has several `PYPI_*` variables that can/must be set (see below); these should be set before `pypi.mk` is included, i.e. before the `include ../pypi.mk` line.

`pypi.mk` also provides default values for `PKG_SOURCE` and `PKG_SOURCE_URL`, so these variables may be omitted.

Required variables:

* `PYPI_NAME`: Package name on pypi.org. This should match the PyPI name exactly.

  For example (from the `python-yaml` package):
  ```
  PYPI_NAME:=PyYAML
  ```

Optional variables:

* `PYPI_SOURCE_NAME`: Package name component of the source tarball filename  
  Default: Same value as `PYPI_NAME`

* `PYPI_SOURCE_EXT`: File extension of the source tarball filename  
  Default: `tar.gz`

`pypi.mk` constructs the default `PKG_SOURCE` value from these variables (and `PKG_VERSION`):
```
PKG_SOURCE?=$(PYPI_SOURCE_NAME)-$(PKG_VERSION).$(PYPI_SOURCE_EXT)
```

### Add Package/<PKG_NAME> OpenWrt definitions

This part is similar to default OpenWrt packages.

Example:
```
define Package/python3-lxml
  SECTION:=lang
  CATEGORY:=Languages
  SUBMENU:=Python
  TITLE:=Pythonic XML processing library
  URL:=https://lxml.de
  DEPENDS:=+python3-light +libxml2 +libxslt +libexslt
endef

define Package/python3-lxml/description
  The lxml XML toolkit is a Pythonic binding
  for the C libraries libxml2 and libxslt.
endef
```

Some considerations here (based on the example above):
* typically the package is named `Package/python3-<something>` ; this convention makes things easier to follow, though it could work without naming things this way
* `TITLE` can be something a bit more verbose/neat ; typically the name is short as seen above

### Python package dependencies

Aside from other libraries and programs, every Python package will depend on at least one of these three types of packages:

* The Python interpreter: All Python packages should depend on one of these three interpreter packages:

  * `python3-light` is the best default for most Python packages.

  * `python3-base` should only be used as a dependency if you are certain the bare interpreter is sufficient.

  * `python3` is useful if many (more than three) Python standard library packages are needed.

* Python standard library packages: As noted above, many parts of the Python standard library are packaged separate from the Python interpreter. These packages are defined by the files in [lang/python/python3/files](./python3/files).

  To find out which of these separate standard library packages are necessary, after completing a draft Makefile (including the `$(eval ...)` lines described in the next section), run `make` with the `configure` target and `PY3=stdlib V=s` in the command line. For example:

  ```
  make package/python-lxml/configure PY3=stdlib V=s
  ```

  If the package has been built previously, include the `clean` target to trigger configure again:

  ```
  make package/python-lxml/{clean,configure} PY3=stdlib V=s
  ```

  This will search the package for module imports and generate a list of suggested dependencies. Some of the found imports may be false positives, e.g. in example or test files, so examine the matches for more information.

* Other Python packages: The easiest way to find these dependencies is to look for the `install_requires` keyword inside the package's `setup.py` file (it will be a keyword argument to the `setup()` function). This will be a list of run-time dependencies for the package.

  There may already be packages in the packages feed that provide these dependencies. If not, they will need to be packaged for your Python package to function correctly.

  Any packages in a `setup_requires` keyword argument are build-time dependencies that may need to be installed on the host (host Python inside of OpenWrt buildroot, not system Python that is part of the outer computer system). To ensure these build-time dependencies are present, see [Host-side Python packages for build](#host-side-python-packages-for-build). (Note that Setuptools is already installed as part of host Python.)

### Wrapping things up so that they build

If all the above prerequisites have been met, all that's left is:

```
$(eval $(call Py3Package,python3-lxml))
$(eval $(call BuildPackage,python3-lxml))
```

The `$(eval $(call Py3Package,python3-lxml))` part will instantiate all the default Python build rules so that the final Python package is packaged into an OpenWrt.
And `$(eval $(call BuildPackage,python3-lxml))` will bind all the rules generated with `$(eval $(call Py3Package,python3-lxml))` into the OpenWrt build system.

These packages will contain byte-codes and binaries (shared libs & other stuff).

If a user wishes to ship source code, adding one more line creates one more package that ship Python source code:
```
$(eval $(call Py3Package,python3-lxml))
$(eval $(call BuildPackage,python3-lxml))
$(eval $(call BuildPackage,python3-lxml-src))
```

The name `*-src` must be the Python package name; so for `python3-lxml-src` a equivalent `python3-lxml` name must exist.

### Customizing things

Some packages need custom build rules (because they do).

The default package build and install processes are defined in `python3-package.mk`.

#### Building

The default build process calls `setup.py install` inside the directory where the Python source package is extracted (`PKG_BUILD_DIR`). This "installs" the Python package to an intermediate location (`PKG_INSTALL_DIR`) where it is used by the default install process.

There are several Makefile variables that can be used to customize this process (all optional):

* `PYTHON3_PKG_SETUP_DIR`: Path where `setup.py` can be found, relative to the package directory (`PKG_BUILD_DIR`).  
  Default: empty value (`setup.py` is in the package directory)
* `PYTHON3_PKG_SETUP_VARS`: Additional environment variables to set for the call to `setup.py`. Should be in the form of `VARIABLE1=value VARIABLE2=value ...`.  
  Default: empty value
* `PYTHON3_PKG_SETUP_GLOBAL_ARGS`: Additional command line arguments to pass to `setup.py`, before / in front of the `install` command.  
  Default: empty value
* `PYTHON3_PKG_SETUP_ARGS`: Additional command line arguments to pass to `setup.py`, after the `install` command.  
  Default: `--single-version-externally-managed`

Conceptually, these variables are used in this way:

```
cd $(PKG_BUILD_DIR)/$(PYTHON3_PKG_SETUP_DIR)
$(PYTHON3_PKG_SETUP_VARS) python3 setup.py $(PYTHON3_PKG_SETUP_GLOBAL_ARGS) install $(PYTHON3_PKG_SETUP_ARGS)
```

The default build process can be completely overridden by defining a custom `Py3Build/Compile` rule in the package Makefile.

#### Installing

The default install process copies some/all of the files from `PKG_INSTALL_DIR`, placed there by the build process, to a location passed to the install rule as the first argument (`$(1)`). The OpenWrt build system will then take those files and create the actual .ipk package archives.

This default process uses 2 build rules:
* `Py3Package/<package>/filespec` which are Python library files relative to `/usr/lib/pythonX.Y` ; by default this is `/usr/lib/python$(PYTHON3_VERSION)/site-packages` (`PYTHON3_PKG_DIR`) ; most Python packages generate files that get installed in this sub-folder
* `Py3Package/<package>/install` is similar to `Package/<package>/install` ; this allows binary (or other files) to be installed on the target

Both the 2 above rules generate a `Package/<package>/install` build rule, which gets picked up by the build system. Both can be used together (they are not mutually exclusive), and provide a good enough flexibility for specifying Python packages.

The `Py3Package/<package>/filespec` rule contains one or more lines of the following format (whitespace added for clarity):

```
<one of: +-=> | <file/directory path> | <file permissions>
```

The initial character controls the action that will be taken:

* `+`: Install the given path. If the path is a directory, all files and subdirectories inside are installed.
  * If file permissions is specified (optional), then the file or directory (and all files and subdirectories) are assigned the given permissions; if omitted, then the file or directory retains its original permissions.
* `-`: Remove the given path. Useful when most of a directory should be installed except for a few files or subdirectories.
  * File permissions is not used / ignored in this case.
* `=`: Assign the given file permissions to the given path. File permissions is required in this case.

As mentioned, the default `Py3Package/<package>/filespec` installs `PYTHON3_PKG_DIR`:

```
define Py3Package/python3-example/filespec
+|$(PYTHON3_PKG_DIR)
endef
```

If the package installs a `example_package` directory inside `PYTHON3_PKG_DIR`, and there is an `examples` directory and `test_*.py` files that can be omitted to save space, this can be specified as:

```
define Py3Package/python3-example/filespec
+|$(PYTHON3_PKG_DIR)
-|$(PYTHON3_PKG_DIR)/example_package/examples
-|$(PYTHON3_PKG_DIR)/example_package/test_*.py
endef
```

### Host-side Python packages for build

These can be installed via pip and ideally they should only be installed like this, because it's a bit simpler than running them through the OpenWrt build system.

#### Requirements files

All host-side Python packages are installed with pip using [requirements files](https://pip.pypa.io/en/stable/user_guide/#requirements-files), with [hash-checking mode](https://pip.pypa.io/en/stable/reference/pip_install/#hash-checking-mode) enabled. These requirements files are stored in the [host-pip-requirements](./host-pip-requirements) directory.

Each requirements file is named after the Python package it installs and contains the package's pinned version and `--hash` option. The `--hash` option value is the SHA256 hash of the package's source tarball; this value can be found on [pypi.org](https://pypi.org/).

For example, the requirements file for setuptools-scm ([setuptools-scm.txt](./host-pip-requirements/setuptools-scm.txt)) contains:

```
setuptools-scm==4.1.2 --hash=sha256:a8994582e716ec690f33fec70cca0f85bd23ec974e3f783233e4879090a7faa8
```

If the Python package to be installed depends on other Python packages, those dependencies, with their pinned versions and `--hash` options, also need to be specified in the requirements file. For instance, [cffi.txt](./host-pip-requirements/cffi.txt) includes information for pycparser because pycparser is a dependency of cffi and will be installed with cffi.

There are two types of requirements files in [host-pip-requirements](./host-pip-requirements):

* Installs the latest version of a Python package.

  A requirements file of this type is named with the package name only (for example, [setuptools-scm.txt](./host-pip-requirements/setuptools-scm.txt)) and is used when there is no strict version requirement.

  These files will be updated as newer versions of the Python packages are available.

* Installs a specific version of a Python package.

  A requirements file of this type is named with the package name and version number (for example, [Django-1.11.txt](./host-pip-requirements/Django-1.11.txt)) and is used when a specific (usually older) version is required.

  Installing the latest versions of packages is preferred over specific versions whenever possible.

#### Installing host-side Python packages

Set `HOST_PYTHON3_PACKAGE_BUILD_DEPENDS` to the names of one or more requirements files in [host-pip-requirements](./host-pip-requirements), without the directory path or ".txt" extension.

For example:

```
HOST_PYTHON3_PACKAGE_BUILD_DEPENDS:=setuptools-scm
```

The Python package will be installed in `$(STAGING_DIR_HOSTPKG)/lib/pythonX.Y/site-packages`.
