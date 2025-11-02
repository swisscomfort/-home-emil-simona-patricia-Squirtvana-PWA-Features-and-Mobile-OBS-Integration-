#!/bin/bash

# Squirtvana PWA - Startup Script
# This script starts the complete Squirtvana PWA system

echo "🚀 Starting Squirtvana PWA System..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "squirtvana-backend/src/main.py" ]; then
    print_error "Backend not found. Please run this script from the squirtvana installation directory."
    exit 1
fi

# Check if virtual environment exists
if [ ! -d "squirtvana-backend/venv" ]; then
    print_warning "Virtual environment not found. Creating one..."
    cd squirtvana-backend
    python3 -m venv venv
    cd ..
fi

# Activate virtual environment and install dependencies
print_status "Setting up Python environment..."
cd squirtvana-backend
source venv/bin/activate

# Install dependencies if needed
if [ ! -f "venv/.dependencies_installed" ]; then
    print_status "Installing Python dependencies..."
    pip install -r requirements.txt
    if [ $? -eq 0 ]; then
        touch venv/.dependencies_installed
        print_success "Dependencies installed successfully"
    else
        print_error "Failed to install dependencies"
        exit 1
    fi
fi

# Check if frontend is built
if [ ! -f "src/static/index.html" ]; then
    print_warning "Frontend not built. Building now..."
    cd ../squirtvana-complete-frontend
    
    # Install npm dependencies if needed
    if [ ! -d "node_modules" ]; then
        print_status "Installing npm dependencies..."
        npm install
    fi
    
    # Build frontend
    print_status "Building frontend..."
    npm run build
    
    # Copy to backend static directory
    print_status "Copying frontend to backend..."
    cp -r dist/* ../squirtvana-backend/src/static/
    
    cd ../squirtvana-backend
    print_success "Frontend built and integrated"
fi

# Start the backend server
print_status "Starting Squirtvana PWA Backend..."
echo ""
echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║                    🎉 SQUIRTVANA PWA 🎉                      ║${NC}"
echo -e "${PURPLE}║                  Mobile Control Center                       ║${NC}"
echo -e "${PURPLE}╠══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${PURPLE}║${NC} 📱 Frontend: ${GREEN}http://localhost:5000${NC}                        ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC} 🔌 API:      ${GREEN}http://localhost:5000/api${NC}                    ${PURPLE}║${NC}"
echo -e "${PURPLE}║${NC} 📊 Health:   ${GREEN}http://localhost:5000/api/health${NC}             ${PURPLE}║${NC}"
echo -e "${PURPLE}╠══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${PURPLE}║${NC} Press ${YELLOW}Ctrl+C${NC} to stop the server                          ${PURPLE}║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Start the Flask application
python src/main.py

