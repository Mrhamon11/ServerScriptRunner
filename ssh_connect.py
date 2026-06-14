import paramiko


def connect(host, port=22, username=None, password=None, timeout=10):
    """Establish SSH connection to remote server.
    
    Args:
        host: Hostname or IP address
        port: SSH port (default: 22)
        username: Username for authentication
        password: Password for authentication
        timeout: Connection timeout in seconds
    
    Returns:
        ssh_client: Paramiko SSH client object
    """
    
    if not all([host, username, password]):
        raise ValueError("Host, username, and password are required")
    
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    
    try:
        ssh.connect(
            hostname=host,
            port=int(port),
            username=username,
            password=password,
            timeout=timeout
        )
        print(f"Connected to {host}:{port} as {username}")
        return ssh
    except Exception as e:
        raise ConnectionError(f"Failed to connect to server: {str(e)}")


def close_connection(ssh_client):
    """Close SSH connection gracefully."""
    try:
        if ssh_client and ssh_client.get_transport():
            ssh_client.get_transport().close()
        print("SSH connection closed.")
    except Exception as e:
        print(f"Error closing connection: {str(e)}")
