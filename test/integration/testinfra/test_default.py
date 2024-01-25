import os

import testinfra.utils.ansible_runner

print(os.environ['MOLECULE_INVENTORY_FILE'])
testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    os.environ['MOLECULE_INVENTORY_FILE']).get_hosts('all')


def test_httpd_is_running_and_enabled(host):
    httpd = host.service("httpd")
    assert httpd.is_running
    assert httpd.is_enabled
