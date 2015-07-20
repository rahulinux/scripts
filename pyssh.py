#!/usr/bin/env python

# modules required
# paramiko


import os
import socket
import sys
from paramiko import AutoAddPolicy, SSHClient

remote_server = 'xx.xx.xx'
remote_user = 'root'
password = 'secret'

def test_connection(host,port=22):
    try:
         sys.stdout.write("Testing SSH Connection...  ")
         sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
         sock.connect((host,port))
         print "[ success ]"
    except Exception as e:
         print "Connection failed " + str(e)
         SystemExit(1)

def auth(host,username,password):
    global client
    sys.stdout.write("Login ===>> %s  " % (host))
    client = SSHClient()
    client.set_missing_host_key_policy(AutoAddPolicy())
    try:
        client.connect(host, username=username, password=password)
        print "[ success ]"
        return
    except:
        print "[ failed  ]"
        print "Unable to Connect: %s" % (host)
        
def command(cmd):
    global client
    try:
       stdin, stdout, stderr = client.exec_command(cmd)
       for line in stdout:
             print '... ' + line.strip('\n')
       client.close()
       print "Close Connection"
    except Exception as e:
       print 'Unable to run command %s' % str(e)
       
if __name__ == '__main__':
    test_connection(remote_server)
    auth(remote_server,remote_user,password)
    command('uptime')




