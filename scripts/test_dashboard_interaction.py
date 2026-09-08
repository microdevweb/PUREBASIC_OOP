import os
import sys
import time
import subprocess
import threading
from PIL import ImageGrab
import win32gui, win32process, win32con, win32api

def run_test():
    base_dir = r"c:\PB\PB_PROJECT\PB_OOP_WORKSPACE\PUREBASIC_OOP_WORKSPACE"
    exe = os.path.join(base_dir, "examples", "07_project_dashboard", "main.exe")
    
    import win32process
    si = win32process.STARTUPINFO()
    si.lpDesktop = r'WinSta0\default'
    
    hp, ht, pid, tid = win32process.CreateProcess(
        None, exe, None, None, False,
        win32process.NORMAL_PRIORITY_CLASS, None, os.path.dirname(exe), si
    )
    
    print(f"Launched {exe} with PID {pid}")
    time.sleep(1.2)
    
    target_hwnd = None
    def cb(h, _):
        nonlocal target_hwnd
        if win32gui.IsWindowVisible(h):
            _, w_pid = win32process.GetWindowThreadProcessId(h)
            if w_pid == pid:
                t = win32gui.GetWindowText(h)
                if "Project Dashboard" in t:
                    target_hwnd = h
    win32gui.EnumWindows(cb, None)
    
    if not target_hwnd:
        print("[ERROR] Dashboard window not found")
        return
        
    win32gui.ShowWindow(target_hwnd, win32con.SW_RESTORE)
    win32gui.SetWindowPos(target_hwnd, win32con.HWND_TOPMOST, 0, 0, 0, 0, win32con.SWP_NOMOVE | win32con.SWP_NOSIZE)
    time.sleep(0.5)
    
    rect = win32gui.GetWindowRect(target_hwnd)
    print("Window Rect:", rect)
    
    # 1. Capture Base State
    im_base = ImageGrab.grab(bbox=rect)
    im_base.save(r"C:\Users\u237685\.gemini\antigravity-ide\brain\3a007449-0db8-4f8e-820e-bf51539a44e2\dashboard_normal.png")
    print("Saved normal state")
    
    # 2. Hover over Sidebar 'Tasks' button (approx x = rect[0] + 100, y = rect[1] + 200)
    tasks_x = rect[0] + 100
    tasks_y = rect[1] + 200
    win32api.SetCursorPos((tasks_x, tasks_y))
    time.sleep(0.2) # Allow 60fps micro-animation interpolation
    im_hover = ImageGrab.grab(bbox=rect)
    im_hover.save(r"C:\Users\u237685\.gemini\antigravity-ide\brain\3a007449-0db8-4f8e-820e-bf51539a44e2\dashboard_hover.png")
    print("Saved hover state")
    
    # 3. Click 'Save Changes' button
    # In dashboard: Save Changes button is inside the card at approx x = rect[0] + 320, y = rect[1] + 525
    save_x = rect[0] + 320
    save_y = rect[1] + 525
    win32api.SetCursorPos((save_x, save_y))
    time.sleep(0.1)
    win32api.mouse_event(win32con.MOUSEEVENTF_LEFTDOWN, save_x, save_y, 0, 0)
    time.sleep(0.08)
    win32api.mouse_event(win32con.MOUSEEVENTF_LEFTUP, save_x, save_y, 0, 0)
    time.sleep(0.3)
    
    im_saved = ImageGrab.grab(bbox=rect)
    im_saved.save(r"C:\Users\u237685\.gemini\antigravity-ide\brain\3a007449-0db8-4f8e-820e-bf51539a44e2\dashboard_saved.png")
    print("Saved 'Save Changes' state")
    
    # 4. Click 'Cancel' button (x = save_x + 90, y = save_y)
    cancel_x = save_x + 95
    cancel_y = save_y
    win32api.SetCursorPos((cancel_x, cancel_y))
    time.sleep(0.1)
    win32api.mouse_event(win32con.MOUSEEVENTF_LEFTDOWN, cancel_x, cancel_y, 0, 0)
    time.sleep(0.08)
    win32api.mouse_event(win32con.MOUSEEVENTF_LEFTUP, cancel_x, cancel_y, 0, 0)
    time.sleep(0.3)
    
    im_cancel = ImageGrab.grab(bbox=rect)
    im_cancel.save(r"C:\Users\u237685\.gemini\antigravity-ide\brain\3a007449-0db8-4f8e-820e-bf51539a44e2\dashboard_cancel.png")
    print("Saved 'Cancel' state")
    
    # Move mouse away and cleanup
    win32api.SetCursorPos((rect[0] + 10, rect[1] + 10))
    time.sleep(0.2)
    subprocess.run(["taskkill", "/F", "/PID", str(pid)], capture_output=True)
    print("Interactive testing complete!")

if __name__ == "__main__":
    sys.path.append(r"c:\PB\PB_PROJECT\PB_OOP_WORKSPACE\PUREBASIC_OOP_WORKSPACE\scripts")
    from pbo_runner import run_in_desktop
    run_in_desktop(run_test)
