# from xontrib.utils import aliasify

# @aliasify
# def back():
#     dir = $(popd)

#     print(dir)

#     if dir:
#         $FORWARD_DIR_STACK.append(dir)

# @aliasify
# def forward():
#     import rich

#     value = $FORWARD_DIR_STACK.pop()

#     if value:
#         cd @(value)
#     else:
#         rich.print('[red]Nowhere to go forward')
