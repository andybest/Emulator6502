#!/bin/sh

dasm  main.dasm -lbuild/romimage-list.txt -obuild/romimage.bin
ftohex 1 build/romimage.bin build/romimage.hex
