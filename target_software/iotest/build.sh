#!/bin/sh

dasm  main.dasm -lbuild/output-list.txt -obuild/output.bin
ftohex 1 build/output.bin build/output.hex
