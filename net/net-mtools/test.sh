#!/bin/sh

msend -v | grep "$2"
mreceive -v | grep "$2"
