#!/usr/bin/env python3
"""Generate a new Fernet encryption key."""
from cryptography.fernet import Fernet

key = Fernet.generate_key()
print(key.decode())
