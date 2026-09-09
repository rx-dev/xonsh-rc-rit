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
