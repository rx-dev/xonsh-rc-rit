import sys
from xonsh.events import events

_RIT_TIPS = (
    "req --help: HTTP GET, pretty JSON, --timeout 10 (seconds).",
    "rename . '^old-' 'new-' previews names; add --apply after reviewing.",
    "todos [folder] finds TODO: with ripgrep and respects .gitignore.",
    "history-search -n 20 'some text' searches saved commands literally.",
    "toggle-python starts a scratch session; exit restores variable bindings.",
    "source .venv/bin/activate works here; deactivate leaves the venv.",
    "@.imp.json.loads(text) imports json only when you use it.",
    "data = $(@json gh repo list --json name) captures JSON as Python objects.",
    "uv run python uses a project's environment without activation.",
    "pastel prints a random pastel hex color. tip shows another reminder.",
)

@aliasify('tip')
def _tip():
    """Show a random shell tip. Disable startup tips with $RIT_SHOW_TIPS = False."""
    import random
    from rich.console import Console
    from rich.text import Text
    color = '#{:02x}{:02x}{:02x}'.format(*(random.randint(160, 255) for _ in range(3)))
    message = Text('Tip: ', style='bold ' + color)
    message.append(random.choice(_RIT_TIPS), style=color)
    Console().print(message)

@events.on_post_init
def _rit_startup_tip(**kwargs):
    if $XONSH_INTERACTIVE and sys.stdin.isatty() and @.env.get('RIT_SHOW_TIPS', True):
        _tip()
