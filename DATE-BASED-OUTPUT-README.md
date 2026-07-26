# Date-Based Output Organization for ComfyUI

## Problem

ComfyUI saves all generated images into a flat `output/` directory. Over time this becomes unwieldy — thousands of files in a single folder make browsing slow, file managers sluggish, and backups painful. Users who generate hundreds of images per day have no built-in way to keep things organized without manual intervention or external scripts.

## Solution

This patch adds two new CLI flags:

| Flag | Default | Description |
|------|---------|-------------|
| `--date-based-output` | off | Automatically save outputs into a date-based subfolder |
| `--date-output-format` | `%Y-%m-%d` | Customize the subfolder name using any valid `strftime` format |

When enabled, outputs are saved to `output/YYYY-MM-DD/` (or whatever format the user specifies) instead of the flat `output/` directory.

### Example

```
# Before (flat)
output/
  ComfyUI_00001_.png
  ComfyUI_00002_.png
  ...
  ComfyUI_04821_.png

# After (organized)
output/
  2025-01-15/
    ComfyUI_00001_.png
    ComfyUI_00002_.png
  2025-01-16/
    ComfyUI_00001_.png
  ...
```

## Usage

```bash
# Basic — organize by date (YYYY-MM-DD)
python main.py --date-based-output

# Custom format — organize by year/month
python main.py --date-based-output --date-output-format "%Y/%m"

# Combined with output directory
python main.py --date-based-output --output-directory "/mnt/nas/comfy-output"
```

## Design Choices

### Opt-in, zero disruption
The feature is entirely behind a CLI flag. Users who don't pass `--date-based-output` see no change in behavior whatsoever. Existing workflows, scripts, and API integrations are unaffected.

### Evaluates at render time, not at startup
The date subfolder is computed inside `get_save_image_path()` on every call — not once at server start. This means:
- Images generated before midnight go to today's folder
- Images generated after midnight go to tomorrow's folder
- No server restart required at midnight
- Long-running batch jobs spanning midnight automatically split across the correct date folders

### Respects existing prefix subfolders
If a node uses a prefix like `portraits/ComfyUI`, the date subfolder is prepended:
```
output/2025-01-15/portraits/ComfyUI_00001_.png
```
This preserves any existing organizational structure users may have set up via filename prefixes.

### Counter resets per folder
Each date folder gets its own independent counter starting at `00001`. This avoids the problem of counters reaching absurdly high numbers over months of use.

### Customizable format via `strftime`
The `--date-output-format` flag accepts any valid Python `strftime` format string. This supports a wide range of organizational preferences:

| Format | Result | Use Case |
|--------|--------|----------|
| `%Y-%m-%d` | `2025-01-15` | Daily folders (default) |
| `%Y/%m/%d` | `2025/01/15` | Nested year/month/day |
| `%Y-%m` | `2025-01` | Monthly folders |
| `%Y/week-%W` | `2025/week-03` | Weekly folders |

## Implementation

The patch touches 3 files with 26 insertions and 2 modifications:

- **`comfy/cli_args.py`** — Adds the two CLI argument definitions, placed logically next to `--output-directory`
- **`folder_paths.py`** — 6 lines in `get_save_image_path()` that prepend the date subfolder when the flag is active
- **`tests-unit/comfy_test/folder_path_test.py`** — Adds a dedicated test for the date-based path and updates the existing test to explicitly set `date_based_output=False` so both code paths are covered

### Core logic (folder_paths.py)

```python
if args.date_based_output:
    # Automatically organize outputs into a date-based subfolder.
    # This keeps working across midnight without restarting the server.
    date_subfolder = time.strftime(args.date_output_format, time.localtime())
    subfolder = os.path.join(date_subfolder, subfolder) if subfolder else date_subfolder
```

## Why this belongs upstream

1. **Frequently requested** — Date-based output organization comes up regularly in ComfyUI discussions. Every user who wants this currently has to implement it themselves via wrapper scripts, custom nodes, or manual folder management.

2. **Minimal footprint** — 26 lines of new code across 3 files. No new dependencies. No new modules. No configuration files.

3. **Zero risk to existing users** — Entirely opt-in via CLI flag. Default behavior is unchanged. The feature adds two arguments and a 6-line `if` block.

4. **Consistent with existing patterns** — The implementation follows the same pattern as other CLI flags like `--output-directory` and `--temp-directory`. It integrates naturally with `get_save_image_path()` which already handles subfolder logic.

5. **Tested** — Includes unit tests for both the default (non-date) and date-based code paths.
