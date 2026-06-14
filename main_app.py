import sys
import os
from PyQt5.QtWidgets import (
    QApplication, QWidget, QVBoxLayout, QLabel, QLineEdit, QPushButton,
    QGroupBox, QMessageBox, QSpacerItem, QSizePolicy
)
from encrypt_decrypt import CredentialManager


class ServerScriptRunnerApp(QWidget):
    def __init__(self):
        super().__init__()
        
        self.setFixedSize(1400, 950)
        self.setWindowTitle("SSH Script Runner")
        
        # Default credential path in current directory
        self.credential_path = "./ssh_credentials.enc"
        
        self.init_ui()
        self.connect_signals()
        
        # Auto-populate if credentials exist
        try:
            decrypted_password = CredentialManager.decrypt_credentials(self.credential_path)
            self.password_field.setText(decrypted_password)
        except FileNotFoundError:
            pass  # No saved credentials, fields will be empty
        except Exception as e:
            QMessageBox.warning(self, "Warning", f"Failed to load credentials: {str(e)}")

    def init_ui(self):
        """Initialize the UI layout."""
        
        main_layout = QVBoxLayout(self)
        
        # Top section: Buttons
        button_group = QGroupBox("Action", self)
        button_layout = QVBoxLayout(button_group)
        
        self.start_btn = QPushButton("Start", self)
        self.stop_btn = QPushButton("Stop", self)
        self.start_btn.setStyleSheet("font-weight: bold; padding: 10px;")
        self.stop_btn.setStyleSheet("font-weight: bold; padding: 10px; background-color: #ff5722; color: white;")
        
        button_layout.addWidget(self.start_btn)
        button_layout.addWidget(self.stop_btn)
        main_layout.addWidget(button_group)
        
        # Bottom section: Input fields
        input_group = QGroupBox("Connection Settings", self)
        input_layout = QVBoxLayout(input_group)
        
        # Hostname field
        host_label = QLabel("Hostname/IP:")
        self.host_field = QLineEdit(self)
        self.host_field.setText("192.168.1.1")
        self.host_field.setFixedHeight(50)
        input_layout.addWidget(host_label)
        input_layout.addWidget(self.host_field)
        spacer = QSpacerItem(20, 15, QSizePolicy.Policy.Minimum, QSizePolicy.Policy.Expanding)
        input_layout.addSpacerItem(spacer)
        
        # Port field
        port_label = QLabel("Port (default 22):")
        self.port_field = QLineEdit(self)
        self.port_field.setText("22")
        self.port_field.setFixedHeight(50)
        input_layout.addWidget(port_label)
        input_layout.addWidget(self.port_field)
        spacer = QSpacerItem(20, 15, QSizePolicy.Policy.Minimum, QSizePolicy.Policy.Expanding)
        input_layout.addSpacerItem(spacer)
        
        # Username field
        user_label = QLabel("Username:")
        self.username_field = QLineEdit(self)
        self.username_field.setFixedHeight(50)
        input_layout.addWidget(user_label)
        input_layout.addWidget(self.username_field)
        spacer = QSpacerItem(20, 15, QSizePolicy.Policy.Minimum, QSizePolicy.Policy.Expanding)
        input_layout.addSpacerItem(spacer)
        
        # Password field (hidden echo)
        pass_label = QLabel("Password:")
        self.password_field = QLineEdit(self)
        self.password_field.setEchoMode(QLineEdit.Password)
        self.password_field.setFixedHeight(50)
        input_layout.addWidget(pass_label)
        input_layout.addWidget(self.password_field)
        spacer = QSpacerItem(20, 15, QSizePolicy.Policy.Minimum, QSizePolicy.Policy.Expanding)
        input_layout.addSpacerItem(spacer)
        
        # Start script path field
        start_script_label = QLabel("Start Script Path:")
        self.start_script_field = QLineEdit(self)
        self.start_script_field.setText("/path/to/start_script.sh")
        self.start_script_field.setFixedHeight(50)
        input_layout.addWidget(start_script_label)
        input_layout.addWidget(self.start_script_field)
        spacer = QSpacerItem(20, 15, QSizePolicy.Policy.Minimum, QSizePolicy.Policy.Expanding)
        input_layout.addSpacerItem(spacer)
        
        # Stop script path field
        stop_script_label = QLabel("Stop Script Path:")
        self.stop_script_field = QLineEdit(self)
        self.stop_script_field.setText("/path/to/stop_script.sh")
        self.stop_script_field.setFixedHeight(50)
        input_layout.addWidget(stop_script_label)
        input_layout.addWidget(self.stop_script_field)
        spacer = QSpacerItem(20, 15, QSizePolicy.Policy.Minimum, QSizePolicy.Policy.Expanding)
        input_layout.addSpacerItem(spacer)
        
        main_layout.addWidget(input_group)

    def connect_signals(self):
        """Connect field changes to save credentials and button clicks."""
        
        # Connect all textChanged signals to save encrypted credentials
        self.host_field.textChanged.connect(lambda: self.save_credentials())
        self.port_field.textChanged.connect(lambda: self.save_credentials())
        self.username_field.textChanged.connect(lambda: self.save_credentials())
        self.password_field.textChanged.connect(lambda: self.save_credentials())
        self.start_script_field.textChanged.connect(lambda: self.save_credentials())
        self.stop_script_field.textChanged.connect(lambda: self.save_credentials())
        
        # Connect Start button
        self.start_btn.clicked.connect(self.on_start)
        
        # Connect Stop button
        self.stop_btn.clicked.connect(self.on_stop)

    def save_credentials(self):
        """Save all credentials to encrypted file."""
        credential_data = f"password={self.password_field.text()}\nstart_script={self.start_script_field.text()}\nstop_script={self.stop_script_field.text()}\nhost={self.host_field.text()}\nport={self.port_field.text()}\nusername={self.username_field.text()}"
        
        CredentialManager.encrypt_credentials(credential_data, self.credential_path)

    def on_start(self):
        """Execute Start button: connect and run start script."""
        host = self.host_field.text().strip()
        port = self.port_field.text().strip() or "22"
        username = self.username_field.text().strip()
        password = self.password_field.text().strip()
        start_script_path = self.start_script_field.text().strip()
        
        if not all([host, port, username, start_script_path]):
            QMessageBox.warning(self, "Missing Info", "Please fill in all required fields for Start.")
            return
        
        try:
            from run_script import run_script
            
            stdout, stderr = run_script(
                host=host,
                port=int(port),
                username=username,
                password=password,
                script_path=start_script_path
            )
            
            QMessageBox.information(self, "Success", f"Start script executed successfully!\n\nOutput:\n{stdout}")
        except Exception as e:
            error_msg = str(e)
            if not error_msg.startswith("SSH"):
                error_msg = "Connection failed." + error_msg
            QMessageBox.critical(self, "Error", f"Failed to execute start script:\n{error_msg}")

    def on_stop(self):
        """Execute Stop button: run stop script and disconnect."""
        host = self.host_field.text().strip()
        port = self.port_field.text().strip() or "22"
        username = self.username_field.text().strip()
        password = self.password_field.text().strip()
        stop_script_path = self.stop_script_field.text().strip()
        
        if not all([host, port, username, stop_script_path]):
            QMessageBox.warning(self, "Missing Info", "Please fill in all required fields for Stop.")
            return
        
        try:
            from run_script import run_script
            
            stdout, stderr = run_script(
                host=host,
                port=int(port),
                username=username,
                password=password,
                script_path=stop_script_path
            )
            
            QMessageBox.information(self, "Success", f"Stop script executed successfully!\n\nOutput:\n{stdout}")
        except Exception as e:
            error_msg = str(e)
            if not error_msg.startswith("SSH"):
                error_msg = "Connection failed." + error_msg
            QMessageBox.critical(self, "Error", f"Failed to execute stop script:\n{error_msg}")

    def closeEvent(self, event):
        """Save credentials before closing app."""
        self.save_credentials()
        event.accept()


if __name__ == "__main__":
    app = QApplication(sys.argv)
    
    # Set application-wide stylesheet for better visuals
    app.setStyle("Fusion")
    
    window = ServerScriptRunnerApp()
    window.show()
    
    sys.exit(app.exec_())
