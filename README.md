# setup-my-ubuntu

A simple script to setup your personal linux machine (Ubuntu)

## Coverage

- [x] ZSH
  - [x] oh-my-zsh (custom prompt)
  - [x] zsh4humans
- [x] Java
- [x] Spark
- [x] Maven
- [x] PyENV
- [x] Docker & docker-compose
- [ ] VLC
- [ ] OBS
- [x] VS Code
- [x] SSH keys
- [x] Terminator
- [x] Sublime Text


## Usage
1. Clone this repository
2. `cd setup-my-ubuntu`
3. `bash setup-system.sh [OPTIONS]`

```bash
bash setup-system.sh [OPTIONS]

  OPTIONS:
    --zsh         Setup zsh via zsh4humans or oh-my-zsh
    --pyenv       Setup Python version management tool PyENV
    --java        Setup Java
    --maven       Setup Maven
    --spark       Setup Apache Spark
    --vscode      Setup Microsoft Visual Studio Code
    --sshkey      Setup ssh key pair
    --docker      Setup docker and docker-compose
    --terminal    Setup Gnome terminator
    --sublt       Setup Sublime text
    --all         Setup everything (same as passing all flags)
```

