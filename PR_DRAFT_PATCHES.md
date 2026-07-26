# PR: Add patch reapply workflow and date-based launch helper

## Summary

This PR adds an update workflow that **re-applies custom patches after each ComfyUI update**, plus a helper launcher for date-based output organization.

### Included in this PR

- Add `Update ComfyUI with Custom Patches.bat`
  - Runs the normal update flow.
  - Re-applies local patches in sequence:
    - `date-based-output.patch`
    - `server-info.patch`
  - Uses `git apply --check` before applying and detects already-applied patches via reverse-check.
  - Returns non-zero exit code when update fails or patching is not clean.

- Add `Update ComfyUI with Custom Patches and RUN.bat`
  - Calls the patch-aware updater.
  - Starts ComfyUI only if update + patch steps succeed.

- Add `date-based-output.patch`
  - Adds new CLI options in ComfyUI:
    - `--date-based-output`
    - `--date-output-format`
  - Adds date-subfolder logic in `get_save_image_path`.
  - Extends tests for both default and date-based output behavior.

- Add documentation: `DATE-BASED-OUTPUT-README.md`
  - Explains motivation, behavior, and usage examples for the date-based output patch.

- Update `run_nvidia_gpu_with_date.bat`
  - Uses delayed-expansion-safe `!BASE_OUTPUT!` when launching ComfyUI.
  - Clarifies prompt/help text around date-based subfolder behavior.

## Why

Users who keep local ComfyUI customizations currently need to manually re-apply patches after every update. This PR automates that process and adds clear success/failure signaling.

The date-based launcher + patch make generated outputs easier to manage over long-running usage by automatically organizing files into date folders.

## Behavior details

- If update fails: patch stage is skipped and script exits with code `1`.
- If a patch applies cleanly: it is applied with `--whitespace=fix`.
- If a patch is already applied: it is reported as `[SKIP]` and not re-applied.
- If a patch does not apply cleanly: script reports an error and exits with code `1` at the end.

## Manual validation checklist

- [ ] Run `Update ComfyUI with Custom Patches.bat` on a clean state.
- [ ] Re-run it to confirm already-applied patches are detected as `[SKIP]`.
- [ ] Intentionally break one patch hunk to confirm error path and exit code.
- [ ] Run `Update ComfyUI with Custom Patches and RUN.bat` and verify ComfyUI starts only on success.
- [ ] Run `run_nvidia_gpu_with_date.bat` and verify outputs go into date-named subfolders.

## Notes

- This PR contains local automation and patch artifacts intended for this Easy-Install repository.
- The upstream ComfyUI code changes are contained in `date-based-output.patch` and `server-info.patch` for re-application after updates.
