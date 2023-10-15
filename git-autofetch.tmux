#!/usr/bin/env bash

PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin"
conf() (tmux show -gqv "@git-autofetch-$1")

LOGGING=$(conf "logging")
SKIP_PATHS=$(conf "skip-paths")
SCAN_PATHS=$(conf "scan-paths")
SKIP_PATHS=${SKIP_PATHS/\~/$HOME}
SCAN_PATHS=${SCAN_PATHS/\~/$HOME}

log() {
    [ ! "$LOGGING" = "true" ] && return 0;
    local f=${FUNCNAME[1]}
    local r="$2"
    local l="/tmp/tmux-git-autofetch.log"
    [ "$1" = "sep" ] && echo "---" >> $l && return 0;
    [ "$f" = "path_control" ] && (echo "┌ Patterns => Skip: $SKIP_PATHS - Scan: $SCAN_PATHS") >> $l;
    local res=$([[ -n "$r" ]] && echo "true" || echo "false")
    echo "$(date +'%Y-%m-%d-%H:%M:%S') [$f] $1 => $res" >> $l;
    [ "$f" = "fetch" ] && awk '{sub("^", "├ "); print}' "$1/.git/FETCH_HEAD" >> $l;
}

fetch() {
    local res=$(cd "$1" && git fetch -q --all && echo "true")
    log "$1" "$res"&
}

path_control() {
    local pass=0
    [[ $1 =~ $SKIP_PATHS ]] && pass=1;
    [[ $1 =~ $SCAN_PATHS ]] && pass=0;
    log "sep"
    log "$1" "$([ "$pass" = 0 ] && echo "true")"
    return "$pass"
}

path_is_repo() {
    local is_repo=$(cd "$1" && git rev-parse --is-inside-work-tree &>/dev/null && echo "true")
    log "$1" "$is_repo"
    [ -n "$is_repo" ]
}

# Check changed path
check_current() {
    path=$(pwd)
    path_control "$path" &&
    path_is_repo "$path" &&
    fetch "$path"
}

# Fetch current opened repositories
scan_paths() {
    tmux_panes_paths=$(tmux list-windows -F '#{pane_current_path}' | sort | uniq)
    for path in $tmux_panes_paths; do
        [ -d $path ] &&
        path_control "$path" &&
        path_is_repo "$path" &&
        fetch "$path"
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

