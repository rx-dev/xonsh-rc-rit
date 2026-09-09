from xontrib.rit_python_mode import toggle_python, record_command
from xonsh.events import events
aliases.register('toggle-python')(toggle_python)
events.on_postcommand(record_command)
