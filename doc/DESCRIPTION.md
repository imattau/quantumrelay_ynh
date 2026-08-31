Quantum Relay is a [Nostr](https://github.com/nostr-protocol/nostr) relay
built on the `rely` framework. It moves notes between relays with a
continuous-time quantum-walk propagation model over a peer mesh, and uses a
gossip-based reputation layer to suppress spam network-wide instead of just
locally.

Unlike most relays, publishing a note to one relay can cause it to reach
other relays in the mesh that the author never configured, driven purely by
walk probability and reputation — not by every client blasting every relay.

Supports NIP-01, NIP-09, NIP-11, NIP-13, NIP-15, NIP-20, NIP-22, NIP-40,
NIP-42 and NIP-70.
