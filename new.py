from requests import get

params = {'api_key':open('token').read().strip()}

result = get('https://api.vultr.com/v1/sshkey/list', params=params)

print(result.json())

