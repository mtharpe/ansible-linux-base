# ansible-linux-base

Base Linux configuration playbook. Successor to [`chef-linux-base-recipe`](https://github.com/mtharpe/chef-linux-base-recipe).

Applies a minimal, opinionated baseline to fresh Linux hosts:

- Installs core utilities (`bash`, `curl`, `wget`, `unzip`, `mlocate`, `vim`)
- On RHEL family: enables EPEL
- On Ubuntu: purges Landscape client packages, AppArmor, and UFW (the
  `devsec.hardening.os_hardening` role takes over firewall and MAC posture)
- Applies [`devsec.hardening.os_hardening`](https://galaxy.ansible.com/ui/repo/published/devsec/hardening/) and `devsec.hardening.ssh_hardening`

Supported targets: Ubuntu 22.04+, Debian 12+, Rocky/Alma/RHEL 8+.

## Layout

```
ansible-linux-base/
├── setup_linux.yml         # entrypoint playbook
├── ansible.cfg
├── inventory               # localhost by default
├── requirements.yml        # ansible.posix, community.general, devsec.hardening
├── handlers/main.yml       # sshd restart handler
├── meta/main.yml           # role metadata
├── vars/vars.yml           # package lists
├── roles/linux_base/tasks/ # repos, packages
├── molecule/               # podman + docker scenarios
├── Makefile                # molecule wrappers
└── run.sh                  # bootstrap + apply against localhost
```

## Usage

Apply against localhost:

```bash
./run.sh
```

Or run manually:

```bash
ansible-galaxy collection install -r requirements.yml
ansible-playbook -i inventory setup_linux.yml
```

## Testing

Molecule scenarios cover Ubuntu 24.04 and Rocky 9 in parallel.

```bash
make test           # podman (default)
make test-docker    # docker
make idempotence-podman
```

## Migrating from `chef-linux-base-recipe`

| Chef | Ansible |
|------|---------|
| `include_recipe 'chef-linux-base-recipe::packages'` | role `linux_base` (tasks/packages.yml) |
| `include_recipe 'os-hardening::default'` | role `devsec.hardening.os_hardening` |
| `include_recipe 'ssh-hardening::default'` | role `devsec.hardening.ssh_hardening` |
| `include_recipe 'yum-epel::default'` (RHEL) | tasks/repos.yml installs `epel-release` |
| Ubuntu `package … action :purge` | `apt: state=absent purge=true` |
