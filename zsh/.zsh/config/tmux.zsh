_not_inside_tmux() {
  [[ -z "$TMUX" ]]
}

ensure_tmux_is_running() {
  if _not_inside_tmux; then
    tat
  fi
}

# Fuzzy tmux session switcher. `tm` to pick from list, `tm name` to jump/create.
tm() {
  local session="${1:-$(tmux list-sessions -F '#{session_name}' 2>/dev/null \
    | fzf --prompt='session: ' --reverse --height=~10)}"
  [[ -z "$session" ]] && return
  tat "$session"
}
