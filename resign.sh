#!/bin/bash

# MachObfuscator doesn't support resigning yet. This script can be used to
# resign all images in the app bundle.

if [ $# != 2 ]
then
    echo "usage: $0 appPath identity"
    echo "eg.: $0 ~/SampleApp.app '-'"
    echo "     $0 ~/SampleApp.app 'iPhone Developer'"
    exit 1
fi

find "$1" -name libswift* | while read FILE; do codesign -f -s "$2" "$FILE";  done
find "$1" -name _CodeSignature | while read FILE; do codesign -f -s "$2" "$FILE/..";  done
