#!/usr/bin/env python3
# encoding: utf8
#
# Copyright 2016-2017 Yunhui Fu <yhfudev@gmail.com>
#
# This program is free software: you can redistribute it and/or modify it
# under the terms of the GNU General Public License version 3, as published
# by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranties of
# MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
# PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program.  If not, see <http://www.gnu.org/licenses/>.
#
# For further info, check https://github.com/yhfudev/

import os

print("HTTP/1.0 200 OK")
print("Content-type: text/html\n\n")
print("<html><HEAD><TITLE>Python3 script</TITLE></HEAD>")
print("<BODY><PRE>")
print("<div align=center><h1>A Python CGI index with env variables</h1></div>")
os.system('env')


