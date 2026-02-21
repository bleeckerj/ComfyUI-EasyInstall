## Do ComfyUI Patches Require a Rebuild?

In most cases, ComfyUI is a Python-based application that loads its code at runtime. This means that if you patch Python source files (such as `.py` files) in the ComfyUI directory, you do **not** need to perform a separate build step—changes are picked up the next time the relevant code is loaded or the server is restarted. However, if you patch dependencies, compiled extensions, or files that are loaded only at startup, you should restart the ComfyUI server to ensure your changes take effect.

For typical workflow and node logic changes, a server restart is sufficient. For UI or frontend changes (if any), you may need to rebuild the frontend assets if the project uses a build system for those parts.

---

## Patch Value and Rationale (for PR Description)

### Value of the Patch
This patch addresses persistent, disruptive full-page reloads in the Next.js/ComfyUI/Photarium development workflow. By moving all runtime data writes out of the source directory, disabling unnecessary background cache refreshes and polling in development, and clarifying the logic for one-time status checks, the patch:

- Eliminates Hot Module Reload (HMR) triggers caused by file writes inside the repo
- Reduces log noise and adds timestamps for easier debugging
- Improves UI layering (modal z-index)
- Ensures a smoother, less disruptive developer experience during editing and uploads

### Rationale
Previously, runtime file writes and aggressive polling caused frequent reloads and noisy logs, making development inefficient and error-prone. This patch ensures that development-time file writes are redirected to temporary directories, and that background refreshes and polling are disabled by default in development. These changes prevent unnecessary reloads, reduce confusion, and make the development environment more stable and predictable. The patch also clarifies the workflow for status checks and improves UI usability, addressing both backend and frontend pain points reported by developers.
============================================================
  How to Apply the server-info.patch to ComfyUI
============================================================

This patch adds folder path information (input, output, temp,
user directories, CWD, and base_path) to the /system_stats
API endpoint in ComfyUI's server.py.

------------------------------------------------------------
  STEPS
------------------------------------------------------------

1. Open a terminal (Command Prompt, PowerShell, or Git Bash)

2. Navigate to your ComfyUI installation directory:

     cd C:\path\to\ComfyUI

3. (Optional) Make sure you're on a clean state:

     git status

4. Apply the patch:

     git apply "\\SYNOLOGY-NAS\homes\imagine\server-info.patch"

   Or if the patch file is copied locally:

     git apply server-info.patch

5. Verify the change was applied:

     git diff server.py

   You should see 6 new lines added after "argv": sys.argv

6. Restart ComfyUI

7. Test it by visiting in your browser:

     http://localhost:8188/system_stats

   Or with curl:

     curl http://localhost:8188/system_stats

   The JSON response should now include these new fields
   inside the "system" object:

     "cwd":             "C:\\path\\to\\ComfyUI"
     "base_path":       "C:\\path\\to\\ComfyUI"
     "input_directory":  "C:\\path\\to\\ComfyUI\\input"
     "output_directory": "C:\\path\\to\\ComfyUI\\output"
     "temp_directory":   "C:\\path\\to\\ComfyUI\\temp"
     "user_directory":   "C:\\path\\to\\ComfyUI\\user"

------------------------------------------------------------
  TROUBLESHOOTING
------------------------------------------------------------

If git apply fails with whitespace errors, try:

     git apply --whitespace=fix server-info.patch

If it fails with "patch does not apply", your server.py
may have been modified. You can apply it manually — the
change is in the system_stats function. Find this line:

     "argv": sys.argv

And change it to:

     "argv": sys.argv,
     "cwd": os.getcwd(),
     "base_path": folder_paths.base_path,
     "input_directory": folder_paths.get_input_directory(),
     "output_directory": folder_paths.get_output_directory(),
     "temp_directory": folder_paths.get_temp_directory(),
     "user_directory": folder_paths.get_user_directory(),

Note the comma added after sys.argv — that's important.

------------------------------------------------------------
  TO REVERT
------------------------------------------------------------

     git checkout server.py

============================================================
