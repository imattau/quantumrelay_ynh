## Two public ports

This app exposes two separate public endpoints:

- **The relay itself**, on your chosen domain over 443, like any other
  YunoHost app. Nostr clients connect here (`wss://your.domain/`), and the
  same URL serves the NIP-11 info document to clients that send
  `Accept: application/nostr+json`.
- **The peer mesh**, on the port you chose during install (default 8443).
  Other quantum-relay instances connect here to gossip notes and reputation.
  This port is opened directly in the firewall and terminates TLS itself
  using your domain's existing YunoHost-managed certificate — it is not
  proxied through the standard app vhost, since it isn't a `location` under
  your domain, it's its own `listen <port> ssl` server block.

If you change the peer port from the config panel (below), the old firewall
port is closed, the new one opened, and the peer TLS server block rewritten
automatically — but you'll still need to reconfigure any peer relays that
were pointing at the old port.

## Configuration panel

Apps → Quantum Relay → Config in the webadmin exposes everything that
matters day-to-day, grouped into: relay identity, access control (NIP-42 and
authorized npubs), the read-only mesh dashboard,
rate limits, the peer mesh (public port and the `peers:` list), trust
(weighted peers), and quantum-walk tuning (`gamma`, `fetch_threshold`, tick
intervals, max concurrent fetches). Peer relay URLs and trusted peer URLs
are entered as a comma-separated list of `ws://` / `wss://` URLs.

Saving the panel edits `config.yaml` directly (not just YunoHost's app
settings) and restarts the `quantum-relay` service. The quantum-walk tuning
section is the propagation model's actual knobs, not cosmetic settings —
the defaults are sane for most deployments; only change them if you
understand `cmd/quantum-relay/README.md`'s propagation math.

Anything not in the panel (currently nothing — the panel covers the full
`config.yaml` schema except the internal listen addresses, which are
YunoHost-managed ports) would need a direct edit of `config.yaml` followed
by a service restart.

Authorized-npub management requires a relay binary with allowlist support
(v0.1.6 or newer). The package refuses to save this setting against older
binaries, which only support the global `auth.required` switch.

Enable the mesh dashboard in the panel and add one or more dashboard
administrator npubs. It is then available at `/mesh` and uses NIP-07/NIP-42
authentication; it does not expose peer topology until the browser session is
authenticated.

## Storage

Events and reputation are persisted to SQLite under the app's data directory
and survive restarts and upgrades.
