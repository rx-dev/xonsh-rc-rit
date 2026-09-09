import shutil
if shutil.which('zoxide'):
    execx($(zoxide init xonsh), 'exec', __xonsh__.ctx, filename='zoxide')
