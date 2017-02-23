from __future__ import print_function
import sys

from time import sleep
from sys import argv
from requests import post, get
from requests.auth import HTTPBasicAuth
from os import environ

from datetime import timedelta
from delorean import Delorean, now
import hashlib


def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)


class VultrAPI():
    """
    Using a VPS service is more stable than docker orchestration and easier to learn. Vultr seams to be the cheapest one.
    """
    def __init__(self, filename):
        """

        :param filename: of file that holds the API token
        """
        self.filename = filename
        self.url = 'https://api.vultr.com/v1'

    def vultr_post(self, endpoint, data):
        print(now())
        print(endpoint)
        result = None
        sleep(1) # the rate limit is 2 calls per second
        headers = {'api_key': open(self.filename).read().strip()}
        response = post(self.url+endpoint, params=headers, data=data, timeout=60)
        try:
            json_object = response.json()
        except ValueError, e:
            result = response
        else:
            result = response.json()
        return result

    def vultr_get(self, endpoint, data):
        print(now())
        print(endpoint)
        result = None
        sleep(1) # the rate limit is 2 calls per second
        data['api_key'] = open(self.filename).read().strip()
        try:
            response = get(self.url + endpoint, params=data)
        except:
            print("11111111111111")
            print(data)
            print("22222222222222")
            raise
        try:
            json_object = response.json()
        except:
            assert False, "HTTP status code %d and response text %s" % (response.status_code, response.text)
        else:
            result = json_object
        return result


class Script:
    scriptid = None

    def create(self, filename):
        v = VultrAPI('token')
        script = open('deploy/install_docker.sh').read()
        if filename!=None:
            script += open(filename).read()
        name = hashlib.md5(script).digest().encode("base64")
        response = v.vultr_get('/startupscript/list', {})
        if isinstance(response, list):
            scripts = response
        else:
            scripts = response.values()
        for startupscript in scripts:
            if startupscript['name'] == name:
                self.scriptid = startupscript['SCRIPTID']
                break
        if self.scriptid==None:
            data = {
                'name': name,
                'script': script
            }
            response = v.vultr_post('/startupscript/create', data)
            self.scriptid = response['SCRIPTID']
        return self.scriptid

    def destroy(self):
        v = VultrAPI('token')
        data = {
            'SCRIPTID': self.scriptid
        }
        response = v.vultr_post('/startupscript/destroy', data)


class Key:
    keyid = None
    def create(self, filename):
        v = VultrAPI('token')
        ssh_key = ''
        if filename!=None:
            with_email = open(filename).read().strip()
            words = with_email.split(' ')
            email = words[-1]
            if '@' in email:
                ssh_key = ' '.join(words[:-1])
            else:
                ssh_key = with_email
        name = hashlib.md5(ssh_key).digest().encode("base64")
        response = v.vultr_get('/sshkey/list', {}) # returns HTTP 200 locally but on travis it gets connection refused
        if isinstance(response, list):
            keys = response
        else:
            keys = response.values()
        for key in keys:
            if key['ssh_key'] == ssh_key:
                self.keyid = key['SSHKEYID']
                break
        if self.keyid==None:
            data = {
                'name': name,   # this is a minor security issue compared to the stdout in case of 404, so we first need private logging
                'ssh_key': ssh_key
            }
            response = v.vultr_post('/sshkey/create', data)
            self.keyid = response['SSHKEYID']
        return self.keyid
    def destroy(self):
        v = VultrAPI('token')
        data = {
            'SSHKEYID': self.keyid
        }
        response = v.vultr_post('/sshkey/destroy', data)


class Server:
    subid = None
    ip = None
    startuptime = None
    script = Script()
    key = Key()

    def __init__(self, mock):
        self.mock = mock

    def create(self, label, plan, datacenter, boot):
        """
        Creates a new vm at vultr. Usually it takes 2 minutes.
        :param label:
        :return: ip
        """
        self.label = label
        v = VultrAPI('token')
        keyid = self.key.create('key')
        scriptid = self.script.create(boot)
        data = {
            'DCID':      datacenter,             # data center at Frankfurt
            'VPSPLANID': plan,       # 768 MB RAM,15 GB SSD,1.00 TB BW
            'OSID':      215,           # virtualbox running ubuntu 16.04 x64
            'label':     label,        #
            'SSHKEYID':  keyid,
            'SCRIPTID':  scriptid       # at digitalocean this is called user_data and the format of the value is cloud-config
        }
        if label.startswith('test'):
            data['notify_activate'] = 'no'
        response = v.vultr_post('/server/create', data)
        self.startuptime = Delorean()
        if hasattr(response, 'text') and 'reached the maximum number of active virtual machines' in response.text:
            assert False, response.text
        self.subid = response['SUBID']

    def getip(self):
        v = VultrAPI('token')
        try:
            while True:
                if Delorean() - self.startuptime < timedelta(minutes=10):
                    srv = v.vultr_get('/server/list', {'SUBID': self.subid})
                    if srv['power_status'] == 'running' and srv['main_ip'] != '0' and srv['default_password'] != '':
                        self.ip = srv['main_ip']
                        break
                    eprint("Waiting for vultr to create " + self.label)
                    sleep(10)
                else:
                    assert False, "Failed to get status of new %s within 5 minutes" % self.label
        except:
            self.destroy()
            raise
        if self.ip==None:
            raise
        return self.ip

    def destroy(self):
        while True:
            if self.mock or not (Delorean() - self.startuptime < timedelta(minutes=5)):
                eprint(self.ip)
                eprint("1...")
                v = VultrAPI('token')
                eprint("2...")
                response = v.vultr_post('/server/destroy', {'SUBID': self.subid})
                eprint("3...")
                self.script.destroy()
                eprint("4...")
                self.key.destroy()
                break
            else:
                eprint("Waiting 5 minutes for vultr to allow destroying a fresh vm...")
                sleep(10)


