# Server Script Runner 🔐

A Python GUI application for SSH-ing to remote servers and executing scripts securely. Features encrypted credential storage with automatic population on startup.

## ✨ Features

- **Secure Credential Storage**: Passwords are encrypted using Fernet encryption
- **Auto-Population**: Credentials persist across sessions
- **Simple Interface**: 6 input fields for connection settings
- **Start/Stop Scripts**: Execute different scripts on connected servers
- **Cross-Platform**: Works on Linux, macOS, and Windows with Python

## 📋 Requirements

- Python 3.7+
- PyQt5 (for GUI)
- paramiko (for SSH connections)
- cryptography (for encryption)

## 🔧 Installation

1. **Clone this repository:**
   ```bash
   git clone https://github.com/Mrhamon11/ServerScriptRunner.git
   cd ServerScriptRunner
   ```

2. **Create virtual environment:**
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

4. **Generate encryption key (first time only):**
   ```bash
   python keygen.py
   ```
   This creates `~/.ssh_key.txt` for encrypting credentials.

## 🚀 Usage

1. **Run the application:**
   ```bash
   source venv/bin/activate
   python main_app.py
   ```

2. **Enter connection details:**
   - Hostname/IP address
   - Port (default: 22)
   - Username
   - Password

3. **Execute scripts:**
   - Click **"Start"** to run the start script
   - Click **"Stop"** to run the stop script

### Alternative: Use the launcher script (recommended!)
```bash
./run_server_script_runner.sh
```
The launcher script:
- Automatically sets up the virtual environment on first run
- Installs dependencies if needed
- Handles all setup steps transparently

4. **Credentials are automatically encrypted and saved** on each field change!
## 📁 Project Structure

```
ServerScriptRunner/
├── main_app.py              # Main PyQt5 application
├── encrypt_decrypt.py       # Credential encryption/decryption
├── ssh_connect.py           # SSH connection handling
├── run_script.py            # Remote script execution
├── keygen.py                # Fernet key generation
├── requirements.txt         # Python dependencies
├── .gitignore              # Git ignore rules
└── README.md               # This file
```

## 🔒 Security Notes

- Passwords are encrypted locally using Fernet symmetric encryption
- Encryption key is stored separately from credentials
- Credentials are saved to `ssh_credentials.enc` in project directory
- **NEVER share your `.ssh_key.txt` or `ssh_credentials.enc` files**
- Keep this project offline or secure when storing sensitive data

## ⚠️ Important: Sensitive Files

The following files should **NOT** be committed to version control:

- `.ssh_key.txt` - Fernet encryption key
- `ssh_credentials.enc` - Encrypted credentials

These are automatically tracked in `.gitignore`. If you see these files in Git, they've been accidentally committed and should be removed!

## 🐛 Troubleshooting

### "ModuleNotFoundError: No module named 'PyQt5'"
```bash
source venv/bin/activate
pip install PyQt5 paramiko cryptography
```

### "venv/bin/activate" errors
The virtual environment may be corrupted. Re-create it:
```bash
rm -rf venv
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

### Wayland/Gnome warning
The `Warning: Ignoring XDG_SESSION_TYPE=wayland` message is harmless and can be ignored. If you need to change this, run with:
```bash
QT_QPA_PLATFORM=xcb python main_app.py
```

## 📝 License

This project is licensed under the MIT License.

## 🤝 Support

For issues or questions, please open an issue on [GitHub Issues](https://github.com/Mrhamon11/ServerScriptRunner/issues).

---

**Remember: This application handles SSH credentials! Keep it secure and offline when storing sensitive data.**
