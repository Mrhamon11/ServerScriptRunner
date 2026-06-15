# ServerScriptRunner Implementation Plan

## 1. Project Structure
```
ServerScriptRunner/
├── venv/              # Virtual environment
├── requirements.txt   # Dependencies
├── encrypt_decrypt.py # Credential encryption helper
├── ssh_connect.py     # SSH connection module
├── run_script.py      # Remote script execution
└── main_app.py        # GUI + logic integration
```

## 2. Dependencies (`requirements.txt`)
- `paramiko==3.4.0` - SSH client
- `cryptography==42.0.5` - Credential encryption
- `PyQt5==5.15.11` - GUI framework

## 3. Implementation Steps

### A. Encryption Module (`encrypt_decrypt.py`)
- Encrypt credentials with user-provided password using Fernet/AES
- Decrypt credentials on app load
- Store encrypted data in a file (e.g., `~/.ssh_credentials.enc`)

### B. SSH Module (`ssh_connect.py`)
- Function: `connect(host, port, username, password)`
- Establish SSH connection with paramiko
- Return SSH client object for script execution

### C. Script Execution Module (`run_script.py`)
- Function: `execute_remote_script(ssh_client, script_path)`
- Connect via ssh_connect.py
- Execute remote bash script on server
- Handle output and errors gracefully

### D. Main App GUI (`main_app.py`)
- Use PyQt5 (richer UI)
- Top section: Start/Stop buttons
- Bottom section: 6 input fields with labels
  - Hostname, Port (default 22), Username, Password (QLineEdit echo=none)
  - Start script path, Stop script path
- Connect signals: on textChanged → encrypt & save to file
- On app start: decrypt & populate fields

### E. Integration Logic
- **Start button:** 
  1. Decrypt credentials
  2. Call `ssh_connect.connect()`
  3. Call `run_script.execute_remote_script(ssh_client, start_path)`
  
- **Stop button:**
  1. Call `run_script.execute_remote_script(ssh_client, stop_path)`
  2. Close SSH connection
