# -*- coding: utf-8 -*-
# ============================================================================
# PureBasic OOP HTML Documentation Builder & Updater
# Author: MicrodevWeb
# ============================================================================

import os
import subprocess

pb_script_path = r"c:\PB\PB_PROJECT\PB_OOP_WORKSPACE\PUREBASIC_OOP_WORKSPACE\scripts\generate_docs.pb"
exe_path = r"c:\PB\PB_PROJECT\PB_OOP_WORKSPACE\PUREBASIC_OOP_WORKSPACE\scripts\generate_docs.exe"
pbcompiler = r"C:\Program Files\PureBasic\Compilers\pbcompiler.exe"

with open(pb_script_path, "r", encoding="utf-8") as f:
    text = f.read()

# Fix duplicated listicon lines if present
text = text.replace("""    n + "      <li class='nav-item" + Iif(Bool(currentKey="label"), " active", "") + "'><a href='" + relPath + "ui/label.html'><span>Label</span><span class='badge badge-ui'>UI</span></a></li>
    n + "      <li class='nav-item" + Iif(Bool(currentKey="listicon"), " active", "") + "'><a href='" + relPath + "ui/listicon.html'><span>ListIcon</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="listicon"), " active", "") + "'><a href='" + relPath + "ui/listicon.html'><span>ListIcon</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$" + #CRLF$""",
"""    n + "      <li class='nav-item" + Iif(Bool(currentKey="label"), " active", "") + "'><a href='" + relPath + "ui/label.html'><span>Label</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="listicon"), " active", "") + "'><a href='" + relPath + "ui/listicon.html'><span>ListIcon</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$""")

# Also check in EN part
text = text.replace("""    n + "      <li class='nav-item" + Iif(Bool(currentKey="label"), " active", "") + "'><a href='" + relPath + "ui/label.html'><span>Label</span><span class='badge badge-ui'>UI</span></a></li>\n    n + \"      <li class='nav-item\" + Iif(Bool(currentKey=\"listicon\"), \" active\", \"\") + \"'><a href='\" + relPath + \"ui/listicon.html'><span>ListIcon</span><span class='badge badge-ui'>UI</span></a></li>\" + #CRLF$",
"""    n + "      <li class='nav-item" + Iif(Bool(currentKey="label"), " active", "") + "'><a href='" + relPath + "ui/label.html'><span>Label</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$
    n + "      <li class='nav-item" + Iif(Bool(currentKey="listicon"), " active", "") + "'><a href='" + relPath + "ui/listicon.html'><span>ListIcon</span><span class='badge badge-ui'>UI</span></a></li>" + #CRLF$""")

with open(pb_script_path, "w", encoding="utf-8") as f:
    f.write(text)

print("Saved fixed generate_docs.pb. Now compiling...")

res = subprocess.run([pbcompiler, pb_script_path, "/EXE", exe_path, "/CONSOLE", "/THREAD", "/UNICODE", "/XP", "/USER", "/DPIAWARE", "/QUIET"], capture_output=True, text=True)
print("pbcompiler returncode:", res.returncode)
if res.returncode != 0:
    print("Compile error:\n", res.stderr, res.stdout)
else:
    print("Successfully compiled generate_docs.exe. Now running it...")
    run_res = subprocess.run([exe_path], capture_output=True, text=True)
    print("Run output:\n", run_res.stdout)
    if run_res.stderr:
        print("Run stderr:\n", run_res.stderr)
