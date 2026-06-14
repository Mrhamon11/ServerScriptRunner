import os
from cryptography.fernet import Fernet


class CredentialManager:
    """Encrypts and decrypts SSH credentials for secure storage."""
    
    # Default path for encrypted credentials file in current directory
    DEFAULT_PATH = "./ssh_credentials.enc"
    KEY = None  # Key will be generated automatically on first use

    @classmethod
    def get_key(cls):
        """Get the encryption key from file."""
        key_path = os.path.expanduser("~/.ssh_key.txt")
        if not os.path.exists(key_path):
            # Auto-generate and save a new key if it doesn't exist
            from cryptography.fernet import Fernet
            fernet = Fernet()
            key_bytes = fernet.generate_key()
            with open(key_path, 'wb') as f:
                f.write(key_bytes)
        
        with open(key_path, 'rb') as f:
            key_bytes = f.read()
            return key_bytes

    @classmethod
    def encrypt_credentials(cls, password, save_path=None):
        """Encrypt credentials and save to file."""
        if save_path is None:
            save_path = cls.DEFAULT_PATH

        key = cls.get_key()
        fernet = Fernet(key)
        encrypted_data = fernet.encrypt(password.encode())
        
        with open(save_path, 'wb') as f:
            f.write(encrypted_data)
        
        return save_path

    @classmethod
    def decrypt_credentials(cls, file_path):
        """Decrypt credentials from file and return password."""
        if not os.path.exists(file_path):
            return None
        
        with open(file_path, 'rb') as f:
            encrypted_data = f.read()
        
        key = cls.get_key()
        fernet = Fernet(key)
        decrypted_data = fernet.decrypt(encrypted_data)
        
        return decrypted_data.decode()
