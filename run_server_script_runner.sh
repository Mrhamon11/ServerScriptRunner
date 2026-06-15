#!/bin/bash

# Server Script Runner Launcher - Desktop File Optimized
# Handles .desktop file launches and signal cleanup properly

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Configuration
KEY_FILE="$HOME/.ssh_key.txt"
APP_PID=""
WAIT_TIMEOUT=10  # Longer wait for desktop file launches
DEBUG=false

# Function to generate encryption key (first time only)
generate_key() {
    if [ ! -f "$KEY_FILE" ]; then
        echo "⚠️  Encryption key not found. Generating new key..."
        if source venv/bin/activate 2>/dev/null; then
            python keygen.py > "$KEY_FILE"
            deactivate 2>/dev/null || true
            echo "✓ Generated encryption key: ~/.ssh_key.txt"
        else
            echo "⚠️  Could not activate virtual environment. Generating key anyway..."
            python3 keygen.py > "$KEY_FILE"
            echo "✓ Generated encryption key: ~/.ssh_key.txt"
        fi
    else
        echo "✓ Encryption key exists: ~/.ssh_key.txt"
    fi
}

# Function to check if venv exists and is valid
check_venv() {
    if [ ! -d "venv" ]; then
        echo "⚠️  Virtual environment not found. Setting up..."
        python3 -m venv venv
        echo "✓ Created virtual environment"
    else
        echo "✓ Virtual environment exists"
    fi
    
    # Check if activate script is valid
    if [ ! -s "venv/bin/activate" ]; then
        echo "❌ Corrupted virtual environment. Re-creating..."
        rm -rf venv
        python3 -m venv venv
    fi
}

# Function to install dependencies (first-time only)
install_dependencies() {
    if [ ! -f "requirements.txt" ]; then
        echo "❌ No requirements.txt found. Please initialize the repo first."
        exit 1
    fi
    
    # Check if packages are installed
    if source venv/bin/activate 2>/dev/null && python -c "import PyQt5, paramiko, cryptography; print('✓ All dependencies installed')" 2>/dev/null; then
        echo "✓ Dependencies already installed"
    else
        echo "⚠️  First-time setup detected. Installing dependencies..."
        pip install -r requirements.txt
        echo "✓ Dependencies installed successfully"
    fi
    
    deactivate 2>/dev/null || true
}

# Function to launch the app
launch_app() {
    echo ""
    echo "=========================================="
    echo "   Launching Server Script Runner App"
    echo "=========================================="
    
    # Activate virtual environment
    source venv/bin/activate
    
    # Run the app (output redirected for cleaner log)
    python main_app.py > /tmp/server_script_runner.log 2>&1 &
    APP_PID=$!
    
    echo ""
    echo "✓ Application is running (PID: $APP_PID)"
    echo ""
    echo "Press Ctrl+C or close the GUI window to exit."
    echo "(Process will be cleaned up automatically)"
    echo ""
}

# Function to cleanup on exit
cleanup() {
    if [ -n "$APP_PID" ]; then
        # Only cleanup if we're actually being asked to exit (not during setup)
        local should_cleanup=false
        
        # Check if called via terminal signal (Ctrl+C, window close)
        if [ "$(tty)" != "/dev/tty" ] || [ -t 0 ]; then
            echo ""
            echo "=========================================="
            echo "   Shutting down..."
            echo "=========================================="
            
            should_cleanup=true
        fi
        
        # Wait for process to close gracefully (longer timeout)
        local count=0
        while kill -0 "$APP_PID" 2>/dev/null && [ $count -lt $WAIT_TIMEOUT ]; do
            sleep 1
            ((count++))
            
            # Check if process is still responding
            if ! ps -p "$APP_PID" -o pid,ppid,args >/dev/null 2>&1; then
                break
            fi
        done
        
        # Process still running? Force kill it
        if kill -0 "$APP_PID" 2>/dev/null; then
            echo "   Waiting for graceful shutdown (attempt $((count+1))/$WAIT_TIMEOUT)..."
            
            local remaining=10
            while kill -0 "$APP_PID" 2>/dev/null && [ $remaining -gt 0 ]; do
                sleep 2
                ((remaining--))
                
                # Check if still running
                if ! ps -p "$APP_PID" -o pid,ppid,stat >/dev/null 2>&1; then
                    break
                fi
                
                echo "   Still waiting (attempt $((WAIT_TIMEOUT-count+1))/$WAIT_TIMEOUT)..."
            done
        fi
        
        # Force kill if still running after timeout
        if kill -0 "$APP_PID" 2>/dev/null; then
            echo "   Force killing application process (PID: $APP_PID)..."
            kill -9 "$APP_PID" 2>/dev/null || true
            
            # Wait for it to actually die
            sleep 1
            
            # Clean up any remaining main_app processes
            local remaining=$(pgrep -f "python.*main_app\.py" 2>/dev/null | wc -l)
            if [ "$remaining" -gt 0 ]; then
                echo "   Cleaning up additional Python processes..."
                pgrep -f "python.*main_app\.py" 2>/dev/null | xargs kill -9 2>/dev/null || true
            fi
        fi
        
        APP_PID=""
    fi
    
    # Deactivate venv (silently)
    deactivate 2>/dev/null || true
}

# Set up cleanup trap for signals
trap cleanup SIGINT SIGTERM EXIT

# Main execution flow
check_venv
install_dependencies
generate_key

launch_app
