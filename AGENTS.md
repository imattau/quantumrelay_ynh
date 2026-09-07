# AGENTS.md

Notes for an AI (or human) picking up this package again. Tribal knowledge
that bit us while operating it, not derivable just by reading the scripts.

## CI: security.yml, not a standalone linter

CI is one call to `imattau/nostr-yunohost`'s shared
`static-security.yml` (lint, shellcheck, secret scan, vuln scan, workflow
lint, manifest validation) - not a bespoke `package_linter.yml`. The full
adoption checklist (what broke, what to copy, what's genuinely
per-package) lives centrally in `nostr-yunohost`'s
`docs/security-workflow.md` under "Adopting this in a new package
repository" - read that before touching CI here, since the two real
gotchas (`.shellcheckrc` for YunoHost's runtime-injected variables, and
the catalog-membership lint allowlist) apply to every `_ynh` package in
this family, not just this one.

No CI attestation (`nostr-ynh attest`, kind-30080 signed CI result) is
wired up yet - CI only produces the unsigned `ci-result.json` artifact.
That's true of every package in this catalog right now, including the
catalog daemon's own repo, not a gap specific to this one.

## Config panel option ids must match their get__/set__ function names exactly

YunoHost dispatches a config-panel option's getter/setter by its exact
declared `id` in `config_panel.toml`, not by whatever name feels intuitive
next to the function definitions in `scripts/config`. `[main.dashboard.enabled]`
looked reasonable and had the right custom `bind = "null"` + a correctly
written `get__dashboard_enabled`/`set__dashboard_enabled` pair - but the
option `id` was `enabled`, not `dashboard_enabled`, so those functions were
silently unreachable dead code. The panel always read back `0`/false
regardless of what was set, and every `app_config_set` call reported
success while doing nothing. `trust.trust_enabled` avoided the identical
trap only because its id already carried the `trust_` prefix. If a
config-panel boolean/value "isn't taking" despite `app_config_set`
returning success, check this first: does the option's TOML table path
literally match its `get__<id>`/`set__<id>` function names, not just look
like it should.

## Two data-loss traps around upgrade/restore, both hit live (2026-09-07)

- **`ynh_systemd_action --line_match="listening"` never actually matched.**
  The Go binary's startup log said `listening addr=...` as of quantum-rely
  v0.1.14 (previously `listen=...`, which doesn't contain the substring
  `"listening"` at all) - a mismatch present since both repos' first
  commits. A slow-enough startup (DB open + the replaceable-key migration +
  peer dials) hitting `ynh_systemd_action`'s wait timeout failed the whole
  upgrade *and* restore identically (restore's own start step waits on the
  same line), and since YunoHost's automatic safety-restore-on-failed-
  upgrade uses the same restore path, both failures cascade into the app
  being fully uninstalled with no fallback. If `app_upgrade`/`backup_restore`
  ever fail again with a generic "error inside the app upgrade/restore
  script" and no visible trace, suspect a slow-start/line_match mismatch
  again before anything else - it's exactly the kind of failure that gives
  no useful error message anywhere the YunoHost API surfaces.
- **A failed upgrade + failed auto-restore leaves `data_dir` behind.**
  `app_remove` (including the one YunoHost runs internally before its
  failed safety-restore) does not appear to purge `data_dir` by default, so
  a fresh reinstall after such a failure can boot against the *old*,
  possibly large, preserved SQLite DB rather than an empty one - a real
  factor in a since-fixed high-CPU incident (a full, unindexed
  `SELECT * FROM events` table scan on every REQ, fixed in quantum-rely
  v0.1.13). Don't assume a reinstalled instance has a clean database; check
  before attributing new resource-usage symptoms to something else.
- **Both failure modes above required a clean `app_install` from the git
  URL to recover, not a repeat `app_upgrade`/`backup_restore` retry - and
  that recovery drops any config-panel state that wasn't itself persisted
  in the failed backup** (peer mesh list, trust peers, dashboard admin
  npub). After any such recovery, diff `app_config_get(app, full=True)`
  against the other running instance (if one exists) rather than assuming
  settings survived.

## Log visibility is worse than it looks from the MCP tooling

The relay logs to its own file (`/var/log/quantumrelay/quantumrelay.log`
via `--log_path` in the systemd unit), not the journal in a way most
journal-reading tools surface - `journalctl -u quantumrelay` (and every
MCP tool backed by it) only shows systemd's own start/stop/CPU-consumed
lifecycle notices, never the application's own `log.Printf` output. Same
for a *failed* `app_upgrade`/`app_install`/`backup_restore` operation log:
YunoHost's own operation log for a failure only ever contained the final
one-line summary error in every case hit here, never the bash `set -x`
trace a *successful* run of the same operation type shows in full. If you
need the real trace of why a lifecycle script failed, that requires actual
SSH access to read the log file or operation log directly - no MCP tool
available at the time of writing gets you there.
