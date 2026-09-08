import os
import sys
import time
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

def transpile_and_compile(pb_file, out_exe=None):
    base_dir = r"c:\PB\PB_PROJECT\PB_OOP_WORKSPACE\PUREBASIC_OOP_WORKSPACE"
    transpiler = os.path.join(base_dir, "compiler", "transpiler.exe")
    pbcompiler = r"C:\Program Files\PureBasic\Compilers\pbcompiler.exe"
    
    pb_file = os.path.abspath(pb_file)
    dir_name = os.path.dirname(pb_file)
    base_name = os.path.splitext(os.path.basename(pb_file))[0]
    
    transpiled_file = os.path.join(dir_name, f"{base_name}_transpiled.pb")
    if not out_exe:
        out_exe = os.path.join(dir_name, f"{base_name}.exe")
        
    print(f"[1/2] Transpiling {pb_file} -> {transpiled_file}...")
    t_res = subprocess.run([transpiler, pb_file, transpiled_file, "--base-dir", base_dir], capture_output=True, text=True)
    if t_res.returncode != 0:
        print("[ERROR] Transpilation failed:")
        print(t_res.stdout)
        print(t_res.stderr)
        return None
        
    print(f"[2/2] Compiling {transpiled_file} -> {out_exe}...")
    c_res = subprocess.run([
        pbcompiler, transpiled_file,
        "/OUTPUT", out_exe,
        "/THREAD", "/UNICODE", "/XP", "/USER", "/DPIAWARE"
    ], capture_output=True, text=True)
    
    if c_res.returncode != 0:
        print("[ERROR] PureBasic compilation failed:")
        print(c_res.stdout)
        print(c_res.stderr)
        return None
        
    print(f"[SUCCESS] Built {out_exe}")
    return out_exe

def launch_on_desktop(exe_path, cwd=None):
    import win32process
    si = win32process.STARTUPINFO()
    si.lpDesktop = r'WinSta0\default'
    if not cwd:
        cwd = os.path.dirname(exe_path)
    
    hp, ht, pid, tid = win32process.CreateProcess(
        None, exe_path, None, None, False,
        win32process.NORMAL_PRIORITY_CLASS, None, cwd, si
    )
    return pid

def capture_window_for_pid(pid, output_png, wait_sec=2.0, kill_after=True):
    def _inner():
        import win32gui, win32process, win32con
        from PIL import ImageGrab

        time.sleep(wait_sec)
        target_hwnd = None
        target_title = ""
        
        def cb(h, _):
            nonlocal target_hwnd, target_title
            if win32gui.IsWindowVisible(h):
                _, w_pid = win32process.GetWindowThreadProcessId(h)
                if w_pid == pid:
                    t = win32gui.GetWindowText(h)
                    if t:
                        target_hwnd = h
                        target_title = t
        win32gui.EnumWindows(cb, None)

        if not target_hwnd:
            print(f"[WARN] No visible window found for PID {pid}")
            return False

        print(f"[CAPTURE] Window found: HWND={target_hwnd}, Title='{target_title}'")
        win32gui.ShowWindow(target_hwnd, win32con.SW_RESTORE)
        win32gui.SetWindowPos(target_hwnd, win32con.HWND_TOPMOST, 0, 0, 0, 0, win32con.SWP_NOMOVE | win32con.SWP_NOSIZE)
        time.sleep(0.5)

        rect = win32gui.GetWindowRect(target_hwnd)
        im = ImageGrab.grab(bbox=rect)
        im.save(output_png)
        print(f"[CAPTURE] Screenshot saved: {output_png} ({im.size})")

        if kill_after:
            subprocess.run(["taskkill", "/F", "/PID", str(pid)], capture_output=True)
            print(f"[CLEANUP] Process {pid} stopped.")
        return True

    return run_in_desktop(_inner)

def launch_pb_ide(file_to_open=None):
    # Check official or PBO IDE
    base_dir = r"c:\PB\PB_PROJECT\PB_OOP_WORKSPACE\PUREBASIC_OOP_WORKSPACE"
    pbo_ide = os.path.join(base_dir, "pbo_ide.exe")
    official_ide = r"C:\Program Files\PureBasic\PureBasic.exe"
    
    ide = pbo_ide if os.path.exists(pbo_ide) else official_ide
    cmd = f'"{ide}"'
    if file_to_open:
        cmd += f' "{os.path.abspath(file_to_open)}"'
        
    print(f"Launching IDE on user desktop: {cmd}")
    pid = launch_on_desktop(cmd, base_dir)
    return pid

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python pbo_runner.py [build|run|test|ide] <file>")
        sys.exit(1)
        
    action = sys.argv[1].lower()
    
    if action == "build":
        transpile_and_compile(sys.argv[2])
    elif action == "run":
        exe = sys.argv[2]
        if exe.endswith(".pb"):
            exe = transpile_and_compile(exe)
        if exe:
            pid = launch_on_desktop(exe)
            print(f"Running PID {pid}")
    elif action == "test":
        pb_file = sys.argv[2]
        out_png = sys.argv[3] if len(sys.argv) > 3 else pb_file.replace(".pb", "_shot.png")
        exe = transpile_and_compile(pb_file)
        if exe:
            pid = launch_on_desktop(exe)
            capture_window_for_pid(pid, out_png, wait_sec=2.0, kill_after=False)
    elif action == "ide":
        f = sys.argv[2] if len(sys.argv) > 2 else None
        launch_pb_ide(f)
