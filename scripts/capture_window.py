import sys
import time
import os
import subprocess
import threading
from PIL import Image

def run_in_desktop(func, *args, **kwargs):
    result = {}
    def worker():
        try:
            import win32service, win32con
            d = win32service.OpenDesktop('default', 0, False, win32con.MAXIMUM_ALLOWED)
            d.SetThreadDesktop()
            result['val'] = func(*args, **kwargs)
        except Exception as e:
            result['err'] = e
    t = threading.Thread(target=worker)
    t.start()
    t.join()
    if 'err' in result:
        raise result['err']
    return result.get('val')

def capture_window_by_title(title_sub, output_png):
    def _inner():
        import win32gui, win32ui, win32con
        from PIL import ImageGrab

        target_hwnd = None
        def enum_cb(h, _):
            nonlocal target_hwnd
            if win32gui.IsWindowVisible(h):
                txt = win32gui.GetWindowText(h)
                if title_sub.lower() in txt.lower():
                    target_hwnd = h
        win32gui.EnumWindows(enum_cb, None)

        if not target_hwnd:
            print(f"Window with title containing '{title_sub}' not found.")
            return False

        print(f"Found window: HWND={target_hwnd}, Title='{win32gui.GetWindowText(target_hwnd)}'")
        win32gui.ShowWindow(target_hwnd, win32con.SW_RESTORE)
        win32gui.SetForegroundWindow(target_hwnd)
        time.sleep(0.4)

        rect = win32gui.GetWindowRect(target_hwnd)
        # Capture screen region directly now that it's in foreground
        im = ImageGrab.grab(bbox=rect)
        im.save(output_png)
        print(f"Captured window to {output_png} (size: {im.size})")
        return True

    return run_in_desktop(_inner)

if __name__ == "__main__":
    title = sys.argv[1] if len(sys.argv) > 1 else "CanvasControl"
    out = sys.argv[2] if len(sys.argv) > 2 else r"c:\PB\PB_PROJECT\PB_OOP_WORKSPACE\PUREBASIC_OOP_WORKSPACE\tests\captured_demo.png"
    capture_window_by_title(title, out)
