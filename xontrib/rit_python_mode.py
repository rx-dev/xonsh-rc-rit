"""A lightweight scratch namespace inside the same xonsh process."""
from xonsh.built_ins import XSH

_state = None
_commands = []


def toggle_python(args=None):
    """Toggle an in-process xonsh scratch session; exit returns to your prompt.

    Restores variable bindings and prompt settings, not mutations to existing
    objects, the filesystem, working directory, or environment variables.
    """
    global _state
    if _state is None:
        _state = {
            'ctx': dict(XSH.ctx),
            'env': {key: XSH.env[key] for key in ('PROMPT', 'RIGHT_PROMPT', 'MULTILINE_PROMPT', 'XONSH_SHOW_TRACEBACK')},
            'exit': XSH.aliases['exit'],
        }
        _commands.clear()
        XSH.env.update(PYTHON_MODE=True, PROMPT='>>> ', RIGHT_PROMPT='', MULTILINE_PROMPT='... ', XONSH_SHOW_TRACEBACK=True)
        XSH.aliases['exit'] = toggle_python
        print('Python scratch mode (still xonsh). exit restores bindings; object mutations persist.')
    else:
        state = _state
        _state = None
        for key in set(XSH.ctx) - set(state['ctx']):
            XSH.ctx.pop(key, None)
        XSH.ctx.update(state['ctx'])
        XSH.env.update(state['env'])
        XSH.env['PYTHON_MODE'] = False
        XSH.env['TOGGLE_PYTHON_LAST_SESSION'] = '\n'.join(_commands)
        XSH.aliases['exit'] = state['exit']
        print('Back to shell. Scratch commands: $TOGGLE_PYTHON_LAST_SESSION')
    return 0


def record_command(cmd, **kwargs):
    if _state is not None and cmd.strip() not in ('toggle-python', 'exit'):
        _commands.append(cmd.rstrip())


toggle_python.__xonsh_threadable__ = False
