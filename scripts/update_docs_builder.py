# ============================================================================
# PureBasic OOP Documentation Generator Helper
# Author: MicrodevWeb
# ============================================================================

import os

pb_file = r"c:\PB\PB_PROJECT\PB_OOP_WORKSPACE\PUREBASIC_OOP_WORKSPACE\scripts\generate_docs.pb"

with open(pb_file, "r", encoding="utf-8") as f:
    code = f.read()

# Let's inspect where FR UI definitions start
print("Read original file, size:", len(code))
