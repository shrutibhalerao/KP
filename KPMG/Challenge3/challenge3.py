import os
import sys

def get_value(value, key):
    keys = key.split('/')
    for key in keys:
        value = value.pop(key)
    return value

object = {'x': {'y': {'z': 'a'}}}
key = 'x/y/z'

print("Value is:", get_value(object, key))