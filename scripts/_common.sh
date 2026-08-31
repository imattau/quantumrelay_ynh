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
