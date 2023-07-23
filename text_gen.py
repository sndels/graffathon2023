#!/usr/bin/python3

import sys

print("Give input as a line, piped or ctrl-D after enter", flush=True)
input = sys.stdin.readlines()
assert len(input) == 1, "Only one input line supported"

output_arr = str()

for c in input[0]:
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
    elif c == ' ' or c == '\n':
        output_arr += "30"
        output_arr
    else:
        print(f"Unsupported char '{c}'")
        output_arr += "99"
    output_arr += ','
output_arr = output_arr[:-1]

print(f"const int CHAR_COUNT = {len(input[0])};")
print("const int CHARS[CHAR_COUNT]= int[](" + output_arr + ");")

