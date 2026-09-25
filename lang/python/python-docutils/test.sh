#!/bin/sh

[ "$1" = python3-docutils ] || exit 0

python3 - << 'EOF'

import docutils.core
import docutils.parsers.rst

# Basic RST to HTML conversion
rst_input = """\
Hello World
===========

This is a **bold** paragraph with *italics*.

- item one
- item two
"""

html = docutils.core.publish_string(rst_input, writer_name="html")
html_str = html.decode("utf-8")

assert "Hello World" in html_str
assert "<strong>bold</strong>" in html_str
assert "<em>italics</em>" in html_str

EOF
