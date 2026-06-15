#!/bin/bash

# Server Script Runner Launcher
# This script handles both initial setup and running the app
# Usage: ./run_server_script_runner.sh

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "=========================================="
echo "   Server Script Runner Launcher"
echo "=========================================="
echo ""

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
    
    # Try to run the app
    python main_app.py 2>&1 &
    
    # Get the PID of the started process
    APP_PID=$!
    
    echo ""
    echo "✓ Application is running (PID: $APP_PID)"
    echo ""
    echo "Press Ctrl+C to close the application window."
    echo ""
}

# Function to cleanup on exit
cleanup() {
    if [ -n "$APP_PID" ] && kill -0 "$APP_PID" 2>/dev/null; then
        echo "Closing application..."
        kill "$APP_PID" 2>/dev/null || pkill -f "python.*main_app" 2>/dev/null || true
        deactivate 2>/dev/null || true
    fi
}

# Set up cleanup trap
trap cleanup EXIT INT TERM

# Main execution flow
echo "=========================================="
echo "   Phase 1: Setup (if needed)"
echo "=========================================="
check_venv
install_dependencies

echo ""
echo "=========================================="
echo "   Ready to launch!"
echo "=========================================="
echo ""

launch_app
