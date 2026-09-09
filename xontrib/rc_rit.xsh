"""
Awesome snippets of code to make your awesome xonsh RC.
Source: https://github.com/anki-code/xontrib-rc-awesome
If you like the idea click ⭐ on the repo and stay tuned.
"""

from .utils import yieldify, aliasify

@yieldify
def main():
    # print("Loading .xonshrc")

    from pathlib import Path
    import httpx

    import rich

    yield "imports"

    import sys
    import warnings
    from xontrib.environment import configure
    configure(__xonsh__.env)

    yield "path"

    # https://github.com/prompt-toolkit/python-prompt-toolkit/issues/1696
    __import__('warnings').filterwarnings(
        'ignore', 'There is no current event loop', DeprecationWarning, 'prompt_toolkit')

    yield "filterwarning"

    # Xontribs - https://github.com/topics/xontrib
    # print("  xontribs:")
    for _xontrib in (
        # Command abbreviations for auto-complete
        "abbrevs",

        # enable some bash stuff, !! to rerun last cmd for example
        "bashisms",

        # cd is now cd! aka bash compliant
        "cd",

        # python auto-complete
        "jedi",

        # lazily load python modules
        # https://github.com/agoose77/xontrib-mod
        "mod",

        # allows u to "double-click" stuff, open files, navigate, pandas read
        "onepath",

        # build in debugger w/ xonsh?
        "pdb",

        # start with ! to run copy and pasted shell cmds
        "sh",

        # jump between words, same keyboard shortcut as ide's
        "whole_word_jumping",

        # fancy af `ls` cmd
        "xlsd",

    ):
        # xlsd 0.1.7 imports a deprecated compatibility re-export. Both
        # modules expose the same lazyobject; silence only this known warning
        # while loading xlsd, leaving other startup warnings visible.
        with warnings.catch_warnings():
            if _xontrib == "xlsd":
                warnings.filterwarnings(
                    "ignore",
                    message=r"^Use `xonsh\.lib\.lazyasd` instead of `xonsh\.lazyasd`\.$",
                    category=DeprecationWarning,
                    module=r"^xontrib\.xlsd$",
                )
            xontrib load @(_xontrib)
        yield f"  loading {_xontrib}"

    $PROMPT_FIELDS['prompt_end'] = '@'

    # Do not write the command to the history if it was ended by `###`
    $XONSH_HISTORY_IGNORE_REGEX = '.*(\\#\\#\\#\\s*)$'

    # Remove front dot in multiline input to make the code copy-pastable.
    $MULTILINE_PROMPT = ' '

    # Suppress line "xonsh: For full traceback set: $XONSH_SHOW_TRACEBACK = True"
    # in case of exceptions or wrong command.
    $XONSH_SHOW_TRACEBACK = False

    # Suppress line "Did you mean one of the following?"
    $SUGGEST_COMMANDS = False

    # Flag for automatically pushing directories onto the directory stack
    #  i.e. `dirs -p` (https://xon.sh/aliases.html#dirs).
    $AUTO_PUSHD = True

    $XONTRIB_CD_LONG_DURATION = 5  # default

    # defaults
    $PYTHON_MODE = False
    $LAST_DIR = []
    $RUNNING_BACK = False

    # iPython
    # $PYTHONBREAKPOINT = 'IPython.core.debugger.set_trace'

    # Use sqlite for history and ignore duplicate commands
    $XONSH_HISTORY_BACKEND = 'sqlite'
    $HISTCONTROL = 'ignoredups'

    $ENABLE_ASYNC_PROMPT = True
    if sys.stdin.isatty():
        $GPG_TTY = $(tty).strip()

    yield "envs"

    if (path := Path.home() / '.secrets.xsh').exists():
        source @(path.resolve())

    yield "secrets"

    # Adding aliases from dict
    global aliases
    aliases |= {
        '-': 'cd -',
        '..': 'cd ..',
        '....': 'cd ../..',

        # List all files, including hidden entries.
        'll': 'ls -lAh',

        # Make directory and cd into it.
        # Example: md /tmp/my/awesome/dir/will/be/here
        'md': 'mkdir -p $arg0 && cd $arg0',

        # fast to gpt4
        'mod4': 'mods -m 4',

        # Grepping string occurrences recursively starting from current directory.
        # Example: cd ~/git/xonsh && greps environ
        'greps': 'grep -ri',

        # `grep` with color output.
        # This is distinct alias to keep output clean in case `var = $(echo 123 | grep 12)`
        'grepc': 'grep --color=always',

        # SSH: Suppress "Connection close" message.
        'ssh': 'ssh -o LogLevel=QUIET',

        # Run http server in the current directory.
        'http-here': 'python3 -m http.server',

        # history search macro
        'history-search': """sqlite3 $XONSH_HISTORY_FILE @("SELECT inp FROM xonsh_history WHERE inp LIKE '%" + $arg0 + "%' AND inp NOT LIKE 'history-%' ORDER BY tsb DESC LIMIT 10");""",

        # vscode
        'code': 'open -a "Visual Studio Code"',
        'work-code': 'open -a "Visual Studio Code - Insiders"',

        # reconfig xonsh
        'config': 'code ~/Life/Things/MC2/dev/xonsh-rc',

        # yoink
        'yoink': 'open -a Yoink',

        # cat bat
        'batdiff': 'git diff --name-only --relative --diff-filter=d | xargs bat --diff',

        # poe the poet
        'poe': 'uv run poe',

        # quick access to the python of xonsh for hunter, etc
        'xpython': [sys.executable],

        # with auto-pushd, this is easy
        "back": "popd > /dev/null",

        # weather
        "weather": "curl wttr.in",

        # shortcut to query, useful for piping
        "zq": "zoxide query",

        # alt zip
        "zipp": "zip",

        # quick ssh
        "ssh-summit-build": "ssh ubuntu@hytale.smithed.net",
        "ssh-summit-prod": "ssh debian@40.160.20.122",
        "ssh-summit-prod2": "ssh debian@40.160.20.53",
    }

    yield "aliases"

    addons = Path(__file__).parent / "addons"
    for file in sorted(addons.glob("*.xsh")):
        source @(file.resolve())
        yield f"  addon [{file.stem}]"

    yield "all addons"
