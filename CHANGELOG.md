# Changelog

## Unreleased
- Initial scaffold migrated from `chef-linux-base-recipe`
- Translate Chef recipes to an Ansible role: `yum-epel` → `epel-release` package; Ubuntu `package :purge` → `apt: state=absent purge=true`; `os-hardening` and `ssh-hardening` cookbooks → `devsec.hardening.os_hardening` and `devsec.hardening.ssh_hardening` roles
- Add Molecule scenarios for podman and docker drivers, covering Ubuntu 24.04 and Rocky 9
- Add `Makefile`, `run.sh`, `requirements.yml`, and base playbook layout mirroring `ansible-ubuntu-workstation-base`
