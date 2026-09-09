# Generated from xontrib/environment.json. Keep PATH entries in sync.
typeset -U path PATH
path=( ${path:#$HOME/.pyenv(|/*)} )
path=( ${path:#$HOME/.rye/shims} )
unset PYENV_ROOT PYENV_VERSION PYENV_SHELL PIPX_DEFAULT_PYTHON
export BUN_INSTALL="$HOME/.bun"
export PNPM_HOME="$HOME/Library/pnpm"
export UV_PYTHON_PREFERENCE="only-managed"
typeset -a _rit_paths
_rit_paths=(
  "$HOME/.local/bin"
  "/opt/homebrew/bin"
  "/opt/homebrew/sbin"
  "/opt/homebrew/opt/postgresql@17/bin"
  "/opt/homebrew/opt/curl/bin"
  "$HOME/.cargo/bin"
  "$HOME/.bun/bin"
  "$HOME/Library/pnpm"
  "$HOME/.tally/bin"
  "$HOME/.antigravity/antigravity/bin"
  "/usr/local/bin"
  "/Applications/Obsidian.app/Contents/MacOS"
)
for (( _rit_i=${#_rit_paths}; _rit_i>=1; _rit_i-- )); do
  [[ -d "${_rit_paths[_rit_i]}" ]] && path=( "${_rit_paths[_rit_i]}" $path )
done
unset _rit_paths _rit_i
export PATH
