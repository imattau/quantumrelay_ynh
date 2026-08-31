#!/usr/bin/env python3
"""Fail CI on any package_linter critical/error, except catalog-membership
checks that are expected to fire until this app is submitted to
YunoHost/apps (it's distributed through a custom catalog instead)."""
import json
import sys

ALLOWED = {"AppCatalog.is_in_catalog", "AppCatalog.state_is_working"}

with open(sys.argv[1]) as f:
    data = json.load(f)

blocking = [c for c in data["critical"] + data["error"] if c not in ALLOWED]
if blocking:
    print("Blocking linter findings:", blocking)
    sys.exit(1)

print("No blocking linter findings (ignoring catalog-membership checks).")
