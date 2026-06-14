import sys
from ssh_connect import connect, close_connection


def execute_remote_script(ssh_client, script_path):
    """Execute a bash script on the remote server.
    
    Args:
        ssh_client: Paramiko SSH client object
        script_path: Full path to the script on the remote server
    
    Returns:
        stdout_output: Command output as string
        stderr_output: Error output as string
    
    Raises:
        FileNotFoundError: If script doesn't exist
        PermissionError: If script is not executable
    """
    
    if not ssh_client or not script_path:
        raise ValueError("SSH client and script path are required")
    
    stdin, stdout, stderr = ssh_client.exec_command(f"bash {script_path}")
    
    # Read output
    stdout_output = stdout.read().decode()
    stderr_output = stderr.read().decode()
    exit_status = stdout.channel.recv_exit_status()
    
    print(f"Script executed with status: {exit_status}")
    
    if exit_status == 0:
        return stdout_output, stderr_output
    else:
        raise RuntimeError(f"Script failed with exit status {exit_status}: {stderr_output}")


def run_script(host, port, username, password, script_path):
    """Execute a remote script and close connection.
    
    Args:
        host: Hostname or IP address
        port: SSH port (default: 22)
        username: Username for authentication
        password: Password for authentication
        script_path: Full path to the script on the remote server
    
    Returns:
        stdout_output: Command output as string
        stderr_output: Error output as string
    """
    
    try:
        ssh = connect(host, port, username, password)
        return execute_remote_script(ssh, script_path)
    finally:
        close_connection(ssh)
