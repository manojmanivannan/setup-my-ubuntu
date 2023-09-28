# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh
# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes

ZSH_THEME="amuse"
# ZSH_THEME="powerlevel9k/powerlevel9k"
export DOCKER_BUILDKIT=0
export COMPOSE_DOCKER_CLI_BUILD=0

##################################################################
# # Theme: powerlevel9k
# ## https://github.com/bhilburn/powerlevel9k
# # POWERLEVEL9K_INSTALLATION_PATH=$ANTIGEN_BUNDLES/bhilburn/powerlevel9k
# ## configurations:
# POWERLEVEL9K_MODE='awesome-patched'
# POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(status dir dir_writable vcs)
# POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(time)
# POWERLEVEL9K_SHORTEN_DIR_LENGTH=2
# POWERLEVEL9K_DIR_WRITABLE_FORBIDDEN_FOREGROUND="white"
# POWERLEVEL9K_STATUS_VERBOSE=false
# POWERLEVEL9K_TIME_BACKGROUND="black"
# POWERLEVEL9K_TIME_FOREGROUND="249"
# POWERLEVEL9K_TIME_FORMAT="%D{%H:%M} \uE12E"
# POWERLEVEL9K_COLOR_SCHEME='dark'
# POWERLEVEL9K_VCS_GIT_ICON='\uE1AA'
# POWERLEVEL9K_VCS_GIT_GITHUB_ICON='\uE1AA'
# POWERLEVEL9K_VCS_GIT_GITLAB_ICON='\uE1AA'
# POWERLEVEL9K_HIDE_BRANCH_ICON=true

# POWERLEVEL9K_DIR_HOME_FOREGROUND='254'
# POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND='254'
# POWERLEVEL9K_DIR_ETC_FOREGROUND='254'
# POWERLEVEL9K_DIR_DEFAULT_FOREGROUND='254'

# POWERLEVEL9K_VCS_CLEAN_FOREGROUND='254'
# POWERLEVEL9K_VCS_UNTRACKED_FOREGROUND='254'
# POWERLEVEL9K_VCS_MODIFIED_FOREGROUND='254'


##################################################################

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

plugins=(git
zsh-autosuggestions
zsh-syntax-highlighting
fzf-zsh-plugin
colored-man-pages
colorize
command-not-found
web-search
kubectl
zsh-aliases-exa
z
virtualenv
)
export ZSH_HIGHLIGHT_MAXLENGTH=500
source $ZSH/oh-my-zsh.sh

bindkey '^j' forward-word
bindkey '^f' backward-word

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

alias bat="batcat"
alias sz='source ~/.zshrc'
autoload -U bashcompinit
bashcompinit

# To enable autocomplete to your script
# eval "$(register-python-argcomplete /tmp/test.py)"
# where /tmp/test.py is below
# #!/usr/bin/env python3
# PYTHON_ARGCOMPLETE_OK
# import argcomplete, argparse, requests, pprint
# from argcomplete.completers import ChoicesCompleter
#
# def github_org_members(prefix, parsed_args, **kwargs):
#     resource = "https://api.github.com/orgs/{org}/members".format(org=parsed_args.organization)
#     return (member['login'] for member in requests.get(resource).json() if member['login'].startswith(prefix))

# parser = argparse.ArgumentParser()
# parser.add_argument("--organization", help="GitHub organization")
# parser.add_argument("--member", help="GitHub member").completer = github_org_members
#
# argcomplete.autocomplete(parser)
# args = parser.parse_args()
#
# pprint.pprint(requests.get("https://api.github.com/users/{m}".format(m=args.member)).json())


function py_select() {
    # only accepts file paths are arguments
    ~/.scripts/py_script.py $@

}


fs() {
    local PATH_REGEX=${1?param missing - specify the path regex}
    local FILE_REGEX=${2?param missing - specify the file regex}
    local SEARCH_REGEX=${3?param missing - specify the string regex}
    find "$PATH_REGEX" -name "$FILE_REGEX" -print0 | xargs -0 grep -Hrin "$SEARCH_REGEX" | grep -i "$SEARCH_REGEX"
}

s() {
    # s 'string1.*string2' path -> for AND
    # s 'string1\|string2' path -> for OR
	regex=${1?param missing - specify string to search} 
	location=${2?param missing - specify directory to search (recursive)} 
	location="$(realpath $location)"
	filename_ext="${3}"  #regex for file type, eg METRIC.xml
	if [ -z "$filename_ext" ]; then 
		filename_ext="*"; 
	else 
		filename_ext="$filename_ext"; fi
	
	grep -HErin "$regex" --include "$filename_ext" "$location";}

sf() {
    # s 'string1.*string2' path -> for AND
    # s 'string1\|string2' path -> for OR
        regex=${1?param missing - specify string to search}
        location=${2?param missing - specify directory to search (recursive)}
        #location="$(realpath $location)"
        filename_ext="${3}"  #regex for file type, eg METRIC.xml
        if [ -z "$filename_ext" ]; then
                filename_ext="*";
        else
                filename_ext="$filename_ext"; fi

        grep -lrin "$regex" --include "$filename_ext" "$location";
    }

sxtract(){
    local FILE=${1?param missing - specify file name}
    local REGEX=${2?param missing - specify the starting word}
    grep -oiP '(?<='"$REGEX"'")[a-zA-Z0-9_]+' $FILE


}

f() {	
	local regex=${1?param missing - specify string.} 
	local location=${2?param missing - specify directory.}
    local extra_args="${3:-empty}"
	location="$(realpath $location)"
    if [[ $extra_args = *print* ]]; then
        find "$location" -type f -iname "*$regex*" -print0
    else
        find "$location" -type f -iname "*$regex*" | grep -i "$regex"
    fi
    }


fo(){
    local regex=${1?param missing - specify string.}
    local location=${2?param missing - specify directory.}
    local RESULT=$(f $regex $location)
    local RESULT_LENGTH=$(echo $RESULT | tr ' ' '\n' | wc -l)

    if [[ ${RESULT_LENGTH} == "1" ]] && [[ ! -z ${RESULT} ]]; then
        echo "Opening $RESULT"
        sleep 0.5
        vim $RESULT
    elif [[ ${RESULT_LENGTH} -gt "1" ]] && [[ ! -z ${RESULT} ]]; then
        local array=()
        while IFS=  read -r -d $'\0'; do
            array+=("$REPLY")
        done < <(f $regex $location "print")
        #echo "Array ${array[@]}"
        py_select "$location" "${array[@]}"
    else
        echo "No files found matching: \"$1\""
    fi
}

s_in_quotes(){
    usage(){
        echo "Search any word [matching regex: a-zA-Z0-9_] betweem quotes, preceeded by another string"
        echo "s_in_quotes -word_before 'name' -file /path/to/file"
        
    }
    if [ $# -lt 1 ]
    then
        usage
        return
    fi

    local PRINT_SILENT=0
    while [[ $# > 0 ]]
    do
        key=$1
        case "$key" in
            -word_before) shift; local WORD_BEFORE_QUOTES=${1?Specifcy the string before quotes for -word_before} ;;
            -file) shift; local FILE_NAME=${1?Specify file path for -file} ;;
            -s) PRINT_SILENT=1 ;;
            *)  echo"Invalid option"; local INVALID=1; usage;;
        esac
        shift
    done

    if [[ ${INVALID} -ne 1 ]] && [[ ! -z ${WORD_BEFORE_QUOTES} ]] && [[ ! -z ${FILE_NAME} ]]; then


        if [[ ${PRINT_SILENT} -eq 0 ]]; then
            echo "Searching words within quotes matching regex .*${WORD_BEFORE_QUOTES}\"([a-zA-Z0-9_]{0,50})\".* in ${FILE_NAME}"
            echo
        fi
        sed -nr "s/.*${WORD_BEFORE_QUOTES}\"([a-zA-Z0-9_]{0,50})\".*/\1/p" $FILE_NAME
    else
        usage
    fi
}

function cd() {
  builtin cd "$@"

  if [[ -z "$VIRTUAL_ENV" ]] ; then
    ## If env folder is found then activate the vitualenv
      if [[ -d ./venv ]] ; then
        source ./venv/bin/activate
      fi
  else
    ## check the current folder belong to earlier VIRTUAL_ENV folder
    # if yes then do nothing
    # else deactivate
      parentdir="$(dirname "$VIRTUAL_ENV")"
      if [[ "$PWD"/ != "$parentdir"/* ]] ; then
        deactivate
      fi
  fi
}

function mkdirr() {
    mkdir -p "$@"
    builtin cd "$@"
}

transpose() {
    local filename=${1?param missing - specify full file path}
    ruby -rcsv -e 'puts CSV.parse(STDIN).transpose.map &:to_csv' < "$filename" | while IFS=\, read -r a b ; do echo "$a=$b" ; done
}

csv() {
    local filename=${1?param missing - specify full file path}
    tabview $filename
    #    column -t -s, < "$filename" | less -#2 -N -S 
}



export PATH=${PATH}:~/.local/bin


[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# https://github.com/junegunn/fzf/wiki/Examples

# fd - cd to selected directory
fd() {
  local dir
  dir=$(find ${1:-.} -path '*/\.*' -prune -o -type d -print 2> /dev/null | fzf +m) &&
  cd "$dir"
}

# cf - fuzzy cd from anywhere
# ex: cf word1 word2 ... (even part of a file name)
# zsh autoload function
cf() {
  local file
  
  file="$(locate -Ai -0 $@ | grep -z -vE '~$' | fzf --read0 -0 -1)"

  if [[ -n $file ]]
  then
    if [[ -d $file ]]
    then
      cd -- $file
    else
      cd -- ${file:h}
    fi
  fi
}

tips(){
    local search=${1?param missing - specify search string}
    grep -Hrin -A3 -B3 $search ~/Documents/tips/Diagnostix-cloud-Feed-validation.txt
}

count_records(){
	dir=${1?param missing - specify directory}
	location="$(realpath $dir)"
	header=${2?param missing - specify number of lines to consider as header rows}
	variable=$(find $dir -type f | xargs wc -l | awk '$1 > 1' | grep -v total | awk '{s+=$1-'$header'} END {printf "%.0f\n", s}')
	echo "Directory:  $location"
	echo "No lines :  $variable (ignoring $header lines as header):"
}

function wait_for()
{

    local SEC="$1"
    echo -n "Waiting for $SEC seconds ["
    for i in `seq 1 $SEC`; do
        echo -n "."
        sleep 1
    done
    echo "done]"
}

# Auto completion for kubectl
# source <(kubectl completion zsh)
#TMOUT=300
#TRAPALRM() { if command -v cmatrix &> /dev/null; then cmatrix -sb; fi }
#
#source /etc/profile.d/maven.sh

# GIT Functions
function gpush(){
    if [[ $1 == "--force" ]]
    then
        local force="--force"
    else
        local force=""
    fi
    local cur_branch=$(git branch --show-current)
    echo git push $force origin $cur_branch
    git push $force origin $cur_branch
    if [ $? -eq "128" ]; then
        read "REPLY?Push to origin $cur_branch ?[y/N] "
        if [[ $REPLY =~ ^[Yy]$ ]]
        then
            echo git push --set-upstream origin $cur_branch
            git push --set-upstream origin "$cur_branch"
        fi
    fi
}

alias gdiff='ydiff -s -w0'

function gcommit(){
    local MSG="$@"
    #echo "Message $MSG"
    
    local JIRA_ID=$(git branch --show-current | grep -oh -E '([nla|ap|in|NLA|AP|IN]+-[0-9]+)')
    local commit_message="$JIRA_ID $MSG"
    echo git commit -m "\"$commit_message\""
    git commit -m "$commit_message"
    echo "Commit SHA: $(git rev-parse --verify HEAD)"
}

function gcorecent(){
    local branch=$(git recentb | cut -d ' ' -f1,3 | fzf | cut -d ' ' -f2)
    echo "Switching to $branch"
    gco $branch
}

function glsupport(){
    for each in $(git branch --list support/2.1\*);
    do
        #echo "Fetching $each"
        echo "gfo $each:$each"
        gfo $each:$each
    done
}

function gcbi(){
    local TYPE=${1?Type of branch missing - b:bugfix or f:feature}
    local JIRA=${2?JIRA ticket no without IN}
    if [[ "$TYPE" == "b" ]]; then
        gcb "bugfix/IN-$JIRA"
    elif [[ "$TYPE" == "f" ]]; then
        gcb "feature/IN-$JIRA"
    else
        echo "Invalid type"
    fi
}
alias grecent=gcorecent
alias gclean='git clean -fd && git checkout -- .'
alias glast-tag='git describe --tags --abbrev=0'

function glast-tags-in-branch(){
    local BRANCH_NAME=${1?param missing - specify branch name}
    local CUR_BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
    local DISPLAY=${2:-1}
    git rev-parse --verify $BRANCH_NAME &> /dev/null  # verify that $BRANCH_NAME exists
    if [ $? -ne "0" ];then
        echo "Branch $BRANCH_NAME does not exist"
    fi
    if [[ "$BRANCH_NAME" == "$CUR_BRANCH_NAME" ]]; then
        git pull -q
    else
        git fetch -q origin $BRANCH_NAME:$BRANCH_NAME
    fi
    if [ $? -eq "0" ];then
        git tag --merged $BRANCH_NAME | grep -vE '[a-zA-Z]+' | sort -t "." -k1,1n -k2,2n -k3,3n | tail -n$DISPLAY
    else
        echo "Unable to get the last tag from branch $BRANCH_NAME"
    fi
}

function gcommit-since-last-tag(){
    local BRANCH_NAME=${1?param missing - specify branch name}
    git rev-parse --verify $BRANCH_NAME &> /dev/null  # verify that $BRANCH_NAME exists
    if [ $? -ne "0" ];then
        echo "Branch $BRANCH_NAME does not exist"
        return
    fi
    git log $(glast-tags-in-branch $BRANCH_NAME)..$BRANCH_NAME --oneline
}

function gcommit-deleted(){
    local STRING=${1?param missing - specify string to search}
    local FILE=${2?param missing - specify file to search}
    git log -c -S $STRING $FILE
}
function gtag(){
    ~/.scripts/py_tag.py
}

function gmerge(){
    local BRANCH=${1?parameter missing - specify the branch to merge from}
    echo "git fetch origin $BRANCH:$BRANCH && git merge $BRANCH"
    git fetch origin $BRANCH:$BRANCH && git merge $BRANCH
}
# source "/home/mmanivannan/.kubectl/completion"



export KUBECONFIG=''

alias k=kubectl
#alias kubectl='kubectl -n empirix-cloud'
#complete -F __start_kubectl k

set_prompt(){
    #export PROMPT='%{$fg_bold[yellow]($CLUSTER)$reset_color%} %{$fg_bold[green]%}$(_fishy_collapsed_wd)%{$reset_color%}$(git_prompt_info) $ '

    N_CONTEXT=$(kubectl config get-contexts -o=name | wc -l)
    if [[ $N_CONTEXT -eq 1 ]]; then
        CONTEXT=$(kubectl config get-contexts -o=name)
        kubectl config use-context $CONTEXT 
    else
        echo -e "Select CONTEXT:"
        select CONTEXT in $(kubectl config get-contexts -o=name); do break ; done
        kubectl config use-context $CONTEXT
    fi
    export PROMPT='%{$fg_bold[yellow]%}[$CLUSTER-($CONTEXT)] %{$reset_color%}%{$fg_bold[green]%}$(_fishy_collapsed_wd)%{$reset_color%}$(git_prompt_info) $ '
    export POD_NAMESPACE="empirix-cloud"
}
clear_prompt(){
    export PROMPT='%{$fg_bold[green]%}$(_fishy_collapsed_wd)%{$reset_color%}$(git_prompt_info) $ '
    export KUBECONFIG=''
    export POD_NAMESPACE=''
}

alias k.clear=clear_prompt

alias k.ns='echo ${KUBECONFIG}'
alias k.central="export KUBECONFIG=~/.kube/central_config;export CLUSTER=central;set_prompt"
alias k.edge="export KUBECONFIG=~/.kube/central_edge_config;export CLUSTER=edge;set_prompt"
alias k.ireland="export KUBECONFIG=~/.kube/aws_config;export CLUSTER=Ireland;set_prompt"
alias k.billerica="export KUBECONFIG=~/.kube/billerica_config;export CLUSTER=Billerica;set_prompt"
alias k.frankfurt="export KUBECONFIG=~/.kube/aws_frankfurt;export CLUSTER=Frankfurt;set_prompt"
alias k.demo="export KUBECONFIG=~/.kube/demo_cluster.yaml;export CLUSTER=demo;set_prompt"
alias k.milan="export KUBECONFIG=~/.kube/milan_central;export CLUSTER=Milan;set_prompt"
alias k.leo="export KUBECONFIG=~/.kube/leo_config;export CLUSTER=leo;set_prompt"
alias k.london="export KUBECONFIG=~/.kube/london_config;export CLUSTER=London;set_prompt"
alias k.singapore="export KUBECONFIG=~/.kube/aws_singapore;export CLUSTER=singapore;set_prompt"
alias k.christian="export KUBECONFIG=~/.kube/aws_christian;export CLUSTER=christian;set_prompt"
alias k.bhupendra="export KUBECONFIG=~/.kube/apt_bhupendra;export CLUSTER=bhupendra;set_prompt"
alias k.stockholm="export KUBECONFIG=~/.kube/aws_stockholm;export CLUSTER=stockholm;set_prompt"
alias k.devendra.central="export KUBECONFIG=~/.kube/devendra_config_central;export CLUSTER=devendra_central;set_prompt"
alias k.devendra.edge="export KUBECONFIG=~/.kube/devendra_config_edge;export CLUSTER=devendra_edge;set_prompt"
alias k.lunarosa="export KUBECONFIG=~/.kube/lunarosa;export CLUSTER=lunarosa;set_prompt"
alias k.tokyo="export KUBECONFIG=~/.kube/tokyo;export CLUSTER=tokyo;set_prompt"
alias k.marconi="export KUBECONFIG=~/.kube/marconi;export CLUSTER=marconi;set_prompt"
alias k.barb="export KUBECONFIG=~/.kube/barb;export CLUSTER=barb;set_prompt"
alias k.oregon="export KUBECONFIG=~/.kube/aws_oregon; export CLUSTER=Oregon;set_prompt"
alias k.qa="export KUBECONFIG=~/.kube/aws_qa; export CLUSTER=QA;set_prompt"
alias k.nla="export KUBECONFIG=~/.kube/vmware-nla; export CLUSTER=NLA;set_prompt"
alias k.baremetal="export KUBECONFIG=~/.kube/baremetal; export CLUSTER=BAREMETAL;set_prompt"
alias k.sys_ativa="export KUBECONFIG=~/.kube/sys_ativa; export CLUSTER=SYS-ATIVA;set_prompt"
alias k.test="export KUBECONFIG=~/.kube/alessandro_config; export CLUSTER=SYS-ATIVA-TEST;set_prompt"

autoload -Uz compinit
zstyle ':completion:*' menu select
fpath+=~/.zfunc



#### PYENV #########
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
 eval "$(pyenv init -)"
fi

