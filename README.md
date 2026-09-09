# Rit's Xonsh RC

Xonsh and Python are managed by uv. zsh and xonsh share the basic environment in
`xontrib/environment.json`; neither activates pyenv or Rye. mise manages Node.

## Install

```sh
uv python install 3.14 --default
uv tool install --python 3.14 --with-editable . 'xonsh[full]'
```

For a remote install:

```sh
uv tool install --python 3.14 --with 'git+https://github.com/RitikShah/xonsh-rc-rit' 'xonsh[full]'
```

Put `xontrib load rc_rit` in `~/.xonshrc`. Keep terminals pointing at
`~/.local/bin/xonsh`. Run `uv tool upgrade xonsh` for upgrades.
Use `uv run`, `uv add`, and `uv sync` for projects, and `uv tool install` for CLIs.
The shell's isolated environment and project venvs use uv-managed Python;
macOS/Homebrew-owned Python installations do not need to be removed.

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

Personal addons remain available. The directory event addon can source
`.dir_rc_enter.xsh` / `.dir_rc_exit.xsh` when navigating parent/child directories:
these files execute code, so only use that feature in trusted checkouts.
