from xonsh.built_ins import XSH


def yieldify(func):
    """Execute a generator-based startup block synchronously."""
    result = func()
    if result is not None:
        for _ in result:
            pass
    return func


def aliasify(name_or_func):
    if isinstance(name_or_func, str):
        return XSH.aliases.register(name_or_func)
    XSH.aliases.register(name_or_func.__name__)(name_or_func)
    return name_or_func
