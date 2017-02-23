from behave4cmd0.command_steps import *

from mock import MagicMock, patch
import responses
import re


def mock_sync(uri, httpType=responses.POST, body="{}"):
    url_re = re.compile(".*" + uri + ".*")
    responses.add(httpType, url_re, body=body, content_type="application/json")


def mock_vultr():
    mock_sync('https://api.vultr.com/v1/startupscript/list', responses.GET)
    mock_sync('https://api.vultr.com/v1/startupscript/create', body='{"SCRIPTID":1}')
    mock_sync('https://api.vultr.com/v1/startupscript/destroy')
    body = '{"power_status": "running", "main_ip":"8.8.8.8", "default_password": "nosorandom"}'
    mock_sync('https://api.vultr.com/v1/server/list', responses.GET, body=body)
    mock_sync('https://api.vultr.com/v1/server/create', body='{"SUBID":1}')
    mock_sync('https://api.vultr.com/v1/server/destroy')
    mock_sync('https://api.vultr.com/v1/sshkey/list', responses.GET)
    mock_sync('https://api.vultr.com/v1/sshkey/create', body='{"SSHKEYID":1}')

def before_all(context):
    context.patches = []
    context.patches.append(patch('lib.ssh2vm.SSH2VM', MagicMock()))
    mock_vultr()
    context.patches.append(responses)
    for p in context.patches:
        p.start()


def after_all(context):
    for p in context.patches:
        p.stop()
