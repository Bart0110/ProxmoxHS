#!/usr/bin/env bash

# Copyright (c) 2021-2026 Bart0110
# Author: Bart0110 (Bart0110)
# License: MIT | https://github.com/community-scripts/Bart0110/raw/main/LICENSE
# Source: https://beszel.dev/ | Github: https://github.com/henrygd/beszel

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"

function custom_app_settings() {
  BESZEL_PORT=$(whiptail --title "Connection setup" \
      --inputbox "Enter the port which the Beszel Hub connects to (default: 45876)" 10 72 "45876" 3>&1 1>&2 2>&3)
  BESZEL_SSH_KEY=$(whiptail --title "Connection setup" \
      --inputbox "Enter your Beszel SSH key" 10 72 3>&1 1>&2 2>&3)
}
custom_app_settings

color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

fetch_and_deploy_gh_release "beszel" "henrygd/beszel" "prebuild" "latest" "/opt/beszel" "beszel-agent_linux_amd64.tar.gz"

msg_info "Creating Service"
cat <<EOF >/etc/systemd/system/beszel-agent.service
[Unit]
Description=Beszel Agent Service
After=network.target

[Service]
ExecStart=/opt/beszel/beszel-agent
WorkingDirectory=/opt/beszel
Restart=always
RestartSec=5
Environment="LISTEN=$BESZEL_PORT"
Environment="KEY=$BESZEL_SSH_KEY"

[Install]
WantedBy=multi-user.target
EOF
systemctl enable -q --now beszel-agent
msg_ok "Created Service"

motd_ssh
customize
cleanup_lxc
