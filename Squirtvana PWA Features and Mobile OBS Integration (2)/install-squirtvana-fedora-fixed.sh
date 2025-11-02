#!/bin/bash

# Squirtvana PWA - Fedora Linux Installation Script (FIXED for Fedora 42+)
# Automatische Installation aller Dependencies und Setup

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Project info
PROJECT_NAME="Squirtvana PWA"
PROJECT_DIR="$HOME/squirtvana-pwa-project"
BACKEND_DIR="$PROJECT_DIR/squirtvana-backend"
FRONTEND_DIR="$PROJECT_DIR/squirtvana-pwa"

echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║                    SQUIRTVANA PWA INSTALLER                  ║${NC}"
echo -e "${PURPLE}║                 Fedora 42+ Compatible Version                ║${NC}"
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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if package is installed
package_installed() {
    dnf list installed "$1" &>/dev/null
}

# Function to install package if not already installed
install_package() {
    local package="$1"
    if package_installed "$package"; then
        print_success "$package bereits installiert"
    else
        print_status "Installiere $package..."
        sudo dnf install -y "$package"
        if package_installed "$package"; then
            print_success "$package erfolgreich installiert"
        else
            print_error "$package Installation fehlgeschlagen"
            return 1
        fi
    fi
}

# Function to install multiple packages
install_packages() {
    local packages=("$@")
    local failed_packages=()
    
    for package in "${packages[@]}"; do
        if ! install_package "$package"; then
            failed_packages+=("$package")
        fi
    done
    
    if [ ${#failed_packages[@]} -gt 0 ]; then
        print_error "Folgende Pakete konnten nicht installiert werden: ${failed_packages[*]}"
        return 1
    fi
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "Dieses Script sollte NICHT als root ausgeführt werden!"
   print_warning "Führen Sie es als normaler Benutzer aus. sudo wird automatisch verwendet wenn nötig."
   exit 1
fi

print_status "Starte Installation von $PROJECT_NAME..."
echo ""

# Detect Fedora version
if [[ -f /etc/fedora-release ]]; then
    FEDORA_VERSION=$(cat /etc/fedora-release | grep -oP '\d+')
    print_status "Erkannte Fedora Version: $FEDORA_VERSION"
else
    print_error "Dieses Script ist nur für Fedora Linux!"
    exit 1
fi

# Update system
print_status "System-Update wird durchgeführt..."
sudo dnf update -y

# Install basic dependencies
print_status "Installiere Basis-Dependencies..."
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

install_packages "${basic_packages[@]}"

# Install Python with Fedora 42+ compatible package names
print_status "Installiere Python und pip..."

# Try different Python package combinations based on Fedora version
python_packages=()

if [[ $FEDORA_VERSION -ge 42 ]]; then
    # Fedora 42+ package names
    python_packages=(
        "python3"
        "python3-pip"
        "python3-devel"
        "python3-virtualenv"
    )
else
    # Older Fedora versions - try specific Python 3.11 packages first
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
    
    # Add pip and virtualenv
    python_packages+=(
        "python3-pip"
        "python3-virtualenv"
    )
fi

install_packages "${python_packages[@]}"

# Verify Python installation and set up aliases
print_status "Konfiguriere Python..."

# Find the best Python version
PYTHON_CMD=""
if command_exists python3.11; then
    PYTHON_CMD="python3.11"
    PYTHON_VERSION=$(python3.11 --version)
elif command_exists python3; then
    PYTHON_CMD="python3"
    PYTHON_VERSION=$(python3 --version)
else
    print_error "Keine Python-Installation gefunden!"
    exit 1
fi

print_success "Python konfiguriert: $PYTHON_VERSION (Command: $PYTHON_CMD)"

# Ensure pip is available
print_status "Überprüfe pip-Installation..."
if ! $PYTHON_CMD -m pip --version &>/dev/null; then
    print_status "Installiere pip über get-pip.py..."
    curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
    $PYTHON_CMD get-pip.py --user
    rm get-pip.py
fi

# Verify pip
if $PYTHON_CMD -m pip --version &>/dev/null; then
    PIP_VERSION=$($PYTHON_CMD -m pip --version)
    print_success "pip verfügbar: $PIP_VERSION"
else
    print_error "pip Installation fehlgeschlagen!"
    exit 1
fi

# Install Node.js and npm
print_status "Installiere Node.js und npm..."
nodejs_packages=(
    "nodejs"
    "npm"
)

install_packages "${nodejs_packages[@]}"

# Verify Node.js installation
if command_exists node && command_exists npm; then
    NODE_VERSION=$(node --version)
    NPM_VERSION=$(npm --version)
    print_success "Node.js installiert: $NODE_VERSION"
    print_success "npm installiert: $NPM_VERSION"
else
    print_error "Node.js Installation fehlgeschlagen!"
    exit 1
fi

# Install pnpm globally
print_status "Installiere pnpm..."
if command_exists pnpm; then
    print_success "pnpm bereits installiert"
else
    sudo npm install -g pnpm
    if command_exists pnpm; then
        PNPM_VERSION=$(pnpm --version)
        print_success "pnpm installiert: $PNPM_VERSION"
    else
        print_error "pnpm Installation fehlgeschlagen!"
        exit 1
    fi
fi

# Install OBS Studio
print_status "Installiere OBS Studio..."

# Try different methods to install OBS
obs_installed=false

# Method 1: Try from standard repos
if install_package "obs-studio"; then
    obs_installed=true
else
    # Method 2: Try with RPM Fusion
    print_status "Aktiviere RPM Fusion Repository für OBS..."
    if ! dnf repolist | grep -q rpmfusion; then
        sudo dnf install -y "https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" || true
        sudo dnf install -y "https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm" || true
    fi
    
    if install_package "obs-studio"; then
        obs_installed=true
    else
        # Method 3: Try Flatpak as fallback
        print_warning "Standard OBS Installation fehlgeschlagen, versuche Flatpak..."
        if command_exists flatpak; then
            flatpak install -y flathub com.obsproject.Studio || true
            if flatpak list | grep -q obs; then
                print_success "OBS Studio via Flatpak installiert"
                obs_installed=true
            fi
        fi
    fi
fi

if ! $obs_installed; then
    print_warning "OBS Studio Installation fehlgeschlagen - kann später manuell installiert werden"
fi

# Install additional media libraries
print_status "Installiere zusätzliche Media-Libraries..."
media_packages=(
    "ffmpeg"
    "gstreamer1-plugins-base"
    "gstreamer1-plugins-good"
    "gstreamer1-plugins-bad-free"
    "gstreamer1-plugins-ugly-free"
)

# Install media packages (non-critical)
for package in "${media_packages[@]}"; do
    install_package "$package" || print_warning "$package konnte nicht installiert werden"
done

# Create project directory
print_status "Erstelle Projekt-Verzeichnis..."
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Create backend structure
mkdir -p "$BACKEND_DIR"/{src/{routes,models,static},venv}

# Create backend files
print_status "Erstelle Backend-Struktur..."

# Create requirements.txt
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

# Create main.py
cat > "$BACKEND_DIR/src/main.py" << 'EOF'
import os
import sys
from pathlib import Path

# Add the src directory to Python path
sys.path.insert(0, str(Path(__file__).parent))

from flask import Flask, send_from_directory, jsonify
from flask_cors import CORS
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Import route blueprints
from routes.gpt import gpt_bp
from routes.audio import audio_bp
from routes.obs import obs_bp
from routes.stream import stream_bp
from routes.system import system_bp

app = Flask(__name__, static_folder='static', static_url_path='')

# Enable CORS for all routes
CORS(app, origins="*")

# Register blueprints
app.register_blueprint(gpt_bp, url_prefix='/api/gpt')
app.register_blueprint(audio_bp, url_prefix='/api/audio')
app.register_blueprint(obs_bp, url_prefix='/api/obs')
app.register_blueprint(stream_bp, url_prefix='/api')
app.register_blueprint(system_bp, url_prefix='/api')

# Serve React app
@app.route('/')
def serve_react_app():
    return send_from_directory(app.static_folder, 'index.html')

@app.route('/<path:path>')
def serve_react_assets(path):
    if path != "" and os.path.exists(os.path.join(app.static_folder, path)):
        return send_from_directory(app.static_folder, path)
    else:
        return send_from_directory(app.static_folder, 'index.html')

@app.route('/api/health')
def health_check():
    return jsonify({
        'status': 'healthy',
        'message': 'Squirtvana PWA Backend is running'
    })

if __name__ == '__main__':
    print("🚀 Starting Squirtvana PWA Backend...")
    print("📱 Frontend available at: http://localhost:5000")
    print("🔌 API available at: http://localhost:5000/api")
    app.run(host='0.0.0.0', port=5000, debug=True)
EOF

# Create simplified route files
mkdir -p "$BACKEND_DIR/src/routes"

# Create __init__.py files
touch "$BACKEND_DIR/src/__init__.py"
touch "$BACKEND_DIR/src/routes/__init__.py"
touch "$BACKEND_DIR/src/models/__init__.py"

# Create a simple test route for now
cat > "$BACKEND_DIR/src/routes/gpt.py" << 'EOF'
from flask import Blueprint, request, jsonify

gpt_bp = Blueprint('gpt', __name__)

@gpt_bp.route('/generate', methods=['POST'])
def generate_dirty_talk():
    try:
        data = request.get_json()
        prompt = data.get('prompt', '')
        
        if not prompt:
            return jsonify({'success': False, 'error': 'No prompt provided'})
        
        # Placeholder response for testing
        generated_text = f"AI Response to: {prompt}"
        
        return jsonify({
            'success': True,
            'generated_text': generated_text
        })
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)})

@gpt_bp.route('/status')
def gpt_status():
    return jsonify({
        'status': 'active',
        'message': 'GPT service is running'
    })
EOF

# Create other route files (simplified)
for route in audio obs stream system; do
    cat > "$BACKEND_DIR/src/routes/${route}.py" << EOF
from flask import Blueprint, jsonify

${route}_bp = Blueprint('${route}', __name__)

@${route}_bp.route('/status')
def ${route}_status():
    return jsonify({
        'status': 'active',
        'message': '${route} service is running'
    })
EOF
done

# Setup Python virtual environment
print_status "Erstelle Python Virtual Environment..."
cd "$BACKEND_DIR"

# Create virtual environment with the detected Python version
$PYTHON_CMD -m venv venv

# Activate virtual environment and install dependencies
print_status "Installiere Python-Dependencies..."
source venv/bin/activate

# Upgrade pip in virtual environment
$PYTHON_CMD -m pip install --upgrade pip

# Install requirements
$PYTHON_CMD -m pip install -r requirements.txt

print_success "Backend-Setup abgeschlossen!"

# Create frontend structure
print_status "Erstelle Frontend-Struktur..."
cd "$PROJECT_DIR"

# Create React app structure
mkdir -p "$FRONTEND_DIR"/{src/{components/ui,hooks,lib},public}

# Create package.json
cat > "$FRONTEND_DIR/package.json" << 'EOF'
{
  "name": "squirtvana-pwa",
  "private": true,
  "version": "0.0.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "lint": "eslint . --ext js,jsx --report-unused-disable-directives --max-warnings 0",
    "preview": "vite preview"
  },
  "dependencies": {
    "react": "^18.3.1",
    "react-dom": "^18.3.1"
  },
  "devDependencies": {
    "@types/react": "^18.3.12",
    "@types/react-dom": "^18.3.1",
    "@vitejs/plugin-react": "^4.3.3",
    "eslint": "^9.13.0",
    "eslint-plugin-react": "^7.37.2",
    "eslint-plugin-react-hooks": "^5.0.0",
    "eslint-plugin-react-refresh": "^0.4.14",
    "vite": "^6.0.1"
  }
}
EOF

# Install frontend dependencies
print_status "Installiere Frontend-Dependencies..."
cd "$FRONTEND_DIR"

# Try pnpm first, fallback to npm
if command_exists pnpm; then
    pnpm install || npm install
else
    npm install
fi

print_success "Frontend-Dependencies installiert!"

# Create start script with flexible Python command
print_status "Erstelle Start-Scripts..."
cat > "$PROJECT_DIR/start-squirtvana.sh" << EOF
#!/bin/bash

# Squirtvana PWA Start Script

PROJECT_DIR="$PROJECT_DIR"
BACKEND_DIR="$BACKEND_DIR"

echo "🚀 Starting Squirtvana PWA..."

# Start backend
echo "📡 Starting Backend..."
cd "\$BACKEND_DIR"
source venv/bin/activate
$PYTHON_CMD src/main.py &
BACKEND_PID=\$!

echo "✅ Backend started (PID: \$BACKEND_PID)"
echo "📱 Squirtvana PWA available at: http://localhost:5000"
echo ""
echo "Press Ctrl+C to stop..."

# Wait for interrupt
trap 'echo "🛑 Stopping Squirtvana PWA..."; kill \$BACKEND_PID; exit' INT
wait \$BACKEND_PID
EOF

chmod +x "$PROJECT_DIR/start-squirtvana.sh"

# Create desktop entry
print_status "Erstelle Desktop-Verknüpfung..."
mkdir -p "$HOME/.local/share/applications"

cat > "$HOME/.local/share/applications/squirtvana-pwa.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Squirtvana PWA
Comment=Mobile Streaming Control Center
Exec=$PROJECT_DIR/start-squirtvana.sh
Icon=applications-multimedia
Terminal=true
Categories=AudioVideo;Video;
EOF

# Create OBS configuration guide
cat > "$PROJECT_DIR/OBS-SETUP.md" << 'EOF'
# OBS Studio Setup für Squirtvana PWA

## WebSocket-Plugin aktivieren:

1. **OBS Studio öffnen**
2. **Tools → WebSocket Server Settings**
3. **Enable WebSocket server** aktivieren
4. **Server Port**: 4455 (Standard)
5. **Server Password**: Leer lassen
6. **Apply** klicken

## Text-Quelle erstellen:

1. **Sources → Add → Text (GDI+)**
2. **Name**: "DirtyTalk"
3. **Text**: "Waiting for AI generation..."
4. **Font**: Nach Wunsch anpassen
5. **OK** klicken

## Szenen erstellen:

Erstellen Sie verschiedene Szenen wie:
- "Cam 1"
- "Pussy Closeup"
- "Full Body"
- etc.

Die PWA kann dann zwischen diesen Szenen wechseln.

## Stream-Einstellungen:

Konfigurieren Sie Ihre Stream-Einstellungen in:
**Settings → Stream**
- Service: Twitch/YouTube/etc.
- Stream Key: Ihr Stream-Key

Danach können Sie über die PWA streamen!
EOF

# Create system info file
cat > "$PROJECT_DIR/SYSTEM-INFO.txt" << EOF
# Squirtvana PWA - System Information

Installation Date: $(date)
Fedora Version: $FEDORA_VERSION
Python Command: $PYTHON_CMD
Python Version: $PYTHON_VERSION
Node Version: $(node --version 2>/dev/null || echo "Not available")
npm Version: $(npm --version 2>/dev/null || echo "Not available")
pnpm Version: $(pnpm --version 2>/dev/null || echo "Not available")

Project Directory: $PROJECT_DIR
Backend Directory: $BACKEND_DIR
Frontend Directory: $FRONTEND_DIR

Start Command: $PROJECT_DIR/start-squirtvana.sh
URL: http://localhost:5000
EOF

# Final setup
print_status "Finalisiere Installation..."

# Create completion message
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    INSTALLATION ABGESCHLOSSEN!              ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
print_success "Squirtvana PWA wurde erfolgreich installiert!"
echo ""
echo -e "${BLUE}📁 Projekt-Verzeichnis:${NC} $PROJECT_DIR"
echo -e "${BLUE}🚀 Start-Command:${NC} $PROJECT_DIR/start-squirtvana.sh"
echo -e "${BLUE}🌐 URL nach Start:${NC} http://localhost:5000"
echo -e "${BLUE}🐍 Python Command:${NC} $PYTHON_CMD"
echo ""
echo -e "${YELLOW}📋 Nächste Schritte:${NC}"
echo "1. OBS Studio konfigurieren (siehe OBS-SETUP.md)"
echo "2. Squirtvana starten: $PROJECT_DIR/start-squirtvana.sh"
echo "3. Browser öffnen: http://localhost:5000"
echo ""
echo -e "${PURPLE}🎉 Viel Spaß mit Squirtvana PWA!${NC}"
echo ""
echo -e "${BLUE}💡 Tipp:${NC} Bei Problemen siehe SYSTEM-INFO.txt für Debug-Informationen"

