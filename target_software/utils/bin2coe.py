#!/usr/bin/env python

"""
  Bin2mif

  Converts a binary file to hex format that can be read by verilog

"""

import argparse
import sys
import binascii


def convert_file():
  # Parse arguments
  parser = argparse.ArgumentParser()
  parser.add_argument('input', help='Binary input file', type=str)
  parser.add_argument('output', help='Output file', type=str)
  parser.add_argument('--skip_bytes', help='Skip first n bytes', required=False, type=int)
  args = parser.parse_args()
  
  bytes_to_skip = 0
  if args.skip_bytes:
    bytes_to_skip = int(args.skip_bytes)
  
  with open(args.input, 'rb') as inputFile:
    with open(args.output, 'w') as outputFile:
      write_vector(inputFile, outputFile, bytes_to_skip)


def write_vector(inputFile, outputFile, skip):
  # Skip bytes
  if skip > 0:
    try:
      inputFile.read(skip)
    except IOError:
      print('Error! Unable to skip %i bytes- reached end of file.' % skip)
      sys.exit(1)
  
  # Write vector
  byte = inputFile.read(1)
  while byte:
    outputFile.write(byte.encode('hex'))
    byte = inputFile.read(1)
    outputFile.write('\n')
  
if __name__ == '__main__':
  convert_file()