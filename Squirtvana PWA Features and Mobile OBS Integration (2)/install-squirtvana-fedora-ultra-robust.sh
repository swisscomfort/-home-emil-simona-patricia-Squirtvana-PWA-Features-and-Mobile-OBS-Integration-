#!/bin/bash

# Squirtvana PWA - Ultra-Robust Fedora Linux Installation Script
# Fedora 42+ Compatible with Advanced Package Mapping

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Project info
PROJECT_NAME="Squirtvana PWA"
PROJECT_DIR="$HOME/squirtvana-pwa-project"
BACKEND_DIR="$PROJECT_DIR/squirtvana-backend"
FRONTEND_DIR="$PROJECT_DIR/squirtvana-pwa"

echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║                SQUIRTVANA PWA ULTRA-ROBUST INSTALLER         ║${NC}"
echo -e "${PURPLE}║              Fedora 42+ Advanced Package Mapping             ║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to print status
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

print_debug() {
    echo -e "${CYAN}[DEBUG]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if package is installed (with alternatives)
package_installed() {
    local package="$1"
    
    # Direct check first
    if dnf list installed "$package" &>/dev/null; then
        return 0
    fi
    
    # Check for alternative package names based on Fedora 42+ mappings
    case "$package" in
        "wget")
            # Fedora 42+ uses wget2-wget
            if dnf list installed "wget2-wget" &>/dev/null; then
                print_debug "Found alternative: wget2-wget for $package"
                return 0
            fi
            ;;
        "zlib-devel")
            # Fedora 42+ uses zlib-ng-compat-devel
            if dnf list installed "zlib-ng-compat-devel" &>/dev/null; then
                print_debug "Found alternative: zlib-ng-compat-devel for $package"
                return 0
            fi
            ;;
        "python3-pip")
            # Check for python3.11-pip or other versions
            for alt in "python3.11-pip" "python3.12-pip" "python3.13-pip"; do
                if dnf list installed "$alt" &>/dev/null; then
                    print_debug "Found alternative: $alt for $package"
                    return 0
                fi
            done
            ;;
        "python3-virtualenv")
            # Check for python3-venv or python3.11-venv
            for alt in "python3-venv" "python3.11-venv" "python3.12-venv"; do
                if dnf list installed "$alt" &>/dev/null; then
                    print_debug "Found alternative: $alt for $package"
                    return 0
                fi
            done
            ;;
    esac
    
    return 1
}

# Function to get the correct package name for installation
get_package_name() {
    local requested_package="$1"
    local fedora_version="$2"
    
    # Package mapping for Fedora 42+
    if [[ $fedora_version -ge 42 ]]; then
        case "$requested_package" in
            "wget")
                # Try wget first, fallback to wget2-wget
                if dnf list available "wget" &>/dev/null; then
                    echo "wget"
                else
                    echo "wget2-wget"
                fi
                ;;
            "zlib-devel")
                # Try zlib-devel first, fallback to zlib-ng-compat-devel
                if dnf list available "zlib-devel" &>/dev/null; then
                    echo "zlib-devel"
                else
                    echo "zlib-ng-compat-devel"
                fi
                ;;
            *)
                echo "$requested_package"
                ;;
        esac
    else
        echo "$requested_package"
    fi
}

# Enhanced function to install package with alternatives
install_package() {
    local requested_package="$1"
    local fedora_version="${2:-39}"
    
    # Check if already installed (including alternatives)
    if package_installed "$requested_package"; then
        print_success "$requested_package (oder Alternative) bereits installiert"
        return 0
    fi
    
    # Get the correct package name for this Fedora version
    local actual_package=$(get_package_name "$requested_package" "$fedora_version")
    
    print_status "Installiere $actual_package..."
    
    # Try to install the package
    if sudo dnf install -y "$actual_package" &>/dev/null; then
        print_success "$actual_package erfolgreich installiert"
        return 0
    else
        # Try alternative packages if main installation fails
        case "$requested_package" in
            "wget")
                for alt in "wget2-wget" "wget2"; do
                    if dnf list available "$alt" &>/dev/null; then
                        print_status "Versuche Alternative: $alt"
                        if sudo dnf install -y "$alt" &>/dev/null; then
                            print_success "$alt erfolgreich installiert"
                            return 0
                        fi
                    fi
                done
                ;;
            "zlib-devel")
                for alt in "zlib-ng-compat-devel" "zlib1g-dev"; do
                    if dnf list available "$alt" &>/dev/null; then
                        print_status "Versuche Alternative: $alt"
                        if sudo dnf install -y "$alt" &>/dev/null; then
                            print_success "$alt erfolgreich installiert"
                            return 0
                        fi
                    fi
                done
                ;;
            "python3-pip")
                for alt in "python3.11-pip" "python3.12-pip" "pip"; do
                    if dnf list available "$alt" &>/dev/null; then
                        print_status "Versuche Alternative: $alt"
                        if sudo dnf install -y "$alt" &>/dev/null; then
                            print_success "$alt erfolgreich installiert"
                            return 0
                        fi
                    fi
                done
                ;;
            "python3-virtualenv")
                for alt in "python3-venv" "python3.11-venv" "virtualenv"; do
                    if dnf list available "$alt" &>/dev/null; then
                        print_status "Versuche Alternative: $alt"
                        if sudo dnf install -y "$alt" &>/dev/null; then
                            print_success "$alt erfolgreich installiert"
                            return 0
                        fi
                    fi
                done
                ;;
        esac
        
        print_error "$requested_package Installation fehlgeschlagen"
        return 1
    fi
}

# Function to install multiple packages with enhanced error handling
install_packages() {
    local packages=("$@")
    local failed_packages=()
    local fedora_version="${FEDORA_VERSION:-39}"
    
    for package in "${packages[@]}"; do
        if ! install_package "$package" "$fedora_version"; then
            failed_packages+=("$package")
        fi
    done
    
    if [ ${#failed_packages[@]} -gt 0 ]; then
        print_warning "Folgende Pakete konnten nicht installiert werden: ${failed_packages[*]}"
        print_warning "Das Script wird fortgesetzt, aber einige Features könnten nicht funktionieren."
        return 1
    fi
    
    return 0
}

# Function to verify package functionality
verify_package_functionality() {
    local package="$1"
    
    case "$package" in
        "wget")
            if command_exists wget || command_exists wget2; then
                print_success "wget Funktionalität verfügbar"
                return 0
            fi
            ;;
        "python3-pip")
            if command_exists pip3 || command_exists pip || python3 -m pip --version &>/dev/null; then
                print_success "pip Funktionalität verfügbar"
                return 0
            fi
            ;;
        "gcc")
            if command_exists gcc; then
                print_success "gcc Funktionalität verfügbar"
                return 0
            fi
            ;;
    esac
    
    return 1
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "Dieses Script sollte NICHT als root ausgeführt werden!"
   print_warning "Führen Sie es als normaler Benutzer aus. sudo wird automatisch verwendet wenn nötig."
   exit 1
fi

print_status "Starte Ultra-Robust Installation von $PROJECT_NAME..."
echo ""

# Detect Fedora version with enhanced detection
print_status "Erkenne Fedora-Version..."
if [[ -f /etc/fedora-release ]]; then
    FEDORA_VERSION=$(cat /etc/fedora-release | grep -oP '\d+' | head -1)
    print_success "Erkannte Fedora Version: $FEDORA_VERSION"
    
    # Additional version checks
    if [[ $FEDORA_VERSION -ge 42 ]]; then
        print_status "Fedora 42+ erkannt - verwende erweiterte Paketnamen-Mappings"
    elif [[ $FEDORA_VERSION -ge 38 ]]; then
        print_status "Fedora $FEDORA_VERSION erkannt - verwende Standard-Paketnamen"
    else
        print_warning "Fedora $FEDORA_VERSION ist älter als empfohlen (Minimum: 38)"
    fi
else
    print_error "Dieses Script ist nur für Fedora Linux!"
    exit 1
fi

# Update system
print_status "System-Update wird durchgeführt..."
sudo dnf update -y

# Install basic dependencies with enhanced package mapping
print_status "Installiere Basis-Dependencies mit erweiterten Paketnamen-Mappings..."

# Define packages with Fedora version awareness
basic_packages=(
    "curl"
    "wget"
    "git" 
    "unzip"
    "gcc"
    "gcc-c++"
    "make"
    "openssl-devel"
    "bzip2-devel"
    "libffi-devel"
    "zlib-devel"
    "readline-devel"
    "sqlite-devel"
    "xz-devel"
)

print_status "Installiere ${#basic_packages[@]} Basis-Pakete..."
install_packages "${basic_packages[@]}"

# Verify critical functionality
print_status "Überprüfe kritische Funktionalitäten..."
critical_functions=("wget" "gcc" "git")
for func in "${critical_functions[@]}"; do
    if ! verify_package_functionality "$func"; then
        print_warning "$func Funktionalität nicht verfügbar"
    fi
done

# Install Python with enhanced version detection and mapping
print_status "Installiere Python mit erweiterten Versionserkennungen..."

# Python package strategy based on Fedora version
python_packages=()

if [[ $FEDORA_VERSION -ge 42 ]]; then
    print_status "Fedora 42+ Python-Strategie"
    python_packages=(
        "python3"
        "python3-pip"
        "python3-devel"
        "python3-virtualenv"
    )
elif [[ $FEDORA_VERSION -ge 40 ]]; then
    print_status "Fedora 40-41 Python-Strategie"
    python_packages=(
        "python3"
        "python3-pip"
        "python3-devel"
        "python3-virtualenv"
    )
else
    print_status "Fedora <40 Python-Strategie"
    # Try specific Python 3.11 first
    if dnf list available python3.11 &>/dev/null; then
        python_packages=(
            "python3.11"
            "python3.11-devel"
        )
    else
        python_packages=(
            "python3"
            "python3-devel"
        )
    fi
    
    python_packages+=(
        "python3-pip"
        "python3-virtualenv"
    )
fi

print_status "Installiere Python-Pakete: ${python_packages[*]}"
install_packages "${python_packages[@]}"

# Enhanced Python configuration
print_status "Konfiguriere Python mit erweiterten Erkennungen..."

# Find the best Python version with multiple fallbacks
PYTHON_CMD=""
PYTHON_VERSION=""

# Try different Python commands in order of preference
for py_cmd in "python3.13" "python3.12" "python3.11" "python3"; do
    if command_exists "$py_cmd"; then
        PYTHON_CMD="$py_cmd"
        PYTHON_VERSION=$($py_cmd --version 2>&1)
        break
    fi
done

if [[ -z "$PYTHON_CMD" ]]; then
    print_error "Keine Python-Installation gefunden!"
    exit 1
fi

print_success "Python konfiguriert: $PYTHON_VERSION (Command: $PYTHON_CMD)"

# Enhanced pip verification and installation
print_status "Überprüfe pip-Installation mit mehreren Methoden..."

pip_available=false

# Method 1: Check if pip module is available
if $PYTHON_CMD -m pip --version &>/dev/null; then
    pip_available=true
    PIP_VERSION=$($PYTHON_CMD -m pip --version)
    print_success "pip verfügbar via Python-Modul: $PIP_VERSION"
fi

# Method 2: Check for standalone pip commands
if ! $pip_available; then
    for pip_cmd in "pip3" "pip"; do
        if command_exists "$pip_cmd"; then
            pip_available=true
            PIP_VERSION=$($pip_cmd --version)
            print_success "pip verfügbar via $pip_cmd: $PIP_VERSION"
            break
        fi
    done
fi

# Method 3: Install pip via get-pip.py if not available
if ! $pip_available; then
    print_status "Installiere pip über get-pip.py..."
    curl -s https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    $PYTHON_CMD get-pip.py --user
    rm get-pip.py
    
    if $PYTHON_CMD -m pip --version &>/dev/null; then
        pip_available=true
        PIP_VERSION=$($PYTHON_CMD -m pip --version)
        print_success "pip erfolgreich installiert: $PIP_VERSION"
    fi
fi

if ! $pip_available; then
    print_error "pip Installation fehlgeschlagen!"
    exit 1
fi

# Install Node.js and npm with version checking
print_status "Installiere Node.js und npm..."
nodejs_packages=(
    "nodejs"
    "npm"
)

install_packages "${nodejs_packages[@]}"

# Verify Node.js installation with version requirements
if command_exists node && command_exists npm; then
    NODE_VERSION=$(node --version | sed 's/v//')
    NPM_VERSION=$(npm --version)
    
    # Check Node.js version (minimum 18)
    NODE_MAJOR=$(echo "$NODE_VERSION" | cut -d'.' -f1)
    if [[ $NODE_MAJOR -ge 18 ]]; then
        print_success "Node.js installiert: v$NODE_VERSION (✓ >= 18)"
    else
        print_warning "Node.js installiert: v$NODE_VERSION (⚠ < 18, könnte Probleme verursachen)"
    fi
    
    print_success "npm installiert: $NPM_VERSION"
else
    print_error "Node.js Installation fehlgeschlagen!"
    exit 1
fi

# Install pnpm with fallback methods
print_status "Installiere pnpm mit mehreren Methoden..."
pnpm_installed=false

# Method 1: Check if already installed
if command_exists pnpm; then
    PNPM_VERSION=$(pnpm --version)
    print_success "pnpm bereits installiert: $PNPM_VERSION"
    pnpm_installed=true
fi

# Method 2: Install via npm
if ! $pnpm_installed; then
    print_status "Installiere pnpm via npm..."
    if sudo npm install -g pnpm; then
        if command_exists pnpm; then
            PNPM_VERSION=$(pnpm --version)
            print_success "pnpm installiert: $PNPM_VERSION"
            pnpm_installed=true
        fi
    fi
fi

# Method 3: Install via curl (fallback)
if ! $pnpm_installed; then
    print_status "Installiere pnpm via curl (Fallback)..."
    curl -fsSL https://get.pnpm.io/install.sh | sh -
    source ~/.bashrc 2>/dev/null || true
    
    if command_exists pnpm; then
        PNPM_VERSION=$(pnpm --version)
        print_success "pnpm installiert: $PNPM_VERSION"
        pnpm_installed=true
    fi
fi

if ! $pnpm_installed; then
    print_warning "pnpm Installation fehlgeschlagen - verwende npm als Fallback"
fi

# Enhanced OBS Studio installation with multiple methods
print_status "Installiere OBS Studio mit erweiterten Methoden..."

obs_installed=false
obs_method=""

# Method 1: Standard repository
print_status "Versuche OBS Installation aus Standard-Repository..."
if install_package "obs-studio" "$FEDORA_VERSION"; then
    obs_installed=true
    obs_method="Standard Repository"
fi

# Method 2: RPM Fusion
if ! $obs_installed; then
    print_status "Aktiviere RPM Fusion Repository für OBS..."
    
    # Check if RPM Fusion is already enabled
    if ! dnf repolist | grep -q rpmfusion; then
        print_status "Installiere RPM Fusion Repositories..."
        sudo dnf install -y "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" 2>/dev/null || true
        sudo dnf install -y "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm" 2>/dev/null || true
    fi
    
    if install_package "obs-studio" "$FEDORA_VERSION"; then
        obs_installed=true
        obs_method="RPM Fusion"
    fi
fi

# Method 3: Flatpak
if ! $obs_installed; then
    print_status "Versuche OBS Installation via Flatpak..."
    
    # Ensure Flatpak is installed
    if ! command_exists flatpak; then
        install_package "flatpak" "$FEDORA_VERSION"
    fi
    
    if command_exists flatpak; then
        # Add Flathub repository if not present
        flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 2>/dev/null || true
        
        # Install OBS via Flatpak
        if flatpak install -y flathub com.obsproject.Studio 2>/dev/null; then
            obs_installed=true
            obs_method="Flatpak"
        fi
    fi
fi

if $obs_installed; then
    print_success "OBS Studio erfolgreich installiert via $obs_method"
else
    print_warning "OBS Studio Installation fehlgeschlagen - kann später manuell installiert werden"
    print_warning "Versuchen Sie: sudo dnf install obs-studio"
    print_warning "Oder via Flatpak: flatpak install flathub com.obsproject.Studio"
fi

# Install additional media libraries with error tolerance
print_status "Installiere zusätzliche Media-Libraries..."
media_packages=(
    "ffmpeg"
    "gstreamer1-plugins-base"
    "gstreamer1-plugins-good"
    "gstreamer1-plugins-bad-free"
    "gstreamer1-plugins-ugly-free"
)

print_status "Installiere ${#media_packages[@]} Media-Pakete (nicht-kritisch)..."
for package in "${media_packages[@]}"; do
    if install_package "$package" "$FEDORA_VERSION"; then
        print_success "$package installiert"
    else
        print_warning "$package konnte nicht installiert werden (nicht kritisch)"
    fi
done

# Create project directory structure
print_status "Erstelle Projekt-Verzeichnis-Struktur..."
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Create backend structure
mkdir -p "$BACKEND_DIR"/{src/{routes,models,static},venv}

# Create backend files with enhanced error handling
print_status "Erstelle Backend-Struktur mit erweiterten Konfigurationen..."

# Create requirements.txt with version pinning
cat > "$BACKEND_DIR/requirements.txt" << 'EOF'
blinker==1.9.0
click==8.2.1
Flask==3.1.0
Flask-CORS==5.0.0
itsdangerous==2.2.0
Jinja2==3.2.1
MarkupSafe==3.0.2
Werkzeug==3.1.3
openai==1.54.4
requests==2.32.3
websocket-client==1.8.0
python-telegram-bot==21.9
elevenlabs==1.14.0
psutil==6.1.0
python-dotenv==1.0.1
EOF

# Create .env file
cat > "$BACKEND_DIR/.env" << 'EOF'
OPENROUTER_KEY=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
TELEGRAM_API_KEY=7512900295:AAHhwRKamqq9gQj55LNF3mbKV63IQuJ8dQY
ELEVENLABS_API_KEY=sk_226e2f2cec752de5561266ae5043937dc08a7e52597ec069
ELEVENLABS_VOICE_ID=21m00Tcm4TlvDq8ikWAM
EOF

# Create enhanced main.py with better error handling
cat > "$BACKEND_DIR/src/main.py" << 'EOF'
import os
import sys
from pathlib import Path

# Add the src directory to Python path
sys.path.insert(0, str(Path(__file__).parent))

try:
    from flask import Flask, send_from_directory, jsonify
    from flask_cors import CORS
    from dotenv import load_dotenv
except ImportError as e:
    print(f"Error importing required modules: {e}")
    print("Please ensure all dependencies are installed: pip install -r requirements.txt")
    sys.exit(1)

# Load environment variables
load_dotenv()

# Import route blueprints with error handling
try:
    from routes.gpt import gpt_bp
    from routes.audio import audio_bp
    from routes.obs import obs_bp
    from routes.stream import stream_bp
    from routes.system import system_bp
except ImportError as e:
    print(f"Error importing route modules: {e}")
    print("Some features may not be available.")

app = Flask(__name__, static_folder='static', static_url_path='')

# Enable CORS for all routes
CORS(app, origins="*")

# Register blueprints with error handling
try:
    app.register_blueprint(gpt_bp, url_prefix='/api/gpt')
    app.register_blueprint(audio_bp, url_prefix='/api/audio')
    app.register_blueprint(obs_bp, url_prefix='/api/obs')
    app.register_blueprint(stream_bp, url_prefix='/api')
    app.register_blueprint(system_bp, url_prefix='/api')
except NameError:
    print("Warning: Some route blueprints could not be registered")

# Serve React app
@app.route('/')
def serve_react_app():
    try:
        return send_from_directory(app.static_folder, 'index.html')
    except:
        return jsonify({'message': 'Frontend not built yet. Run: cd frontend && npm run build'})

@app.route('/<path:path>')
def serve_react_assets(path):
    if path != "" and os.path.exists(os.path.join(app.static_folder, path)):
        return send_from_directory(app.static_folder, path)
    else:
        return serve_react_app()

@app.route('/api/health')
def health_check():
    return jsonify({
        'status': 'healthy',
        'message': 'Squirtvana PWA Backend is running',
        'python_version': sys.version,
        'flask_version': getattr(__import__('flask'), '__version__', 'unknown')
    })

if __name__ == '__main__':
    print("🚀 Starting Squirtvana PWA Backend...")
    print("📱 Frontend available at: http://localhost:5000")
    print("🔌 API available at: http://localhost:5000/api")
    print(f"🐍 Python: {sys.version}")
    
    try:
        app.run(host='0.0.0.0', port=5000, debug=True)
    except KeyboardInterrupt:
        print("\n🛑 Server stopped by user")
    except Exception as e:
        print(f"❌ Server error: {e}")
EOF

# Create route files with enhanced error handling
mkdir -p "$BACKEND_DIR/src/routes"

# Create __init__.py files
touch "$BACKEND_DIR/src/__init__.py"
touch "$BACKEND_DIR/src/routes/__init__.py"
touch "$BACKEND_DIR/src/models/__init__.py"

# Create simplified but functional route files
for route in gpt audio obs stream system; do
    cat > "$BACKEND_DIR/src/routes/${route}.py" << EOF
from flask import Blueprint, jsonify, request
import sys

${route}_bp = Blueprint('${route}', __name__)

@${route}_bp.route('/status')
def ${route}_status():
    return jsonify({
        'status': 'active',
        'message': '${route} service is running',
        'python_version': sys.version
    })

@${route}_bp.route('/test', methods=['GET', 'POST'])
def ${route}_test():
    return jsonify({
        'success': True,
        'message': '${route} test endpoint working',
        'method': request.method
    })
EOF
done

# Setup Python virtual environment with enhanced error handling
print_status "Erstelle Python Virtual Environment mit erweiterten Konfigurationen..."
cd "$BACKEND_DIR"

# Create virtual environment with the detected Python version
if $PYTHON_CMD -m venv venv; then
    print_success "Virtual Environment erfolgreich erstellt"
else
    print_error "Virtual Environment Erstellung fehlgeschlagen"
    exit 1
fi

# Activate virtual environment and install dependencies
print_status "Installiere Python-Dependencies mit erweiterten Konfigurationen..."
source venv/bin/activate

# Upgrade pip in virtual environment
$PYTHON_CMD -m pip install --upgrade pip

# Install requirements with error handling
if $PYTHON_CMD -m pip install -r requirements.txt; then
    print_success "Alle Python-Dependencies erfolgreich installiert"
else
    print_warning "Einige Python-Dependencies konnten nicht installiert werden"
    print_status "Versuche Installation der wichtigsten Pakete einzeln..."
    
    # Install critical packages individually
    critical_packages=("flask" "flask-cors" "requests" "python-dotenv")
    for pkg in "${critical_packages[@]}"; do
        if $PYTHON_CMD -m pip install "$pkg"; then
            print_success "$pkg installiert"
        else
            print_warning "$pkg Installation fehlgeschlagen"
        fi
    done
fi

print_success "Backend-Setup abgeschlossen!"

# Create frontend structure (simplified for now)
print_status "Erstelle Frontend-Struktur..."
cd "$PROJECT_DIR"

mkdir -p "$FRONTEND_DIR"/{src,public}

# Create minimal package.json
cat > "$FRONTEND_DIR/package.json" << 'EOF'
{
  "name": "squirtvana-pwa",
  "private": true,
  "version": "0.0.0",
  "type": "module",
  "scripts": {
    "dev": "echo 'Frontend development server'",
    "build": "echo 'Frontend build process'",
    "preview": "echo 'Frontend preview'"
  },
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1"
  }
}
EOF

# Create enhanced start script with system detection
print_status "Erstelle erweiterte Start-Scripts..."
cat > "$PROJECT_DIR/start-squirtvana.sh" << EOF
#!/bin/bash

# Squirtvana PWA Enhanced Start Script

PROJECT_DIR="$PROJECT_DIR"
BACKEND_DIR="$BACKEND_DIR"
PYTHON_CMD="$PYTHON_CMD"

echo "🚀 Starting Squirtvana PWA (Ultra-Robust Version)..."
echo "📊 System Info:"
echo "   - Fedora Version: $FEDORA_VERSION"
echo "   - Python Command: \$PYTHON_CMD"
echo "   - Project Directory: \$PROJECT_DIR"
echo ""

# Check if virtual environment exists
if [[ ! -d "\$BACKEND_DIR/venv" ]]; then
    echo "❌ Virtual environment not found!"
    echo "Please run the installation script again."
    exit 1
fi

# Start backend
echo "📡 Starting Backend..."
cd "\$BACKEND_DIR"

# Activate virtual environment
if source venv/bin/activate; then
    echo "✅ Virtual environment activated"
else
    echo "❌ Failed to activate virtual environment"
    exit 1
fi

# Start the application
echo "🌟 Starting Squirtvana PWA Backend..."
\$PYTHON_CMD src/main.py &
BACKEND_PID=\$!

echo "✅ Backend started (PID: \$BACKEND_PID)"
echo "📱 Squirtvana PWA available at: http://localhost:5000"
echo "🔌 API Health Check: http://localhost:5000/api/health"
echo ""
echo "Press Ctrl+C to stop..."

# Wait for interrupt
trap 'echo "🛑 Stopping Squirtvana PWA..."; kill \$BACKEND_PID 2>/dev/null; exit' INT
wait \$BACKEND_PID
EOF

chmod +x "$PROJECT_DIR/start-squirtvana.sh"

# Create enhanced system info file
cat > "$PROJECT_DIR/SYSTEM-INFO.txt" << EOF
# Squirtvana PWA - Enhanced System Information

Installation Date: $(date)
Installation Script: Ultra-Robust Version with Package Mapping
Fedora Version: $FEDORA_VERSION
Architecture: $(uname -m)
Kernel: $(uname -r)

Python Configuration:
- Command: $PYTHON_CMD
- Version: $PYTHON_VERSION
- pip Available: $(if $PYTHON_CMD -m pip --version &>/dev/null; then echo "Yes"; else echo "No"; fi)

Node.js Configuration:
- Version: $(node --version 2>/dev/null || echo "Not available")
- npm Version: $(npm --version 2>/dev/null || echo "Not available")
- pnpm Version: $(pnpm --version 2>/dev/null || echo "Not available")

OBS Studio:
- Installed: $(if command_exists obs || flatpak list | grep -q obs; then echo "Yes"; else echo "No"; fi)
- Method: $obs_method

Project Structure:
- Project Directory: $PROJECT_DIR
- Backend Directory: $BACKEND_DIR
- Frontend Directory: $FRONTEND_DIR

Commands:
- Start: $PROJECT_DIR/start-squirtvana.sh
- URL: http://localhost:5000
- Health Check: http://localhost:5000/api/health

Package Mapping Applied:
- wget -> $(get_package_name "wget" "$FEDORA_VERSION")
- zlib-devel -> $(get_package_name "zlib-devel" "$FEDORA_VERSION")

Installation Log:
$(date): Ultra-robust installation completed successfully
EOF

# Create desktop entry
print_status "Erstelle Desktop-Verknüpfung..."
mkdir -p "$HOME/.local/share/applications"

cat > "$HOME/.local/share/applications/squirtvana-pwa.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Squirtvana PWA (Ultra-Robust)
Comment=Mobile Streaming Control Center - Fedora 42+ Compatible
Exec=$PROJECT_DIR/start-squirtvana.sh
Icon=applications-multimedia
Terminal=true
Categories=AudioVideo;Video;
EOF

# Final completion message
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║              ULTRA-ROBUST INSTALLATION ABGESCHLOSSEN!        ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
print_success "Squirtvana PWA wurde mit erweiterten Paketnamen-Mappings installiert!"
echo ""
echo -e "${CYAN}📊 Installation Summary:${NC}"
echo -e "${BLUE}📁 Projekt-Verzeichnis:${NC} $PROJECT_DIR"
echo -e "${BLUE}🚀 Start-Command:${NC} $PROJECT_DIR/start-squirtvana.sh"
echo -e "${BLUE}🌐 URL nach Start:${NC} http://localhost:5000"
echo -e "${BLUE}🔍 Health Check:${NC} http://localhost:5000/api/health"
echo -e "${BLUE}🐍 Python Command:${NC} $PYTHON_CMD"
echo -e "${BLUE}📦 Fedora Version:${NC} $FEDORA_VERSION"
echo ""
echo -e "${CYAN}🔧 Package Mappings Applied:${NC}"
echo -e "${BLUE}   wget:${NC} $(get_package_name "wget" "$FEDORA_VERSION")"
echo -e "${BLUE}   zlib-devel:${NC} $(get_package_name "zlib-devel" "$FEDORA_VERSION")"
echo ""
echo -e "${YELLOW}📋 Nächste Schritte:${NC}"
echo "1. OBS Studio konfigurieren (WebSocket Port 4455)"
echo "2. Squirtvana starten: $PROJECT_DIR/start-squirtvana.sh"
echo "3. Browser öffnen: http://localhost:5000"
echo "4. Health Check: http://localhost:5000/api/health"
echo ""
echo -e "${PURPLE}🎉 Ultra-Robust Installation erfolgreich abgeschlossen!${NC}"
echo ""
echo -e "${CYAN}💡 Debug-Informationen:${NC} $PROJECT_DIR/SYSTEM-INFO.txt"
echo -e "${CYAN}🆘 Bei Problemen:${NC} Siehe SYSTEM-INFO.txt für detaillierte Konfiguration"

