import shutil
if shutil.which('mise'):
    execx($(mise activate xonsh), 'exec', __xonsh__.ctx, filename='mise')
