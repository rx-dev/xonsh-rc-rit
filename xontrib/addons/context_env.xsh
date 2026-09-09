from contextlib import contextmanager
from xonsh.built_ins import XSH

@contextmanager
def context_env(name: str):
    missing = object()
    old_value = XSH.env.get(name, missing)
    try:
        yield
    finally:
        if old_value is missing:
            XSH.env.pop(name, None)
        else:
            XSH.env[name] = old_value
