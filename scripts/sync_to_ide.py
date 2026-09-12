# -*- coding: utf-8 -*-
import os
import shutil

WS_ROOT = r"c:\PB\PB_PROJECT\PB_OOP_WORKSPACE\PUREBASIC_OOP_WORKSPACE"
IDE_ROOT = r"c:\PB\PB_PROJECT\PB_OOP_WORKSPACE\PUREBASIC_OOP_IDE"

def sync_dir(src, dst):
    print(f"Syncing: {src} -> {dst}")
    if os.path.exists(dst):
        shutil.rmtree(dst)
    shutil.copytree(src, dst)

def sync_file(src, dst):
    print(f"Copying file: {src} -> {dst}")
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    shutil.copy2(src, dst)

# 1. Sync framework
sync_dir(os.path.join(WS_ROOT, "framework"), os.path.join(IDE_ROOT, "framework"))

# 2. Sync doc
sync_dir(os.path.join(WS_ROOT, "doc"), os.path.join(IDE_ROOT, "doc"))

# 3. Sync curated examples (01 to 05)
CURATED_EXAMPLES = [
    "01_basics_oop",
    "02_responsive_layout",
    "03_simple_mvvm",
    "04_todo_app",
    "05_project_dashboard",
    "06_canvas_table"
]
ide_ex_dir = os.path.join(IDE_ROOT, "examples")
if os.path.exists(ide_ex_dir):
    shutil.rmtree(ide_ex_dir)
os.makedirs(ide_ex_dir, exist_ok=True)

for ex in CURATED_EXAMPLES:
    src_ex = os.path.join(WS_ROOT, "examples", ex)
    dst_ex = os.path.join(ide_ex_dir, ex)
    print(f"Syncing example: {ex}")
    shutil.copytree(src_ex, dst_ex)

# 4. Sync compiler
sync_file(os.path.join(WS_ROOT, "compiler", "transpiler.pb"), os.path.join(IDE_ROOT, "compiler", "transpiler.pb"))
if os.path.exists(os.path.join(WS_ROOT, "compiler", "transpiler.exe")):
    sync_file(os.path.join(WS_ROOT, "compiler", "transpiler.exe"), os.path.join(IDE_ROOT, "compiler", "transpiler.exe"))

# 5. Sync OOP_Help.pb
sync_file(
    os.path.join(WS_ROOT, "ide_official", "PureBasicIDE", "OOP_Help.pb"),
    os.path.join(IDE_ROOT, "ide", "PureBasicIDE", "OOP_Help.pb")
)

print("\nSynchronization completed successfully!")
