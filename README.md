# Rit's Xonsh RC

Xonsh and Python are managed by uv. zsh and xonsh share the basic environment in
`xontrib/environment.json`; neither activates pyenv or Rye. mise manages Node.

## Install

Clone this repo, then run from the checkout:

```sh
uv python install 3.14 --default
python3 scripts/install-shell.py
```

The installer exports exact dependency versions from `uv.lock` and constrains
`uv tool install` to those versions. Your rc remains editable; changes to its
source apply to new shells immediately. If the manifest and lock disagree, the
installer stops before changing the installed shell.

To add a permanent shell dependency:

```sh
uv add PACKAGE
python3 scripts/install-shell.py
```

To upgrade deliberately:

```sh
uv lock --upgrade
python3 scripts/install-shell.py
```

Use this installer instead of `uv tool upgrade xonsh` to preserve the lockfile.
Put `xontrib load rc_rit` in `~/.xonshrc`. Terminals should launch
`~/.local/bin/xonsh`. Use `uv run` / `uv add` for projects and `uv tool install`
for independent CLIs. Python itself is selected as 3.14, while the lockfile pins
Python package versions (not the interpreter patch release).

## zsh

Source this checkout's `shell/environment.zsh` from `~/.zshenv` and again from
`~/.zprofile` (macOS path_helper runs between them). Source
`shell/interactive.zsh` from `~/.zshrc`. Copy `shell/starship.toml` to
`~/.config/starship.toml`. Back up existing files before installing.

The PATH includes uv tools, Homebrew, PostgreSQL 17, curl, Cargo, Bun, pnpm,
Tally, Antigravity, and Obsidian when installed. The rc does not translate
`.secrets.xsh` into zsh; keep shell-neutral credentials in an appropriate local file.

## Prompt and startup

Starship keeps Git branch/commit information but disables worktree status and
metrics scans. Run `git status` when needed. The GitHub module reads the existing
username cache with `/bin/sh`; xonsh refreshes it after successful `gh auth`
changes, with a bounded request. Startup does not query GitHub.
Addons load synchronously in sorted order. Optional mise/zoxide/Starship binaries
are detected before initialization. Poetry/vox auto-activation has been removed.

## Development

```sh
uv sync --locked
uv run xonsh --no-rc -c 'xontrib load rc_rit'
uv build
```

## Everyday commands

- `source .venv/bin/activate`: the interactive hook uses `activate.xsh` when
  present, falling back to `source-bash` for older POSIX environments. Quoted
  paths with spaces work. `deactivate` restores the previous environment.
  In scripts, explicitly use `source .venv/bin/activate.xsh` or `source-bash`.
- `rename [--apply] [DIR] PATTERN REPLACEMENT`: preview basename regex changes;
  add `--apply` to execute. Rejects collisions, invalid filenames and symlinks.
  Example: `rename . '^draft-' 'final-'`. Applying uses exclusive hard links
  before unlinking sources; filesystems without hard-link support fail safely.
  A batch is not transactional: an unexpected I/O failure can leave earlier
  entries renamed. Existing destinations are never overwritten.
- `history-search -n 20 "O'Reilly"`: literal, case-insensitive history search
  using xonsh's history API, newest first. Quotes are not SQL.
- `todos [PATH ...]`: `rg` search for `TODO:`, respecting ignore files. Requires
  ripgrep (`brew install ripgrep`). No matches is a successful result.
- `pastel`: print a random pastel hex color.
- `tip`: another random usage reminder. One tip appears on interactive terminal
  startup. Disable it with `$RIT_SHOW_TIPS = False` in your local rc.

### req

HTTP GET, pretty JSON or plain response text:

```xsh
req https://httpbin.org/get
req --timeout 5 'https://httpbin.org/get?hello=world'
req --help
```

Quote URLs with shell punctuation. Default timeout is 10 seconds for connection
and read inactivity, not a total deadline. HTTP failures and network errors
return nonzero. No request occurs at startup. Requests is imported on first use.
The old project-specific `PROXY_URL` default has been removed.

### Python scratch mode

`toggle-python` stays inside xonsh, changes the prompt to `>>>`, and takes a
shallow snapshot of variable bindings. Run `exit` or `toggle-python` to restore
those bindings and the previous prompt. `$TOGGLE_PYTHON_LAST_SESSION` contains
commands from the session. There is no second Python process and no per-command
namespace scan. Python and shell syntax both still work.

Mutations to existing objects, environment variables, files and working directory
are not rolled back. This is a scratch convenience, not isolation. Use `exit`
rather than Ctrl-D to return; Ctrl-D retains normal shell behavior.

Directory-local `.dir_rc_enter.xsh` and `.dir_rc_exit.xsh` are no longer sourced.
Use explicit activation or `uv run` for project environments.
