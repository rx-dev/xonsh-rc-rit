import io
from pathlib import Path
import tempfile
import unittest
from unittest.mock import Mock, patch
from xontrib import rit_commands as c

class Commands(unittest.TestCase):
    def test_rename(self):
        with tempfile.TemporaryDirectory() as tmp:
            p=Path(tmp); (p/'old-a').write_text('one'); (p/'old-b').write_text('two'); out=io.StringIO()
            self.assertEqual(c.rename([tmp,'^old-','new-'],stdout=out),0)
            self.assertTrue((p/'old-a').exists())
            (p/'new-b').write_text('existing')
            self.assertEqual(c.rename(['--apply',tmp,'^old-','new-'],stdout=out,stderr=out),1)
            self.assertTrue((p/'old-a').exists()); self.assertEqual((p/'new-b').read_text(),'existing')
            (p/'new-b').unlink()
            self.assertEqual(c.rename(['--apply',tmp,'^old-','new-'],stdout=out),0)
            self.assertEqual((p/'new-a').read_text(),'one')
            self.assertEqual(c.rename(['--apply',tmp,'.*','../oops'],stdout=out,stderr=out),1)
    def test_duplicate(self):
        with tempfile.TemporaryDirectory() as tmp:
            p=Path(tmp);(p/'a').touch();(p/'b').touch()
            self.assertEqual(c.rename(['--apply',tmp,'[ab]','c'],stderr=io.StringIO()),1)
            self.assertTrue((p/'a').exists())
    def test_history(self):
        hist=Mock();hist.all_items.return_value=iter([{'inp':"echo O'Reilly"},{'inp':'other'}]);out=io.StringIO()
        with patch.object(c.XSH,'history',hist): c.history_search(["O'Reilly"],stdout=out)
        self.assertEqual(out.getvalue(),"echo O'Reilly\n")
    def test_req(self):
        import requests
        result=Mock();result.json.return_value={'ok':True};out=io.StringIO()
        with patch('requests.get',return_value=result) as get:
            self.assertEqual(c.req(['--timeout','2','https://example.com'],stdout=out),0)
            get.assert_called_once_with('https://example.com',timeout=2)
        with patch('requests.get',side_effect=requests.Timeout('timeout')):
            self.assertEqual(c.req(['https://example.com'],stderr=out),1)
        result.raise_for_status.side_effect=requests.HTTPError('404')
        with patch('requests.get',return_value=result): self.assertEqual(c.req(['https://example.com'],stderr=out),1)
    def test_activation(self):
        with tempfile.TemporaryDirectory(prefix='venv space ') as tmp:
            p=Path(tmp)/'bin';p.mkdir();(p/'activate').touch();cmd=f'source {str(p/"activate")!r}\n'
            self.assertTrue(c.activation_command(cmd).startswith('source-bash '))
            (p/'activate.xsh').touch()
            self.assertTrue(c.activation_command(cmd).endswith("activate.xsh'\n"))
            compound=cmd.rstrip()+' && echo hello\n';self.assertEqual(c.activation_command(compound),compound)

    def test_todos_ignores(self):
        import subprocess
        with tempfile.TemporaryDirectory() as tmp:
            p=Path(tmp);subprocess.run(['git','init','-q',tmp],check=True)
            (p/'.gitignore').write_text('ignored/\n');(p/'ignored').mkdir()
            (p/'ignored'/'big.txt').write_text('TODO: hidden\n');(p/'yes.txt').write_text('TODO: visible\n')
            out=io.StringIO()
            with patch.object(c.XSH,'env',Mock(detype=lambda:dict(__import__('os').environ))):
                self.assertEqual(c.todos([tmp],stdout=out),0)
            self.assertIn('visible',out.getvalue());self.assertNotIn('hidden',out.getvalue())
    def test_python_mode(self):
        from xontrib import rit_python_mode as pm
        ctx={'existing':5};env={'PROMPT':'old','RIGHT_PROMPT':'right','MULTILINE_PROMPT':'more','XONSH_SHOW_TRACEBACK':False};aliases={'exit':object()}
        with patch.object(pm, 'XSH', Mock(ctx=ctx, env=env, aliases=aliases)):
            pm.toggle_python();ctx['existing']=6;ctx['new']=7;pm.record_command('1+1');pm.toggle_python()
            self.assertEqual(ctx,{'existing':5});self.assertEqual(env['PROMPT'],'old')
            self.assertEqual(env['TOGGLE_PYTHON_LAST_SESSION'],'1+1')
            pm.toggle_python();pm.toggle_python();self.assertEqual(env['TOGGLE_PYTHON_LAST_SESSION'],'')

unittest.main()
