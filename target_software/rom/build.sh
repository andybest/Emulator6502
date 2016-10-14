#!/bin/sh

dasm  main.dasm -lbuild/romimage-list.txt -obuild/romimage.bin
ftohex 1 build/romimage.bin build/romimage.hex
../utils/bin2coe.py build/romimage.bin build/romimage.vbin --skip_bytes=2