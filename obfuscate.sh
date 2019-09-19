#!/bin/bash

set -e

# Arguments

if [ "$#" -lt 2 ] ; then
  cat <<USAGE
Obfuscates, resigns and repacks IPA file.

$0 path_to_ipa developer_certificate [obfuscator parameters]

Notes:
- path_to_ipa must be absolute
- developer_certificate may be NO_RESIGN which disables resigning
- path to obfuscator binary may be overridden using MACH_OBFUSCATOR environment variable
USAGE

  exit
fi

if [ -z "$MACH_OBFUSCATOR" ] ; then
  MACH_OBFUSCATOR=./MachObfuscator.exe
fi
XRESIGN=XReSign/XReSign/Scripts/xresign.sh


# src path must be absolute!
SRC_APP=$1
CERT=$2
shift
shift

if ! [ -f "$SRC_APP" ] ; then
  echo "$SRC_APP does not exist!" >&2
  exit 1
fi

# Paths
APP_FILENAME=`basename "$SRC_APP"`
APP_DIR=`dirname "$SRC_APP"`

OBF_APP_FILENAME="${APP_FILENAME}_obf.ipa"
OBF_APP="$APP_DIR/$OBF_APP_FILENAME"

TMP_DIR=/tmp/obf
UNPACKED="$TMP_DIR/Payload"

rm -rf "$TMP_DIR" || true
mkdir -p "$TMP_DIR"
rm "$OBF_APP" || true

echo "Unzipping..."

unzip -qd "$TMP_DIR" "$SRC_APP"

echo "Obfuscating..."
ls -Ll "$MACH_OBFUSCATOR"
time "$MACH_OBFUSCATOR" -m realWords "$@" "$UNPACKED"

echo "Zipping..."

(cd "$TMP_DIR" && zip -qr "$OBF_APP_FILENAME" .)
mv "$TMP_DIR/$OBF_APP_FILENAME" "$APP_DIR" 

if [ "$CERT" != "NO_RESIGN" ] ; then
  echo "Resigning..."
  if [ -f "$XRESIGN" ]; then 
    echo "XReSign exists"
    #git pull
  else 
    git clone https://github.com/xndrs/XReSign.git
    #fix permissions
    chmod +x "$XRESIGN"
  fi

  #Xresign has problems with relative paths, only absolute work well,
  #but still, tmp directory is not deleted afterwards.
  #This means that this script must be given an absolute path

  "$XRESIGN" -s "$OBF_APP" -c "$CERT"
else
  echo "Not resigning app"
fi

echo "Done."

