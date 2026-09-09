from xonsh.events import events
from xlsd.icons import STAT_ICONS, LS_ICONS
import rich

XLSD_EMOJIS = set(STAT_ICONS._icons.values()) | set(LS_ICONS._icons.values())


@events.on_transform_command
def _default_command_transform(cmd):
    """Run a default command when no command is given"""
    if not $PYTHON_MODE and (not cmd or cmd.strip() == ""):
        return defaultcmd()
    return cmd

@events.on_transform_command
def _source_activate_patch(cmd):
    """Use native venv activation, or import a POSIX script with source-bash."""
    from xontrib.rit_commands import activation_command
    return activation_command(cmd)

@events.on_transform_command
def _strip_emoji(cmd):
    """Strips leading emojis if present (used for onedrive)"""
    for emoji in XLSD_EMOJIS:
        if cmd.startswith(emoji):
            return cmd.removeprefix(emoji)
    return cmd

@events.on_postcommand
def _colorize_hex_codes(cmd: str, rtn: int, out: str or None, ts: list):
    """Colorizes color in terminal"""
    if out:
        color = out.strip()
        if color.startswith("#") and len(color) == 7:
            printf "\033[1A"  # move cursor one line up
            printf "\033[K"   # delete till end of line
            rich.print(
                rich.panel.Panel.fit(
                    f"[{color}]{color}[/{color}] "
                    f"[{color} on white]{color}[/{color} on white] "
                    f"[{color} on black]{color}[/{color} on black] ",
                    border_style=color
                )
            )

def defaultcmd():
    return "ls"
