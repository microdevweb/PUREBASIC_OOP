import time
import win32service
import win32con
import win32gui
import win32api
from PIL import ImageGrab

d = win32service.OpenDesktop('default', 0, False, win32con.MAXIMUM_ALLOWED)
d.SetThreadDesktop()

target_hwnd = None
def cb(h, _):
    global target_hwnd
    if win32gui.IsWindowVisible(h) and 'CanvasControl' in win32gui.GetWindowText(h):
        target_hwnd = h
win32gui.EnumWindows(cb, None)

if not target_hwnd:
    print("Window not found!")
    exit(1)

win32gui.SetForegroundWindow(target_hwnd)
time.sleep(0.3)
rect = win32gui.GetWindowRect(target_hwnd)
print("Window rect:", rect)

# Move mouse over "Action Primary" button
# Looking at the previous screenshot, "Action Primary" is roughly around:
# window left + 60, window top + 390
btn_x = rect[0] + 60
btn_y = rect[1] + 390
print(f"Moving mouse to button at ({btn_x}, {btn_y})")
win32api.SetCursorPos((btn_x, btn_y))
time.sleep(0.5)

im_hover = ImageGrab.grab(bbox=rect)
im_hover.save(r"c:\PB\PB_PROJECT\PB_OOP_WORKSPACE\PUREBASIC_OOP_WORKSPACE\tests\test_hover.png")
print("Saved test_hover.png")

# Now move mouse FAR away outside window
out_x = rect[0] - 100
out_y = rect[1] - 100
print(f"Moving mouse away to ({out_x}, {out_y})")
win32api.SetCursorPos((out_x, out_y))
time.sleep(0.5)

im_leave = ImageGrab.grab(bbox=rect)
im_leave.save(r"c:\PB\PB_PROJECT\PB_OOP_WORKSPACE\PUREBASIC_OOP_WORKSPACE\tests\test_leave.png")
print("Saved test_leave.png")
