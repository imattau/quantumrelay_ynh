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

If you change the peer port after install, you'll need to reconfigure any
peer relays that point at the old one.

## Configuration beyond the install questions

`config.yaml` (in the app's install directory) exposes more than the install
wizard does — quantum-walk tuning (`gamma`, `fetch_threshold`, tick
intervals), rate limits, and, importantly, the `peers:` and `trust:` lists
that make the mesh actually mesh with anything. The install wizard leaves
`peers: []`; you need to edit `config.yaml` directly and restart the service
to add peer relays.

Manual edits to `config.yaml` are preserved across upgrades unless you also
change the corresponding install-time setting (YunoHost detects the file has
been hand-modified and won't silently clobber it) — but always back up your
edits before an upgrade regardless.

## Storage

Events and reputation are persisted to SQLite under the app's data directory
and survive restarts and upgrades.
