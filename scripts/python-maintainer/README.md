# pip package to OpenWrt porter

This tools helps maintainers of Python packages which are also available within
`pip` to port and update them as OpenWrt packages.

Below an example configuration porting multiple packages to OpenWrt.

```json
{
    "maintainer": "Paul Spooren <mail@aparcar.org>",
    "packages": {
        "pytest": {
            "depends": "+python3 +python3-py +python3-attrs +python3-six +python3-pluggy +python3-zipp +python3-more-itertools +python3-setuptools"
        },
        "py": {},
        "attrs": {},
        "six": {},
        "pluggy": {},
        "zipp": {},
        "more-itertools": {}
    }
}
```

## Configuration

Must be a `dict` containing the `maintainer` string and a sub-`dict` called
`packages`. Each *package* supports `depends` which is a string added to
`DEPENDS:=` as well as `openwrt_name` which renames the package, if unset the
ouput is `python3-<pkg_name>`.

## Requirements

```sh
python3 -m pip install jinja2
```

## Run

Running the script overwrites all existing packages with the same name,
therefore also usable to upgrade existing packages.

```sh
python3 generate_python_package.py -c config.json -o ~/src/packages/lang/python/
```

## Credits

* Script was created by @lynxis
* Updated to Python3 by @aparcar
* pypi CLI is by Steven Loria

