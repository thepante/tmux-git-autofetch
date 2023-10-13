#!/usr/bin/env bash

PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"

path_is_repo() {
    (cd "$1" && git rev-parse --is-inside-work-tree &>/dev/null)
}

# Check changed path
check_current() {
    if path_is_repo "$(pwd)"; then
        git fetch -q &
    fi
}

# Fetch current opened repositories
scan_paths() {
    tmux_panes_paths=$(tmux list-windows -F '#{pane_current_path}' | sort | uniq)
    for path in $tmux_panes_paths; do
        if [ -d $path ] && path_is_repo "$path"; then
            cd "$path" && git fetch --all;
        fi
    done
}

# Cron job to keep scanning
add_cron_job() {
    script_file_path="$(readlink -f "$0")"
    if ! crontab -l | grep -q "$script_file_path"; then
        (crontab -l | { cat; echo "*/3 * * * * $script_file_path --scan-paths"; } | crontab -) &&
        echo "Added cron job";
    else
        echo "Cron already exists";
    fi
}

# To check when changing directory
add_shell_hook() {
    if grep -qE "^[^#]*tmux-git-autofetch/" ~/.zshrc; then
        echo "Shell hook already exists";
        return 0;
    fi
    script_file_path="$(readlink -f "$0")"
    cp ~/.zshrc ~/.zshrc.bk_tga &&
    echo "
tmux-git-autofetch() {($script_file_path --current &)}
add-zsh-hook chpwd tmux-git-autofetch
    " >> ~/.zshrc &&
    echo "Added shell hook"
}

install() {
    add_cron_job
    add_shell_hook
    echo "Install is done"
}

case "$1" in
    "--current")
        check_current ;;
    "--scan-paths")
        scan_paths ;;
    "--add-cron")
        add_cron_job ;;
    "--add-hook")
        add_shell_hook ;;
    "--install")
        install ;;
    "")
        install ;;
    *)
        echo "Invalid option: [$1]" >&2
        exit 0 ;;
esac

