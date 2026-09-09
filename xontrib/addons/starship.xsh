from pathlib import Path
import subprocess
import shutil
from xonsh.events import events

@aliasify
def github_user_name():
    if not shutil.which('gh'):
        return ''
    try:
        result = subprocess.run(['gh', 'api', 'user', '--jq', '.login'], capture_output=True, text=True, timeout=3)
        return result.stdout.strip() if result.returncode == 0 else ''
    except (OSError, subprocess.TimeoutExpired):
        return ''

@events.on_postcommand
def update_github_user_name(cmd, rtn, **kwargs):
    if rtn == 0 and cmd.strip().startswith(('gh auth switch', 'gh auth login', 'gh auth logout')):
        cache = Path.home() / '.config/xonsh/GITHUB_USER'
        cache.parent.mkdir(parents=True, exist_ok=True)
        cache.write_text(github_user_name() + '\n')

if shutil.which('starship'):
    execx($(starship init xonsh), 'exec', __xonsh__.ctx, filename='starship')
