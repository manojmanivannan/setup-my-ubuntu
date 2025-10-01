# Bash completion for the vbox.sh script

_vbox_complete() {
    local cur prev vm_names operations
    
    # COMP_WORDS: An array of the words on the current command line.
    # COMP_CWORD: The index of the word containing the current cursor position.
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Define the list of operations for completion
    operations="start stop poweroff reboot reset pause resume savestate status"

    # Completion for the argument right after the script name (index 1)
    if [ ${COMP_CWORD} -eq 1 ]; then
        COMPREPLY=( $(compgen -W "--name --help -h" -- "${cur}") )
        return 0
    fi
    
    # Check the context based on the previous word
    case "${prev}" in
        --name)
            # Suggest VM names by fetching them live
            vm_names=$(VBoxManage list vms | sed -e 's/.*"\(.*\)".*/\1/')
            COMPREPLY=( $(compgen -W "${vm_names}" -- "${cur}") )
            return 0
            ;;
        *)
            # If we are at the 4th position (e.g., "vbox --name MyVM <cursor_here>"),
            # we should suggest operations.
            if [ ${COMP_CWORD} -eq 3 ]; then
                COMPREPLY=( $(compgen -W "${operations}" -- "${cur}") )
            fi
            ;;
    esac
}

# Register the completion function for our script.
# This assumes the script is named 'vbox' (if you renamed and moved it)
# or 'vbox.sh' if you are running it from the local directory as ./vbox.sh
complete -F _vbox_complete vbox
