from xontrib.utils import yieldify, aliasify

@yieldify
def main():
    from rich.table import Table
    from rich.console import Console
    from rich.color import Color
    from rich.style import Style
    from rich.markdown import Markdown
    from rich import box

    yield "  imports"


    @aliasify
    def cdls(args):
        cd @(args[0])
        if len(list(filter(lambda x: not str(x).startswith('.'), p'.'.glob('*')))) < 100:
            ls -a

    def pretty_pandas(df, args=None):
        import pandas as pd

        col_length = len(df.columns)
        row_length = len(df)

        table = Table(
            title=args[0] if args is not None else '<from python>', box=box.ROUNDED,
            title_style='italic grey62',
            border_style='light_slate_grey',
            header_style='bold grey82',

            caption=f'[{row_length} rows x {col_length} columns]',
            footer_style='italic grey62',
        )

        if col_length > 8:
            for col in df.columns[:4]:
                style = Style.from_color(Color.from_rgb(*_randcolor()))
                table.add_column(col, justify='right', style=style)
            table.add_column('...', justify='center', style=style.combine([Style(bold=True)]))
            for col in df.columns[-4:]:
                style = Style.from_color(Color.from_rgb(*_randcolor()))
                table.add_column(col, justify='right', style=style)
            col_length = 9

        else:
            for col in df.columns:
                style = Style.from_color(Color.from_rgb(*_randcolor()))
                table.add_column(col, justify='right', style=style)

        def handle(values):
            for val in values:
                if type(val) is float:
                    yield str(round(val, 2))
                elif type(val) is int:
                    yield str(val)
                else:
                    yield str(val)

        if row_length > 30:
            df[:15].apply(lambda r: table.add_row(*handle(r)), axis=1)
            dots = ['...'] * col_length
            table.add_row(*dots)
            df[row_length-15:].apply(lambda r: table.add_row(*handle(r)), axis=1)
        else:
            df.apply(lambda r: table.add_row(*handle(r)), axis=1)

        console = Console()
        console.print(table)


    @aliasify
    def view_csv_with_pandas(args):
        import pandas as pd
        pretty_pandas(pd.read_csv(args[0]), args)

    globals()['pretty_pandas'] = pretty_pandas

    $XONTRIB_ONEPATH_ACTIONS['text/'] = 'nano'
    $XONTRIB_ONEPATH_ACTIONS['<DIR>'] = 'cdls'
    $XONTRIB_ONEPATH_ACTIONS['application/csv'] = 'view_csv_with_pandas'
    $XONTRIB_ONEPATH_ACTIONS |= {'*.md': 'bat'}
