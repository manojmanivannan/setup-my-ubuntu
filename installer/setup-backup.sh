#!/bin/bash

### NOTE: no `set -e` here — this file is sourced by setup-system.sh.
### See installer/setup-editor.sh for why.

# Items that setup_load_backup (--load-tar, installer/setup-zsh.sh) knows how
# to restore. Keep in sync with that function.
DEFAULT_BACKUP_ITEMS=(
    "$HOME/Documents"
    "$HOME/.ssh"
    "$HOME/.docker"
    "$HOME/.dockerhub"
    "$HOME/.github"
    "$HOME/.gitconfig"
    "$HOME/.config"
    "$HOME/.api_key"
    "$HOME/.gemini"
    "$HOME/.scripts"
    "$HOME/.local/bin"
)

function add_backup_item
{
    local item="$1"
    if [[ "$item" == "~" || "$item" == "~/"* ]]; then
        item="$HOME${item#\~}"
    fi

    if [[ ! -e "$item" ]]; then
        text_red "Skip '$item': no such file or directory"
        return
    fi

    item=$(realpath "$item")
    if [[ "$item" == "$HOME" ]]; then
        text_red "Skip '$item': --load-tar cannot restore your whole home directory"
        return
    fi
    if [[ "$item" != "$HOME"/* ]]; then
        text_red "Skip '$item': --load-tar can only restore paths under $HOME"
        return
    fi

    for existing in "${SELECTED_BACKUP_ITEMS[@]}"; do
        if [[ "$existing" == "$item" || "$existing" == "$item/"* || "$item" == "$existing/"* ]]; then
            text_yellow "Skip '$item': already covered by '$existing'"
            return
        fi
    done

    SELECTED_BACKUP_ITEMS+=("$item")
}

# Non-interactive: set SAVE_TAR_ITEMS (space-separated paths) and
# optionally PATH_TO_SAVE_TAR to skip all prompts.
function setup_save_backup
{
    print_green "Create tarball backup"
    SELECTED_BACKUP_ITEMS=()

    echo
    text_yellow "Default items (--load-tar knows how to restore these):"
    local i=0 item
    for item in "${DEFAULT_BACKUP_ITEMS[@]}"; do
        i=$((i + 1))
        if [[ -e "$item" ]]; then
            printf "  %2d) %s\n" $i "$item"
        else
            printf "  %2d) %s " $i "$item"
            echo -e "${URed}(not present)${Color_Off}"
        fi
    done

    if [[ -n "$SAVE_TAR_ITEMS" ]]; then
        for item in $SAVE_TAR_ITEMS; do
            add_backup_item "$item"
        done
    else
        local answer
        read -e -p "Numbers to include, space separated (default: all): " answer
        echo
        if [[ -z "${answer// /}" ]]; then
            for item in "${DEFAULT_BACKUP_ITEMS[@]}"; do
                add_backup_item "$item"
            done
        else
            for i in $answer; do
                item="${DEFAULT_BACKUP_ITEMS[$((i-1))]}"
                if [[ -n "$item" ]]; then
                    add_backup_item "$item"
                else
                    text_red "Invalid number: $i"
                fi
            done
        fi

        while true; do
            read -e -p "Add another path (file or folder, blank to finish): " item
            [[ -z "$item" ]] && break
            add_backup_item "$item"
        done
    fi

    if [[ ${#SELECTED_BACKUP_ITEMS[@]} -eq 0 ]]; then
        text_red "Nothing selected, aborting"
        return 1
    fi

    confirm_save_backup
}

function confirm_save_backup
{
    local out
    out="${PATH_TO_SAVE_TAR:-$HOME/linux_backup_$(date +"%Y-%m-%d-%H-%M").tar.gz}"
    # both env vars set = non-interactive: no prompts at all
    if [[ -n "$PATH_TO_SAVE_TAR" && -n "$SAVE_TAR_ITEMS" ]]; then
        out="$PATH_TO_SAVE_TAR"
    fi

    echo
    text_yellow "Items selected:"
    local item
    for item in "${SELECTED_BACKUP_ITEMS[@]}"; do
        echo "  $item"
    done

    local total_size
    total_size=$(du -sb "${SELECTED_BACKUP_ITEMS[@]}" 2>/dev/null | awk '{s+=$1} END {print s}')
    local total_megabytes
    total_megabytes=$(awk "BEGIN {printf \"%.2f\", ${total_size:-0} / 1048576}")
    echo "Total size: $total_megabytes MB"

    # tar stores entries relative to -C dir (stripped of the leading '/'),
    # which is the layout setup_load_backup expects: home/manoj/...
    local -a tar_entries=()
    for item in "${SELECTED_BACKUP_ITEMS[@]}"; do
        tar_entries+=("${item#/}")
    done

    echo
    local answer
    if [[ -n "$PATH_TO_SAVE_TAR" && -n "$SAVE_TAR_ITEMS" ]]; then
        answer=""
    else
        read -e -p "Save as [$out]: " answer
    fi
    [[ -n "$answer" ]] && out="$answer"

    echo
    if [[ -n "$PATH_TO_SAVE_TAR" && -n "$SAVE_TAR_ITEMS" ]]; then
        answer="y"
    else
        read -e -p "Create the backup? (y/n) " answer
        if [[ ! "$answer" =~ ^[Yy]$ ]]; then
            text_red "Aborted"
            return
        fi
    fi

    local tar_ok
    if command -v pv >/dev/null 2>&1; then
        tar -cf - -C / "${tar_entries[@]}" | pv -s $total_size | gzip > "$out"
        tar_ok=${PIPESTATUS[0]}
    else
        tar -czf "$out" -C / "${tar_entries[@]}"
        tar_ok=$?
    fi

    if [[ $tar_ok -eq 0 && -f "$out" ]]; then
        print_green "Backup created: $out (pass it to --load-tar on the new machine)"
    else
        text_red "Failed to create backup: $out"
    fi
}