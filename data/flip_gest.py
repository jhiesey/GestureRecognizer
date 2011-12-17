import os
import sys


input_dir = sys.argv[1]
output_dir = sys.argv[2]


input_files = os.listdir(input_dir)

for fname in input_files:
	f = open(input_dir + '/' + fname,'r')
	lines = f.readlines()
	f.close()
	newlines = list()
	mid = (len(lines) - 2) / 2
	newlines = lines[0:2] + lines[mid+2:] + lines[2:mid+2]
	fname2 = output_dir + '/' + fname
	f2 = open(fname2,'w')
	print f2
	f2.writelines(newlines)
	f2.close()
