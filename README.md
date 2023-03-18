# setup-my-ubuntu

A simple script to setup your linux machine (ubuntu)

## Covers the below items
1. zsh shell 
   1. via zsh4humans or
   2. via oh-my-zsh
2. py-env for managing python versions
3. Java
4. vscode


## Usage
1. Clone this repository
2. `cd setup-my-ubuntu`
3. `bash setup-system.sh [OPTIONS]`

```bash
bash setup-system.sh [OPTIONS]

  OPTIONS:-
    --zsh         Setup zsh via zsh4humans or oh-my-zsh
    --pyenv       Setup Python version management tool PyENV
    --java        Setup Java
    --vscode      Setup Microsoft Visual Studio Code
```

## Coverage
- [ ] Implement grecent (in .zshrc)
- [x] Basic ZSH setup
- [x] zsh amuse theme with custom prompt
- [ ] 