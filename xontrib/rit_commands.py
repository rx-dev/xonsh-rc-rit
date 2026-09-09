"""Small shell commands; expensive dependencies are imported when invoked."""
import argparse
import os
from pathlib import Path
import re
import sys
from xonsh.built_ins import XSH


def rename(args, stdout=None, stderr=None):
    """Preview regex filename changes: rename [--apply] [DIR] PATTERN REPLACEMENT.

    Only regular files in DIR are considered. Patterns match basenames, not paths.
    Changes are previewed by default. --apply refuses existing destinations,
    duplicate targets, symlinks and directory traversal. Backreferences work.
    Example: rename --apply . '^draft-' 'final-'
    """
    parser = argparse.ArgumentParser(prog='rename', description=rename.__doc__)
    parser.add_argument('--apply', action='store_true')
    parser.add_argument('values', nargs='+')
    opts = parser.parse_args(args)
    if len(opts.values) not in (2, 3):
        parser.error('expected [DIR] PATTERN REPLACEMENT')
    folder, pattern, replacement = (['.'] + opts.values if len(opts.values) == 2 else opts.values)
    try:
        regex = re.compile(pattern)
        plan = []
        targets = set()
        for src in sorted(Path(folder).iterdir()):
            if src.is_symlink() or not src.is_file():
                continue
            name = regex.sub(replacement, src.name)
            if name == src.name:
                continue
            if name in ('', '.', '..') or '/' in name or '\\' in name or '\x00' in name:
                raise ValueError(f'invalid destination filename: {name!r}')
            dst = src.with_name(name)
            # Conservative on case-insensitive macOS volumes.
            key = str(dst).casefold()
            if key in targets or os.path.lexists(dst):
                raise ValueError(f'destination collision: {dst}')
            targets.add(key)
            plan.append((src, dst))
        for src, dst in plan:
            print(f'{src} -> {dst}', file=stdout)
        if not opts.apply:
            print(f'{len(plan)} change(s); add --apply to rename.', file=stdout)
            return 0
        for src, dst in plan:
            # Exclusive hard-link creation cannot overwrite a file appearing
            # after the preview. Unlink the source only after the link succeeds.
            os.link(src, dst, follow_symlinks=False)
            src.unlink()
        return 0
    except (OSError, ValueError, re.error) as exc:
        print(f'rename: {exc}', file=stderr or sys.stderr)
        return 1


def todos(args, stdout=None, stderr=None):
    """Search TODO: with ripgrep, respecting .gitignore: todos [PATH ...]."""
    import subprocess
    try:
        result = subprocess.run(['rg', '--line-number', '--heading', '--color=auto', '--fixed-strings', 'TODO:', '--', *(args or ['.'])],
                                env=XSH.env.detype(), capture_output=True, text=True)
    except FileNotFoundError:
        print('todos: install ripgrep with brew install ripgrep', file=stderr or sys.stderr)
        return 127
    print(result.stdout, end='', file=stdout)
    print(result.stderr, end='', file=stderr or sys.stderr)
    return 0 if result.returncode in (0, 1) else result.returncode


def history_search(args, stdout=None, stderr=None):
    """Search literal text in history: history-search [-n LIMIT] TEXT."""
    parser = argparse.ArgumentParser(prog='history-search', description=history_search.__doc__)
    parser.add_argument('-n', '--limit', type=int, default=10)
    parser.add_argument('text', nargs='+')
    opts = parser.parse_args(args)
    if opts.limit < 1:
        parser.error('limit must be positive')
    if XSH.history is None:
        print('history-search: no history available', file=stderr or sys.stderr)
        return 1
    needle = ' '.join(opts.text).casefold()
    count = 0
    for item in XSH.history.all_items(newest_first=True):
        line = item['inp']
        if needle in line.casefold() and not line.lstrip().startswith('history-search'):
            print(line, file=stdout)
            count += 1
            if count >= opts.limit:
                break
    return 0


def req(args, stdout=None, stderr=None):
    """HTTP GET with pretty JSON: req [--timeout SECONDS] URL.

    req https://httpbin.org/get
    req --timeout 5 'https://httpbin.org/get?hello=world'
    Quote URLs containing &, ? or spaces. The timeout (default 10 seconds) is
    requests' connect/read inactivity timeout, not a total wall-clock deadline.
    JSON is pretty-printed; other responses are printed as text. HTTP errors
    and connection failures return status 1. GET only; no implicit proxy URL.
    """
    parser = argparse.ArgumentParser(prog='req', description=req.__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('--timeout', type=float, default=10)
    parser.add_argument('url')
    opts = parser.parse_args(args)
    if not 0 < opts.timeout < float('inf'):
        parser.error('timeout must be a finite positive number')
    if not opts.url.startswith(('http://', 'https://')):
        parser.error('URL must start with http:// or https://')
    import requests
    import json
    try:
        response = requests.get(opts.url, timeout=opts.timeout)
        response.raise_for_status()
        try:
            print(json.dumps(response.json(), indent=2, ensure_ascii=False), file=stdout)
        except ValueError:
            print(response.text, file=stdout)
        return 0
    except requests.RequestException as exc:
        print(f'req: {exc}', file=stderr or sys.stderr)
        return 1


def activation_command(cmd):
    """Translate a single POSIX activation command, preserving other commands."""
    import shlex
    if not cmd.lstrip().startswith(('source ', '. ')):
        return cmd
    try:
        words = shlex.split(cmd, comments=True)
    except ValueError:
        return cmd
    if len(words) != 2 or words[0] not in ('source', '.'):
        return cmd
    path = Path(os.path.expandvars(os.path.expanduser(words[1])))
    if path.name != 'activate' or path.parent.name != 'bin' or not path.is_file():
        return cmd
    native = path.with_name('activate.xsh')
    if native.is_file():
        return f'source {str(native)!r}\n'
    return f'source-bash {str(path)!r}\n'
