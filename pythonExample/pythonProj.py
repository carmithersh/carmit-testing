#!/usr/bin/python
# adding a faewture in CTOA-1010, commit 1 
# adding a faewture in CTOA-1010, commit 2

# Function definition is here
def printme( str ):
    # This prints a passed string into this function
    print (str)
    return;

from project import db, app
from Cryptodome.Cipher import ARC4
import hashlib

def arc4_encrypt_password(key, password):
    cipher = ARC4.new(key.encode('utf-8'))
    encrypted_password = cipher.encrypt(password.encode('utf-8'))
    return hashlib.md5(encrypted_password).hexdigest()

# Now you can call printme function
printme("Hello from JFROG!!");
printme("I am part of test skill 4 jira!!");