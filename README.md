# setup-my-ubuntu

A simple script to setup your personal linux machine (Ubuntu)

## Coverage

- [x] ZSH + oh-my-zsh
- [x] PyENV
- [x] Docker & docker-compose
- [x] VS Code
- [x] SSH keys
- [x] Terminator
- [x] Sublime Text
- [ ] Uninstall everything
  - [ ] Uninstall single components


## Usage
1. Clone this repository
2. `cd setup-my-ubuntu`
3. `bash setup-system.sh [OPTIONS]`

```bash
$ bash setup-system.sh
Automatically Setup Linux Machine
Usage:
  bash setup-system.sh [OPTIONS]

  Env variables:
    SUDO_PASSWORD              Your sudo password (if not provided, will be prompted)
    VSCODE_INSTALL_FROM_SNAP   Install vscode from snap if true (default: false) (if not provided, will be prompted)
    SUBLIME_INSTALL_FROM_SNAP  Install sublime text from snap if true (default: false) (if not provided, will be prompted)
    PATH_TO_BACKUP_TAR         Path to tarball backup of various configurations (if not provided, will be prompted)

  OPTIONS:
    --essential   Install essential packages
    --zsh         Setup zsh + oh-my-zsh
    --pyenv       Setup Python environment (UV)
    --vscode      Setup Microsoft Visual Studio Code
    --sshkey      Setup ssh key pair
    --docker      Setup docker and docker-compose
    --terminal    Setup Gnome terminator
    --sublt       Setup Sublime text
    --all         Setup everything (same as passing all flags)
    --load-tar    Load configuration from a tarball backup
    --uninstall   Uninstall any packages installed via this script
```

