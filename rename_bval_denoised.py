#!/usr/bin/env python3
"""Rename .bval/.bvec files by adding _denoised before the extension."""

from __future__ import annotations

import argparse
import os
import shutil
from pathlib import Path


def rename_sidecar_files(root: Path, dry_run: bool, extension: str) -> int:
    renamed = 0
    denoised_suffix = f"_denoised{extension}"
    for dirpath, _dirnames, filenames in os.walk(root):
        for filename in filenames:
            if not filename.endswith(extension):
                continue
            old_path = Path(dirpath) / filename
            in_90_plus_18 = "90+18" in old_path.parts
            if filename.endswith(denoised_suffix):
                if in_90_plus_18:
                    original_name = filename[: -len(denoised_suffix)] + extension
                    original_path = Path(dirpath) / original_name
                    if not original_path.exists():
                        if dry_run:
                            print(f"DRY-RUN: {old_path} -> {original_path} (copy)")
                        else:
                            shutil.copy2(old_path, original_path)
                            print(f"COPIED: {old_path} -> {original_path}")
                        renamed += 1
                continue
            new_name = filename[: -len(extension)] + denoised_suffix
            new_path = Path(dirpath) / new_name
            if new_path.exists():
                print(f"SKIP (exists): {new_path}")
                continue
            if dry_run:
                print(f"DRY-RUN: {old_path} -> {new_path}")
                if in_90_plus_18:
                    print(f"DRY-RUN: {new_path} -> {old_path} (copy)")
            else:
                old_path.rename(new_path)
                print(f"RENAMED: {old_path} -> {new_path}")
                if in_90_plus_18:
                    shutil.copy2(new_path, old_path)
                    print(f"COPIED: {new_path} -> {old_path}")
            renamed += 1
    return renamed


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Add _denoised before .bval/.bvec extensions under a root directory."
    )
    parser.add_argument(
        "root",
        nargs="?",
        default="datasets/HCP/HCPDatasetSubsetS1200UnprocessedPrepared_shell_1000/denoise_mppca",
        help="Root directory to scan for .bval/.bvec files",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be renamed without modifying files",
    )
    args = parser.parse_args()

    root = Path(args.root).resolve()
    if not root.exists():
        print(f"ERROR: root does not exist: {root}")
        return 1

    renamed = 0
    for ext in (".bval", ".bvec"):
        renamed += rename_sidecar_files(root, args.dry_run, ext)
    print(f"Done. Files processed: {renamed}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
