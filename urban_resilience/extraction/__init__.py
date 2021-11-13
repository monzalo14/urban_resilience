#!/usr/bin/env python

import os

data_dirs = [".tmp", "data"]

for d in data_dirs:
    if not os.path.exists(d):
        print(f"Creating directory {d}")
        os.makedirs(d)

