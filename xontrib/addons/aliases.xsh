from xontrib.utils import yieldify, aliasify

@yieldify
def main():
    import math
    import rich
    from pathlib import Path
    from rich.console import Console
    from prompt_toolkit import prompt


    @aliasify
    def prune(args):
        d = args[0]
        console = Console()
        paths = list(Path(d).glob('**/.DS_Store'))

        if ((num := len(paths)) > 0):

            ans = ![gum confirm f"Are you sure you want to prune {num} files in the '{d}' folder?"]

            if not ans.rtn:
                for path in paths:
                    rich.print(f'[green] {path} [red] deleted')
                    path.unlink()
            else:
                rich.print('[red] Canceled')
        else:
            rich.print('[green] No .DS_Store to worry about [bold]:)')


    from xontrib.rit_commands import rename, todos, history_search
    aliases.register('rename')(rename)
    aliases.register('todos')(todos)
    aliases.register('history-search')(history_search)

    @aliasify
    def snbt():
        import nbtlib
        s = prompt('type raw snbt > ')
        print(nbtlib.serialize_tag(nbtlib.parse_nbt(s), indent=2))


    def generate_pastel_color():
        """Generate a random pastel color as a hex string."""
        # Generate random RGB values within the range (128, 256)
        import random
        r = random.randint(128, 255)
        g = random.randint(128, 255)
        b = random.randint(128, 255)

        # Convert RGB to hex string
        hex_color = '#{:02x}{:02x}{:02x}'.format(r, g, b)

        return hex_color

    @aliasify
    def pastel():
        print(generate_pastel_color())
        return 0

    @aliasify
    def gradient(args):
        from colour import Color
        from rich.console import Console
        from rich.text import Text

        from itertools import chain

        text, color1, color2 = args

        console = Console()
        color_1, color_2 = Color(color1), Color(color2)

        first_half = color_1.range_to(color2, math.floor(len(text) / 2))
        second_half = color_2.range_to(color1, math.ceil(len(text) / 2))

        console.print(
            Text.assemble(
                *(
                    (letter, color.hex_l)
                    for letter, color in zip(text, chain(first_half, second_half))
                )
            )
        )
