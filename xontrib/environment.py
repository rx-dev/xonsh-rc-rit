"""Shared environment data; shell-specific integrations remain interactive."""
import json
from pathlib import Path


def configure(env):
    config = json.loads(Path(__file__).with_name('environment.json').read_text())
    for key, value in config['variables'].items():
        env[key] = str(Path(value).expanduser()) if value.startswith('~') else value
    stale = (str(Path.home() / '.pyenv'), str(Path.home() / '.rye/shims'))
    inherited = [str(p) for p in env['PATH'] if not any(str(p) == s or str(p).startswith(s + '/') for s in stale)]
    preferred = [str(Path(p).expanduser()) for p in config['paths'] if Path(p).expanduser().is_dir()]
    env['PATH'] = list(dict.fromkeys(preferred + inherited))
    for key in ('PYENV_ROOT', 'PYENV_VERSION', 'PYENV_SHELL', 'PIPX_DEFAULT_PYTHON'):
        env.pop(key, None)
