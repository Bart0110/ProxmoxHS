#!/usr/bin/env bash
source <(curl -fsSL https://raw.githubusercontent.com/Bart0110/ProxmoxHS/main/misc/build.func)
# Copyright (c) 2021-2026 Bart0110
# Author: Bart0110 (Bart0110)
# License: MIT | https://github.com/community-scripts/Bart0110/raw/main/LICENSE
# Source: https://beszel.dev/ | Github: https://github.com/henrygd/beszel

APP="Beszel-Agent"
var_tags="${var_tags:-monitoring}"
var_cpu="${var_cpu:-1}"
var_ram="${var_ram:-512}"
var_disk="${var_disk:-4}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

custom_app_settings() {
  BESZEL_PORT=$(whiptail --title "Connection setup" \
      --inputbox "Enter the port which the Beszel Hub connects to (default: 45876)" 10 72 "45876" 3>&1 1>&2 2>&3)
  BESZEL_SSH_KEY=$(whiptail --title "Connection setup" \
      --inputbox "Enter your Beszel SSH key" 10 72 3>&1 1>&2 2>&3)
}

custom_app_settings

function update_script() {
  header_info
  check_container_storage
  check_container_resources
  if [[ ! -d /opt/beszel ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  if check_for_gh_release "beszel" "henrygd/beszel"; then
    msg_info "Stopping Service"
    systemctl stop beszel-agent
    msg_info "Stopped Service"

    msg_info "Updating Beszel"
    $STD /opt/beszel/beszel-agent update
    sleep 2 && chmod +x /opt/beszel/beszel-agent
    msg_ok "Updated Beszel"

    msg_info "Starting Service"
    systemctl start beszel-agent
    msg_ok "Started Service"
    msg_ok "Updated successfully!"
  fi
  exit
}

start
build_container
description

msg_ok "Completed successfully!\n"
