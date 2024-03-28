#!/bin/sh

[ "$1" = python3-pydantic ] || exit 0

python3 -c 'from pydantic import (BaseModel, Field, Json, TypeAdapter)'
