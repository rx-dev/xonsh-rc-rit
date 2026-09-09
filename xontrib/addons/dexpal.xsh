from xontrib.utils import aliasify
import rich

dydx = "https://w64q6egbyo2e5rkiw4f3m7nxni0clnzs.lambda-url.eu-west-1.on.aws"
dexpal = "http://localhost:9000/lambda-url/lambda/default/v1/dexpal"

$PROXY_URL = dydx

from requests import get

@aliasify
def req(args):
    url = args[0]
    resp = get(url)
    try:
        rich.print(resp.json())
    except:
        rich.print(resp.content)
