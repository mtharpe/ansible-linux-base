#!/bin/bash
set -euo pipefail

# Bootstrap helper to install ansible tooling and apply the base linux config
# against localhost. Supports apt (Debian/Ubuntu) and dnf (RHEL family).

if command -v apt-get >/dev/null 2>&1; then
  PKG_MGR=apt
elif command -v dnf >/dev/null 2>&1; then
  PKG_MGR=dnf
else
  echo "Unsupported package manager — install pipx, ansible, ansible-lint manually." >&2
  exit 1
fi

if ! command -v pipx >/dev/null 2>&1; then
  if [ "${PKG_MGR}" = "apt" ]; then
    sudo apt-get update
    sudo apt-get install -y pipx
  else
    sudo dnf install -y pipx
  fi
fi

export PATH="${HOME}/.local/bin:${PATH}"

if ! command -v ansible >/dev/null 2>&1; then
  pipx install --include-deps ansible
fi

if ! command -v ansible-lint >/dev/null 2>&1; then
  pipx install ansible-lint
fi

ansible-galaxy collection install -r requirements.yml --upgrade

SUDOERS_DROPIN="/etc/sudoers.d/${USER}"
if [ ! -f "${SUDOERS_DROPIN}" ]; then
  echo "${USER} ALL=(ALL) NOPASSWD: ALL" | sudo tee -a "${SUDOERS_DROPIN}"
fi

until ansible-playbook setup_linux.yml; do
  echo "Ansible run disrupted, retrying in 10 seconds..."
  sleep 10
done

sudo rm -f "${SUDOERS_DROPIN}"
