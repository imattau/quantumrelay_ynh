#!/bin/bash

# Shared constants and helpers for quantum-relay's YunoHost scripts.

peer_nginx_conf_path() {
	echo "/etc/nginx/conf.d/${app}-peer.conf"
}

# Install (or refresh) the standalone TLS server block that terminates the
# public peer-mesh port. This is not a `location` in the app's main vhost —
# ynh_add_nginx_config only supports appending locations to the domain's
# existing server block, but the peer mesh needs its own `listen <port> ssl`
# server, so it is managed by hand here.
ynh_app_peer_nginx_config() {
	ynh_add_config --template="nginx-peer.conf" --destination="$(peer_nginx_conf_path)"
	systemctl reload nginx
}

ynh_app_remove_peer_nginx_config() {
	ynh_secure_remove --file="$(peer_nginx_conf_path)"
	systemctl reload nginx || true
}

# Re-apply list-valued app settings into config.yaml.
#
# conf/config.yaml hardcodes list values - they're
# YAML lists spanning multiple lines, which ynh_add_config's "key:file"
# bind mechanism can't express, so they're intentionally left out of the
# template and instead round-tripped through PyYAML by scripts/config's
# get__peers/set__peers (see there for why). But that means any script
# that re-renders config.yaml from the template - upgrade, change_url -
# resets them to empty, silently dropping configured values. Call this right
# after such a regen to restore them from the app settings, which scripts/config keeps in sync in
# settings.yml independently of config.yaml.
ynh_app_reapply_peer_lists() {
	python3 - "$install_dir/config.yaml" "${peers:-}" "${trust_peers:-}" "${allowed_pubkeys:-}" <<'PYEOF'
import sys, yaml

path, peers_raw, trust_peers_raw, allowed_pubkeys_raw = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
peers = [p.strip() for p in peers_raw.split(",") if p.strip()]
trust_peers = [p.strip() for p in trust_peers_raw.split(",") if p.strip()]
allowed_pubkeys = [p.strip() for p in allowed_pubkeys_raw.split(",") if p.strip()]

with open(path) as f:
    data = yaml.safe_load(f) or {}

data["peers"] = peers
data.setdefault("trust", {})["peers"] = trust_peers
data.setdefault("auth", {})["allowed_pubkeys"] = allowed_pubkeys

with open(path, "w") as f:
    yaml.safe_dump(data, f, default_flow_style=False, sort_keys=False)
PYEOF
}
