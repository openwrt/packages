#!/usr/bin/env python3
#
# Copyright (C) 2023 Jeffery To
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

import json
import os
import re
import shutil
import sys


def install(input_path, mpy_version, output_path):
    index_json_path = os.path.join(input_path, "index.json")
    files = {}

    with open(index_json_path) as f:
        index_json = json.load(f)

    for p in index_json["packages"]:
        package_name = p["name"]
        package_json_path = os.path.join(input_path, "package", mpy_version, package_name, "latest.json")

        with open(package_json_path) as f:
            package_json = json.load(f)

        for file_name, file_hash in package_json["hashes"]:
            if file_name in files:
                if file_hash != files[file_name]:
                    print("File name/hash collision:", package_name, file=sys.stderr)
                    print("  File:                  ", file_name, file=sys.stderr)
                    print("  Curent hash:           ", file_hash, file=sys.stderr)
                    print("  Previous hash:         ", files[file_name], file=sys.stderr)
                    sys.exit(1)
            else:
                files[file_name] = file_hash

    for file_name, file_hash in files.items():
        in_file_path = os.path.join(input_path, "file", file_hash[:2], file_hash)
        out_file_path = os.path.join(output_path, file_name)

        os.makedirs(os.path.dirname(out_file_path), exist_ok=True)
        shutil.copy2(in_file_path, out_file_path)


def main():
    import argparse

    cmd_parser = argparse.ArgumentParser(description="Install compiled micropython-lib packages.")
    cmd_parser.add_argument("--input", required=True, help="input directory")
    cmd_parser.add_argument("--version", required=True, help="mpy version to install")
    cmd_parser.add_argument("--output", required=True, help="output directory")
    args = cmd_parser.parse_args()

    install(args.input, args.version, args.output)


if __name__ == "__main__":
    main()
