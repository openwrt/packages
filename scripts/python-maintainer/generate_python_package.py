#!/usr/bin/env python3

import argparse
import json
import os
import pypi_cli
from jinja2 import Template

parser = argparse.ArgumentParser()
parser.add_argument("-o", "--output", help="output directory",
                    default="feeds")
parser.add_argument("-c", "--config", help="config json file")
parser.add_argument("-v", "--verbose", help="verbose")
args = parser.parse_args()

with open(args.config, "r") as config_file:
    config = json.load(config_file)

localdir = os.path.dirname(os.path.abspath(__file__))
template = open(localdir + '/makefile_template.jinja2').read()
target_dir = args.output

try:
    os.mkdir(target_dir)
except FileExistsError:
    pass

# generate template
templ = Template(template)

class NoVersionFound(RuntimeError):
    pass

def get_release_info(release, ver):
    """ data -> release_data - containing a list of tuple
    """

    for release in release:
        # check if this is the correct version
        if release[0] != ver:
            continue

        # correct version found
        # search for source
        for sub in release[1]:
            if sub['python_version'] == 'source':
                return sub

    raise NoVersionFound("Not found")

def make_package(pkg, config, maintainer):
    if 'openwrt_name' in config:
        openwrt_name = config['openwrt_name']
    else:
        openwrt_name = 'python3-' + pkg

    pkg_dir = target_dir + '/' + openwrt_name

    # create directory
    try:
        os.mkdir(pkg_dir)
    except FileExistsError:
        pass

    # prepare render variables
    pypi = pypi_cli.Package(pkg)
    print(str(pypi))
    version = pypi.data['info']['version']

    release_info = get_release_info(pypi.release_info, version)

    render = {}
    render['input'] = "%s: %s" % (pkg, config)
    render['openwrt_name'] = openwrt_name
    render['package'] = pypi.name
    render['version'] = version

    render['sha256'] = release_info['digests']['sha256']
    render['filename'] = release_info['filename']
    render['maintainer'] = maintainer
    render['first_char'] = pypi.name[0]
    render['license'] = pypi.license
    render['description'] = pypi.summary
    render['depends'] = ''
    if 'depends' in config:
        render['depends'] = config['depends']

    render['is_egg'] = True
    if 'egg' in config:
        render['is_egg'] = config['egg']

    # write out template
    with open(pkg_dir + '/Makefile', 'w') as makefile:
        makefile.write(templ.render(render))

for pkg in config["packages"]:
    print("Package: %s" % pkg)
    make_package(pkg, config["packages"][pkg], config["maintainer"])
