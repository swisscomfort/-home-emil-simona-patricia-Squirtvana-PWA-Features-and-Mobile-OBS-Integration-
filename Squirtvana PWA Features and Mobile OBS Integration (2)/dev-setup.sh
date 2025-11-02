#!/bin/bash

# Squirtvana PWA - Development Setup Script for VSCode
# This script sets up the complete development environment

echo "🚀 Setting up Squirtvana PWA Development Environment..."

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

print_header() {
    echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║                    $1                    ║${NC}"
    echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
}

# Check if we're in the right directory
if [ ! -f "squirtvana-workspace.code-workspace" ]; then
    print_error "VSCode workspace file not found. Please run this script from the squirtvana-vscode-dev directory."
    exit 1
fi

print_header "🎯 SQUIRTVANA PWA DEVELOPMENT SETUP"

# 1. Backend Setup
print_status "Setting up Python Backend..."
cd squirtvana-backend

# Create virtual environment if it doesn't exist
if [ ! -d "venv" ]; then
    print_status "Creating Python virtual environment..."
    python3 -m venv venv
    if [ $? -eq 0 ]; then
        print_success "Virtual environment created"
    else
        print_error "Failed to create virtual environment"
        exit 1
    fi
fi

# Activate virtual environment and install dependencies
print_status "Installing Python dependencies..."
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

if [ $? -eq 0 ]; then
    print_success "Python dependencies installed"
    # Mark dependencies as installed
    touch venv/.dependencies_installed
else
    print_error "Failed to install Python dependencies"
    exit 1
fi

cd ..

# 2. Frontend Setup
print_status "Setting up React Frontend..."
cd squirtvana-complete-frontend

# Check if Node.js is available
if ! command -v node &> /dev/null; then
    print_error "Node.js not found. Please install Node.js 18+ first."
    exit 1
fi

# Install npm dependencies
if [ ! -d "node_modules" ]; then
    print_status "Installing npm dependencies..."
    npm install
    if [ $? -eq 0 ]; then
        print_success "npm dependencies installed"
    else
        print_error "Failed to install npm dependencies"
        exit 1
    fi
else
    print_success "npm dependencies already installed"
fi

cd ..

# 3. VSCode Extensions Check
print_status "Checking VSCode extensions..."
if command -v code &> /dev/null; then
    print_status "Installing recommended VSCode extensions..."
    
    # Essential extensions
    code --install-extension ms-python.python
    code --install-extension ms-python.black-formatter
    code --install-extension esbenp.prettier-vscode
    code --install-extension dbaeumer.vscode-eslint
    code --install-extension bradlc.vscode-tailwindcss
    code --install-extension rangav.vscode-thunder-client
    code --install-extension eamodio.gitlens
    code --install-extension pkief.material-icon-theme
    
    print_success "VSCode extensions installed"
else
    print_warning "VSCode CLI not found. Please install extensions manually."
fi

# 4. Build Frontend for first time
print_status "Building frontend for first time..."
cd squirtvana-complete-frontend
npm run build
if [ $? -eq 0 ]; then
    print_status "Copying frontend to backend static directory..."
    cp -r dist/* ../squirtvana-backend/src/static/
    print_success "Frontend built and deployed"
else
    print_warning "Frontend build failed, but continuing..."
fi

cd ..

# 5. Create development shortcuts
print_status "Creating development shortcuts..."

# Create a quick start script
cat > quick-start.sh << 'EOF'
#!/bin/bash
echo "🚀 Starting Squirtvana PWA Development Environment..."

# Start backend in background
cd squirtvana-backend
source venv/bin/activate
python src/main.py &
BACKEND_PID=$!

# Start frontend in background
cd ../squirtvana-complete-frontend
npm run dev &
FRONTEND_PID=$!

echo "✅ Backend running on http://localhost:5000"
echo "✅ Frontend running on http://localhost:5174"
echo ""
echo "Press Ctrl+C to stop both servers"

# Wait for Ctrl+C
trap "kill $BACKEND_PID $FRONTEND_PID; exit" INT
wait
EOF

chmod +x quick-start.sh

# Create a test script
cat > run-tests.sh << 'EOF'
#!/bin/bash
echo "🧪 Running Squirtvana PWA Tests..."

# Backend tests
echo "🐍 Running Python tests..."
cd squirtvana-backend
source venv/bin/activate
python -m pytest -v

# Frontend tests (linting)
echo "⚛️ Running Frontend linting..."
cd ../squirtvana-complete-frontend
npm run lint

echo "✅ All tests completed"
EOF

chmod +x run-tests.sh

print_success "Development shortcuts created"

# 6. Final setup
print_header "🎉 SETUP COMPLETE"

echo ""
echo -e "${GREEN}✅ Development environment is ready!${NC}"
echo ""
echo -e "${BLUE}📁 Project Structure:${NC}"
echo "   ├── squirtvana-workspace.code-workspace  (Open this in VSCode)"
echo "   ├── squirtvana-complete-frontend/        (React PWA)"
echo "   ├── squirtvana-backend/                  (Flask API)"
echo "   ├── quick-start.sh                       (Start both servers)"
echo "   └── run-tests.sh                         (Run all tests)"
echo ""
echo -e "${BLUE}🚀 Next Steps:${NC}"
echo "   1. Open VSCode: ${YELLOW}code squirtvana-workspace.code-workspace${NC}"
echo "   2. Install recommended extensions when prompted"
echo "   3. Use Ctrl+Shift+P → 'Tasks: Run Task' → '🚀 Start Squirtvana'"
echo "   4. Or run: ${YELLOW}./quick-start.sh${NC}"
echo ""
echo -e "${BLUE}🌐 Access URLs:${NC}"
echo "   • PWA Frontend: ${GREEN}http://localhost:5000${NC}"
echo "   • Dev Frontend: ${GREEN}http://localhost:5174${NC}"
echo "   • API Health:   ${GREEN}http://localhost:5000/api/health${NC}"
echo ""
echo -e "${PURPLE}Happy Coding! 💻${NC}"

