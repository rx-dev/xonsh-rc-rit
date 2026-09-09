"""Install the editable rc and xonsh using exact dependency versions in uv.lock.

Run: python3 scripts/install-shell.py
Update deliberately: uv lock --upgrade; python3 scripts/install-shell.py
"""
from pathlib import Path
import subprocess
import tempfile

repo = Path(__file__).resolve().parent.parent
with tempfile.TemporaryDirectory(prefix='xonsh-lock-') as temp:
    constraints = Path(temp) / 'constraints.txt'
    subprocess.run(['uv', 'export', '--locked', '--no-dev', '--no-emit-project',
                    '--no-hashes', '--output-file', str(constraints)], cwd=repo, check=True, stdout=subprocess.DEVNULL)
    subprocess.run(['uv', 'tool', 'install', '--force', '--reinstall', '--python', '3.14',
                    '--constraints', str(constraints), '--with-editable', str(repo),
                    'xonsh[full]'], cwd=repo, check=True)
