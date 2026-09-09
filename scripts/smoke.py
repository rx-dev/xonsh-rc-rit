"""Load the installed rc without user secrets or optional external integrations."""
import os
from pathlib import Path
import subprocess
import sys
import tempfile

with tempfile.TemporaryDirectory() as home:
    env = dict(os.environ, HOME=home, PATH=str(Path(sys.executable).parent) + ':/usr/bin:/bin', XONSH_AUTOCOMPLETIONS_CACHE='False')
    result = subprocess.run([sys.executable, '-m', 'xonsh', '--no-rc', '-c',
        'xontrib load rc_rit; assert "xpython" in aliases; assert "snbt" in aliases; print("RC_OK")'],
        env=env, capture_output=True, text=True)
    print(result.stdout)
    print(result.stderr, file=sys.stderr)
    assert result.returncode == 0 and 'RC_OK' in result.stdout
    assert 'Traceback' not in result.stderr and 'Failed to load' not in result.stderr
    assert "DeprecationWarning" not in result.stderr

# Render both prompts too: merely loading the rc misses pipeline/alias errors.
import shutil
if shutil.which('starship'):
    env = dict(os.environ, TERM='xterm-256color')
    result = subprocess.run([sys.executable, '-m', 'xonsh', '--no-rc', '-i', '-c',
        'xontrib load rc_rit; assert callable($PROMPT); assert isinstance($PROMPT(), str); assert isinstance($RIGHT_PROMPT(), str); print("PROMPT_OK")'],
        env=env, capture_output=True, text=True)
    assert result.returncode == 0 and 'PROMPT_OK' in result.stdout, result.stderr
    assert 'Traceback' not in result.stderr and 'DeprecationWarning' not in result.stderr, result.stderr
