#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

ibtool --compile ../Samples/IosView.nib IosView.xib
ibtool --compile ../Samples/MacView.nib MacView.xib
