import subprocess
import time
import win32service
import win32con
import win32gui
import win32process
from PIL import ImageGrab

# Switch to default interactive desktop
d = win32service.OpenDesktop('default', 0, False, win32con.MAXIMUM_ALLOWED)
d.SetThreadDesktop()

exe_path = r"c:\PB\PB_PROJECT\PB_OOP_WORKSPACE\PUREBASIC_OOP_WORKSPACE\tests\demo_canvas_xml.exe"
proc = subprocess.Popen([exe_path], cwd=r"c:\PB\PB_PROJECT\PB_OOP_WORKSPACE\PUREBASIC_OOP_WORKSPACE\tests")

time.sleep(1.5)

target_hwnd = None
def find_window(hwnd, _):
    global target_hwnd
    if win32gui.IsWindowVisible(hwnd):
        _, pid = win32process.GetWindowThreadProcessId(hwnd)
        if pid == proc.pid:
            target_hwnd = hwnd

win32gui.EnumWindows(find_window, None)

out_path = r"c:\PB\PB_PROJECT\PB_OOP_WORKSPACE\PUREBASIC_OOP_WORKSPACE\tests\demo_canvas_xml_screenshot.png"

if target_hwnd:
    rect = win32gui.GetWindowRect(target_hwnd)
    print(f"Target window found: HWND={target_hwnd}, Rect={rect}")
    # Capture bounding box (left, top, right, bottom)
    im = ImageGrab.grab(bbox=rect)
    im.save(out_path)
    print(f"Window screenshot saved: {out_path}")
else:
    print("Warning: HWND for process not found, grabbing full screen...")
    im = ImageGrab.grab()
    im.save(out_path)
    print(f"Full screen saved: {out_path}")

proc.kill()
