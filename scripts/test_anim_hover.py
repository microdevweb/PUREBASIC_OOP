import time
import win32service, win32con, win32gui, win32api
from PIL import ImageGrab

d = win32service.OpenDesktop('default', 0, False, win32con.MAXIMUM_ALLOWED)
d.SetThreadDesktop()

hwnd = None
def cb(h, _):
    global hwnd
    if win32gui.IsWindowVisible(h) and 'CanvasControl' in win32gui.GetWindowText(h):
        hwnd = h
win32gui.EnumWindows(cb, None)

if not hwnd:
    print("Window not found!")
    exit(1)

win32gui.SetWindowPos(hwnd, win32con.HWND_TOPMOST, 0, 0, 0, 0, win32con.SWP_NOMOVE | win32con.SWP_NOSIZE)
time.sleep(0.3)
rect = win32gui.GetWindowRect(hwnd)

# Capture initial Normal state
im_normal = ImageGrab.grab(bbox=rect)
im_normal.save(r"c:\PB\PB_PROJECT\PB_OOP_WORKSPACE\PUREBASIC_OOP_WORKSPACE\tests\anim_1_normal.png")
print("Saved anim_1_normal.png")

# Target button "Action Primary": roughly left+60, top+385
btn_x = rect[0] + 60
btn_y = rect[1] + 385
win32api.SetCursorPos((btn_x, btn_y))
time.sleep(0.2) # wait for 120ms animation to complete

im_hover = ImageGrab.grab(bbox=rect)
im_hover.save(r"c:\PB\PB_PROJECT\PB_OOP_WORKSPACE\PUREBASIC_OOP_WORKSPACE\tests\anim_2_hover.png")
print("Saved anim_2_hover.png")

# Move mouse away
win32api.SetCursorPos((rect[0] - 100, rect[1] - 100))
time.sleep(0.25) # wait for 160ms animation to complete

im_leave = ImageGrab.grab(bbox=rect)
im_leave.save(r"c:\PB\PB_PROJECT\PB_OOP_WORKSPACE\PUREBASIC_OOP_WORKSPACE\tests\anim_3_leave.png")
print("Saved anim_3_leave.png")
