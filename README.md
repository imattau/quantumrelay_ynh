# Quantum Relay for YunoHost

[![Integration level](https://dash.yunohost.org/integration/quantumrelay.svg)](https://dash.yunohost.org/appci/app/quantumrelay)

[Quantum Relay](https://github.com/imattau/quantum-rely) packaged as a
YunoHost application: a [Nostr](https://github.com/nostr-protocol/nostr)
relay that uses quantum-walk propagation over a peer mesh and gossip-based
reputation to move notes between relays and suppress spam network-wide.

## Status

Pinned to upstream release
[`v0.1.0`](https://github.com/imattau/quantum-rely/releases/tag/v0.1.0),
which publishes prebuilt `linux/amd64`/`linux/arm64` binaries via
[`.github/workflows/release.yml`](https://github.com/imattau/quantum-rely/blob/main/.github/workflows/release.yml)
in the upstream repo. This package has not yet been run through the
YunoHost app CI (`tests.toml`) or submitted to the app catalog.

## Two public ports

Unlike most YunoHost apps, this one needs two things open to the internet:
the relay itself (443, like any app) and the peer-mesh port (configurable
at install, default 8443). See [`doc/ADMIN.md`](./doc/ADMIN.md).

## Config panel

Apps → Quantum Relay → Config in the webadmin exposes the app's full
`config.yaml` schema: relay identity, NIP-42 auth, authorized-npub allowlist,
rate limits, peer mesh
(port + peer list), trust weighting, and quantum-walk tuning. See
[`config_panel.toml`](./config_panel.toml) and
[`doc/ADMIN.md`](./doc/ADMIN.md).

## Links

- Report a package-specific bug: this repository's issue tracker
- Report an upstream relay bug: https://github.com/imattau/quantum-rely
- YunoHost website: https://yunohost.org
