#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Copyright 2014 Steven Loria
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

"""
    pypi_cli
    ~~~~~~~~

    A command line interface to the Python Package Index.

    :copyright: (c) 2014 by Steven Loria.
    :license: MIT, see LICENSE for more details.
"""
from __future__ import division, print_function
import re
import sys
import time
import textwrap
import math
from collections import OrderedDict
PY2 = int(sys.version[0]) == 2
if PY2:
    from xmlrpclib import ServerProxy
    from urllib import quote as urlquote
else:
    from xmlrpc.client import ServerProxy
    from urllib.parse import quote as urlquote

import requests

__version__ = '0.4.1'
__author__ = 'Steven Loria'
__license__ = 'MIT'

DATE_FORMAT = "%y/%m/%d"
MARGIN = 3
DEFAULT_SEARCH_RESULTS = 100

TICK = '*'
DEFAULT_PYPI = 'https://pypi.python.org/pypi'
PYPI_RE = re.compile('''^(?:(?P<pypi>https?://[^/]+/pypi)/)?
                        (?P<name>[-A-Za-z0-9_.]+)
                        (?:/(?P<version>[-A-Za-z0-9.]+))?$''', re.X)
SEARCH_URL = 'https://pypi.python.org/pypi?%3Aaction=search&term={query}'

# Number of characters added by bold formatting
_BOLD_LEN = 8
# Number of characters added by color formatting
_COLOR_LEN = 9

def get_package(name_or_url, client=None):
    m = PYPI_RE.match(name_or_url)
    if not m:
        return None
    pypi_url = m.group('pypi') or DEFAULT_PYPI
    name = m.group('name')
    return Package(name, pypi_url=pypi_url, client=client)

# Utilities
# #########

def lazy_property(fn):
    """Decorator that makes a property lazy-evaluated."""
    attr_name = '_lazy_' + fn.__name__

    @property
    def _lazy_property(self):
        if not hasattr(self, attr_name):
            setattr(self, attr_name, fn(self))
        return getattr(self, attr_name)
    return _lazy_property

class PackageError(Exception):
    pass


class NotFoundError(PackageError):
    pass


# API Wrapper
# ###########

class Package(object):

    def __init__(self, name, client=None, pypi_url=DEFAULT_PYPI):
        self.client = client or requests.Session()
        self.name = name
        self.url = '{pypi_url}/{name}/json'.format(pypi_url=pypi_url,
                                                   name=name)

    @lazy_property
    def data(self):
        resp = self.client.get(self.url)
        if resp.status_code == 404:
            raise NotFoundError('Package not found')
        return resp.json()

    @lazy_property
    def versions(self):
        """Return a list of versions, sorted by release datae."""
        return [k for k, v in self.release_info]

    @lazy_property
    def version_downloads(self):
        """Return a dictionary of version:download_count pairs."""
        ret = OrderedDict()
        for release, info in self.release_info:
            download_count = sum(file_['downloads'] for file_ in info)
            ret[release] = download_count
        return ret

    @property
    def release_info(self):
        release_info = self.data['releases']
        # filter out any versions that have no releases
        filtered = [(ver, releases) for ver, releases in release_info.items()
                    if len(releases) > 0]
        # sort by first upload date of each release
        return sorted(filtered, key=lambda x: x[1][0]['upload_time'])

    @lazy_property
    def downloads(self):
        """Total download count.

        :return: A tuple of the form (version, n_downloads)
        """
        return sum(self.version_downloads.values())

    @lazy_property
    def max_version(self):
        """Version with the most downloads.

        :return: A tuple of the form (version, n_downloads)
        """
        data = self.version_downloads
        if not data:
            return None, 0
        return max(data.items(), key=lambda item: item[1])

    @lazy_property
    def min_version(self):
        """Version with the fewest downloads."""
        data = self.version_downloads
        if not data:
            return (None, 0)
        return min(data.items(), key=lambda item: item[1])

    @lazy_property
    def average_downloads(self):
        """Average number of downloads."""
        return int(self.downloads / len(self.versions))

    @property
    def author(self):
        return self.data['info'].get('author')

    @property
    def description(self):
        return self.data['info'].get('description')

    @property
    def summary(self):
        return self.data['info'].get('summary')

    @property
    def author_email(self):
        return self.data['info'].get('author_email')

    @property
    def maintainer(self):
        return self.data['info'].get('maintainer')

    @property
    def maintainer_email(self):
        return self.data['info'].get('maintainer_email')

    @property
    def license(self):
        return self.data['info'].get('license')

    @property
    def downloads_last_day(self):
        return self.data['info']['downloads']['last_day']

    @property
    def downloads_last_week(self):
        return self.data['info']['downloads']['last_week']

    @property
    def downloads_last_month(self):
        return self.data['info']['downloads']['last_month']

    @property
    def package_url(self):
        return self.data['info']['package_url']

    @property
    def home_page(self):
        return self.data['info'].get('home_page')

    @property
    def docs_url(self):
        return self.data['info'].get('docs_url')

    def __repr__(self):
        return '<Package(name={0!r})>'.format(self.name)

