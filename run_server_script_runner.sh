#!/bin/bash

# Server Script Runner Launcher
# Fixed cleanup logic for proper process termination

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "   Server Script Runner Launcher"
echo "=========================================="
echo ""

# Configuration
KEY_FILE="$HOME/.ssh_key.txt"
APP_PID=""
WAIT_TIMEOUT=5  # How long to wait before force killing

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
    
    # Try to run the app in background but capture PID
    python main_app.py > /tmp/server_script_runner.log 2>&1 &
    APP_PID=$!
    
    echo ""
    echo "✓ Application is running (PID: $APP_PID)"
    echo ""
    echo "Press Ctrl+C or close the GUI window to exit."
    echo "(Process will be cleaned up automatically)"
    echo ""
}

# Function to cleanup on exit - handles app and processes properly
cleanup() {
    if [ -n "$APP_PID" ]; then
        echo ""
        echo "=========================================="
        echo "   Shutting down..."
        echo "=========================================="
        
        # Wait for process to close gracefully
        local count=0
        while kill -0 "$APP_PID" 2>/dev/null && [ $count -lt $WAIT_TIMEOUT ]; do
            echo "   Waiting for graceful shutdown (attempt $((count+1))/$WAIT_TIMEOUT)..."
            sleep 1
            ((count++))
        done
        
        # Process still running? Check if it's zombie or real process
        if kill -0 "$APP_PID" 2>/dev/null; then
            local is_zombie=$(ps -p "$APP_PID" -o stat= 2>/dev/null | grep -c '^Z' || echo "0")
            
            if [ "$is_zombie" = "1" ]; then
                echo "   Process appears to be zombie, terminating..."
                kill -9 "$APP_PID" 2>/dev/null || true
            else
                echo "   Force killing application process..."
                kill -9 "$APP_PID" 2>/dev/null || true
            fi
            
            # Wait for it to actually die
            sleep 1
        fi
        
        # Kill any remaining main_app processes
        local remaining=$(pgrep -f "python.*main_app\.py" 2>/dev/null | wc -l)
        if [ "$remaining" -gt 0 ]; then
            echo "   Cleaning up additional Python processes..."
            pgrep -f "python.*main_app\.py" 2>/dev/null | xargs kill -9 2>/dev/null || true
        fi
        
        # Kill any orphaned child processes
        local orphans=$(pgrep --parent "$APP_PID" 2>/dev/null)
        if [ -n "$orphans" ]; then
            echo "   Removing orphaned children..."
            pkill -P "$APP_PID" 2>/dev/null || true
        fi
        
        APP_PID=""
    fi
    
    # Deactivate venv
    deactivate 2>/dev/null || true
    
    echo ""
    echo "✓ Cleanup complete. You should see your shell prompt."
}

# Set up cleanup trap for signals (Ctrl+C, close window, etc.)
trap cleanup SIGINT SIGTERM EXIT

# Main execution flow
echo "=========================================="
echo "   Phase 1: Setup (if needed)"
echo "=========================================="
check_venv
install_dependencies
generate_key

echo ""
echo "=========================================="
echo "   Ready to launch!"
echo "=========================================="
echo ""

launch_app
