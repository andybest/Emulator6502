#!/usr/bin/env python

"""
  Bin2coe

  Converts a binary file to Xilinx COE format

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
  print(args)
  
  with open(args.input, 'rb') as inputFile:
    with open(args.output, 'w') as outputFile:
      write_coe_header(outputFile)
      write_coe_vector(inputFile, outputFile, bytes_to_skip)


def write_coe_header(f):
  f.write('memory_initialization_radix = 16;\n')
  f.write('memory_initialization_vector =\n')


def write_coe_vector(inputFile, outputFile, skip):
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
    if byte:
      outputFile.write(',\n')
    
  outputFile.write(';\n')
  
if __name__ == '__main__':
  convert_file()