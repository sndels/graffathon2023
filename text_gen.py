#!/usr/bin/python3

import sys

assert len(sys.argv) == 2
input = sys.argv[1]


output_arr = str()
for c in input:
    if c >= 'a' and c <= 'z':
        output_arr += str(ord(c) - ord('a'))
    elif c == '!':
        output_arr += "26"
    elif c == ':':
        output_arr += "27"
    elif c == '-':
        output_arr += "28"
    elif c == '_':
        output_arr += "29"
    elif c == ' ':
        output_arr += "30"
    else:
        print(f"Unsupported char '{c}")
        output_arr += "99"
    output_arr += ','
output_arr = output_arr[:-1]

print(f"const int CHAR_COUNT = {len(input)};")
print("const int CHARS[CHAR_COUNT]= int[](" + output_arr + ");")

