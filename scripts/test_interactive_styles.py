import os
import sys
import time
import subprocess
import threading
from PIL import ImageGrab
import win32gui, win32process, win32con, win32api

def run_test():
    base_dir = r"c:\PB\PB_PROJECT\PB_OOP_WORKSPACE\PUREBASIC_OOP_WORKSPACE"
    exe = os.path.join(base_dir, "tests", "demo_wpf_styles.exe")
    
    import win32process
    si = win32process.STARTUPINFO()
    si.lpDesktop = r'WinSta0\default'
    
    hp, ht, pid, tid = win32process.CreateProcess(
        None, exe, None, None, False,
        win32process.NORMAL_PRIORITY_CLASS, None, os.path.dirname(exe), si
    )
    
    print(f"Launched {exe} with PID {pid}")
    time.sleep(1.5)
    
    target_hwnd = None
    def cb(h, _):
        nonlocal target_hwnd
        if win32gui.IsWindowVisible(h):
            _, w_pid = win32process.GetWindowThreadProcessId(h)
            if w_pid == pid:
                t = win32gui.GetWindowText(h)
                if "WPF Styles" in t:
                    target_hwnd = h
    win32gui.EnumWindows(cb, None)
    
    if not target_hwnd:
        print("Window not found")
        return
        
    win32gui.ShowWindow(target_hwnd, win32con.SW_RESTORE)
    win32gui.SetWindowPos(target_hwnd, win32con.HWND_TOPMOST, 0, 0, 0, 0, win32con.SWP_NOMOVE | win32con.SWP_NOSIZE)
    time.sleep(0.5)
    
    rect = win32gui.GetWindowRect(target_hwnd)
    print("Window Rect:", rect)
    
    # 1. Capture Normal State
    im1 = ImageGrab.grab(bbox=rect)
    im1.save("tests/wpf_style_normal.png")
    print("Saved normal state")
    
    # Coordinates of "Action Primaire" button: approx rect[0] + 110, rect[1] + 250
    btn_x = rect[0] + 110
    btn_y = rect[1] + 250
    
    # Move mouse to button (Hover)
    win32api.SetCursorPos((btn_x, btn_y))
    time.sleep(0.2) # Allow animation to interpolate
    im2 = ImageGrab.grab(bbox=rect)
    im2.save("tests/wpf_style_hover.png")
    print("Saved hover state")
    
    # Move mouse away (Leave)
    win32api.SetCursorPos((rect[0] + 10, rect[1] + 10))
    time.sleep(0.3) # Allow animation to return to 1.0
    im3 = ImageGrab.grab(bbox=rect)
    im3.save("tests/wpf_style_leave.png")
    print("Saved leave state")
    
    subprocess.run(["taskkill", "/F", "/PID", str(pid)], capture_output=True)
    print("Test completed successfully.")

if __name__ == "__main__":
    from pbo_runner import run_in_desktop
    run_in_desktop(run_test)
