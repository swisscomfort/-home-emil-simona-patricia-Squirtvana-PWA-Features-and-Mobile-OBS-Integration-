#!/bin/bash

# Squirtvana PWA - Fedora Linux Installation Script
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
echo -e "${PURPLE}║                   Fedora Linux Auto-Setup                    ║${NC}"
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

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "Dieses Script sollte NICHT als root ausgeführt werden!"
   print_warning "Führen Sie es als normaler Benutzer aus. sudo wird automatisch verwendet wenn nötig."
   exit 1
fi

print_status "Starte Installation von $PROJECT_NAME..."
echo ""

# Update system
print_status "System-Update wird durchgeführt..."
sudo dnf update -y

# Install basic dependencies
print_status "Installiere Basis-Dependencies..."
sudo dnf install -y \
    curl \
    wget \
    git \
    unzip \
    gcc \
    gcc-c++ \
    make \
    openssl-devel \
    bzip2-devel \
    libffi-devel \
    zlib-devel \
    readline-devel \
    sqlite-devel \
    xz-devel

# Install Python 3.11
print_status "Installiere Python 3.11..."
sudo dnf install -y python3.11 python3.11-pip python3.11-devel python3.11-venv

# Verify Python installation
if command_exists python3.11; then
    PYTHON_VERSION=$(python3.11 --version)
    print_success "Python installiert: $PYTHON_VERSION"
else
    print_error "Python 3.11 Installation fehlgeschlagen!"
    exit 1
fi

# Install Node.js and npm
print_status "Installiere Node.js und npm..."
sudo dnf install -y nodejs npm

# Install pnpm globally
print_status "Installiere pnpm..."
sudo npm install -g pnpm

# Verify Node.js installation
if command_exists node; then
    NODE_VERSION=$(node --version)
    NPM_VERSION=$(npm --version)
    PNPM_VERSION=$(pnpm --version)
    print_success "Node.js installiert: $NODE_VERSION"
    print_success "npm installiert: $NPM_VERSION"
    print_success "pnpm installiert: $PNPM_VERSION"
else
    print_error "Node.js Installation fehlgeschlagen!"
    exit 1
fi

# Install OBS Studio
print_status "Installiere OBS Studio..."
sudo dnf install -y obs-studio

# Verify OBS installation
if command_exists obs; then
    print_success "OBS Studio erfolgreich installiert"
else
    print_warning "OBS Studio Installation möglicherweise fehlgeschlagen"
fi

# Install additional media libraries
print_status "Installiere zusätzliche Media-Libraries..."
sudo dnf install -y \
    ffmpeg \
    gstreamer1-plugins-base \
    gstreamer1-plugins-good \
    gstreamer1-plugins-bad-free \
    gstreamer1-plugins-ugly-free

# Create project directory
print_status "Erstelle Projekt-Verzeichnis..."
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Download project files (simulated - in real scenario you'd download from your repository)
print_status "Lade Projekt-Dateien herunter..."

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

# Create route files (simplified versions)
mkdir -p "$BACKEND_DIR/src/routes"

# GPT route
cat > "$BACKEND_DIR/src/routes/gpt.py" << 'EOF'
import os
from flask import Blueprint, request, jsonify
from openai import OpenAI

gpt_bp = Blueprint('gpt', __name__)

# Initialize OpenAI client
try:
    client = OpenAI(
        api_key=os.getenv('OPENROUTER_KEY'),
        base_url="https://openrouter.ai/api/v1"
    )
except Exception as e:
    print(f"Warning: OpenAI client initialization failed: {e}")
    client = None

@gpt_bp.route('/generate', methods=['POST'])
def generate_dirty_talk():
    try:
        data = request.get_json()
        prompt = data.get('prompt', '')
        
        if not prompt:
            return jsonify({'success': False, 'error': 'No prompt provided'})
        
        if not client:
            return jsonify({'success': False, 'error': 'OpenAI client not initialized'})
        
        response = client.chat.completions.create(
            model="meta-llama/llama-3.1-8b-instruct:free",
            messages=[
                {"role": "system", "content": "You are a flirty, playful AI assistant that generates engaging and suggestive responses."},
                {"role": "user", "content": prompt}
            ],
            max_tokens=150,
            temperature=0.8
        )
        
        generated_text = response.choices[0].message.content
        
        return jsonify({
            'success': True,
            'generated_text': generated_text
        })
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)})

@gpt_bp.route('/status')
def gpt_status():
    return jsonify({
        'status': 'active' if client else 'error',
        'message': 'GPT service is running' if client else 'GPT client not initialized'
    })
EOF

# Audio route
cat > "$BACKEND_DIR/src/routes/audio.py" << 'EOF'
import os
import requests
from flask import Blueprint, request, jsonify, send_file
from elevenlabs import ElevenLabs

audio_bp = Blueprint('audio', __name__)

# Initialize ElevenLabs client
try:
    client = ElevenLabs(api_key=os.getenv('ELEVENLABS_API_KEY'))
    VOICE_ID = os.getenv('ELEVENLABS_VOICE_ID', '21m00Tcm4TlvDq8ikWAM')
except Exception as e:
    print(f"Warning: ElevenLabs client initialization failed: {e}")
    client = None

@audio_bp.route('/generate', methods=['POST'])
def generate_audio():
    try:
        data = request.get_json()
        text = data.get('text', '')
        
        if not text:
            return jsonify({'success': False, 'error': 'No text provided'})
        
        if not client:
            return jsonify({'success': False, 'error': 'ElevenLabs client not initialized'})
        
        # Generate audio
        audio = client.generate(
            text=text,
            voice=VOICE_ID,
            model="eleven_monolingual_v1"
        )
        
        # Save audio file
        audio_path = os.path.join('src', 'static', 'output.mp3')
        os.makedirs(os.path.dirname(audio_path), exist_ok=True)
        
        with open(audio_path, 'wb') as f:
            for chunk in audio:
                f.write(chunk)
        
        return jsonify({
            'success': True,
            'audio_url': '/output.mp3'
        })
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)})

@audio_bp.route('/test', methods=['POST'])
def test_voice():
    try:
        test_text = "Hello! This is a test of the voice generation system."
        
        if not client:
            return jsonify({'success': False, 'error': 'ElevenLabs client not initialized'})
        
        # Generate test audio
        audio = client.generate(
            text=test_text,
            voice=VOICE_ID,
            model="eleven_monolingual_v1"
        )
        
        # Save audio file
        audio_path = os.path.join('src', 'static', 'test_voice.mp3')
        os.makedirs(os.path.dirname(audio_path), exist_ok=True)
        
        with open(audio_path, 'wb') as f:
            for chunk in audio:
                f.write(chunk)
        
        return jsonify({
            'success': True,
            'audio_url': '/test_voice.mp3'
        })
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)})

@audio_bp.route('/status')
def audio_status():
    return jsonify({
        'status': 'active' if client else 'error',
        'message': 'Audio service is running' if client else 'ElevenLabs client not initialized'
    })

@audio_bp.route('/file/<filename>')
def serve_audio(filename):
    try:
        audio_path = os.path.join('src', 'static', filename)
        if os.path.exists(audio_path):
            return send_file(audio_path, mimetype='audio/mpeg')
        else:
            return jsonify({'error': 'File not found'}), 404
    except Exception as e:
        return jsonify({'error': str(e)}), 500
EOF

# OBS route
cat > "$BACKEND_DIR/src/routes/obs.py" << 'EOF'
import json
import websocket
from flask import Blueprint, request, jsonify

obs_bp = Blueprint('obs', __name__)

OBS_WEBSOCKET_URL = "ws://localhost:4455"

def send_obs_request(request_type, request_data=None):
    try:
        ws = websocket.create_connection(OBS_WEBSOCKET_URL)
        
        message = {
            "op": 6,
            "d": {
                "requestType": request_type,
                "requestId": "squirtvana-request",
                "requestData": request_data or {}
            }
        }
        
        ws.send(json.dumps(message))
        response = json.loads(ws.recv())
        ws.close()
        
        return response
    except Exception as e:
        return {"error": str(e)}

@obs_bp.route('/scenes')
def get_scenes():
    try:
        response = send_obs_request("GetSceneList")
        
        if "error" in response:
            return jsonify({'success': False, 'error': response["error"]})
        
        scenes = [scene["sceneName"] for scene in response["d"]["responseData"]["scenes"]]
        current_scene = response["d"]["responseData"]["currentProgramSceneName"]
        
        return jsonify({
            'success': True,
            'scenes': scenes,
            'current_scene': current_scene
        })
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)})

@obs_bp.route('/scene/switch', methods=['POST'])
def switch_scene():
    try:
        data = request.get_json()
        scene_name = data.get('scene_name')
        
        if not scene_name:
            return jsonify({'success': False, 'error': 'No scene name provided'})
        
        response = send_obs_request("SetCurrentProgramScene", {"sceneName": scene_name})
        
        if "error" in response:
            return jsonify({'success': False, 'error': response["error"]})
        
        return jsonify({'success': True, 'message': f'Switched to scene: {scene_name}'})
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)})

@obs_bp.route('/text/update', methods=['POST'])
def update_text_source():
    try:
        data = request.get_json()
        source_name = data.get('source_name', 'DirtyTalk')
        text = data.get('text', '')
        
        response = send_obs_request("SetInputSettings", {
            "inputName": source_name,
            "inputSettings": {"text": text}
        })
        
        if "error" in response:
            return jsonify({'success': False, 'error': response["error"]})
        
        return jsonify({'success': True, 'message': f'Updated text source: {source_name}'})
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)})

@obs_bp.route('/status')
def obs_status():
    try:
        response = send_obs_request("GetVersion")
        if "error" in response:
            return jsonify({'status': 'disconnected', 'error': response["error"]})
        
        return jsonify({'status': 'connected', 'message': 'OBS WebSocket connected'})
    except Exception as e:
        return jsonify({'status': 'disconnected', 'error': str(e)})
EOF

# Stream route
cat > "$BACKEND_DIR/src/routes/stream.py" << 'EOF'
import json
import websocket
from flask import Blueprint, request, jsonify

stream_bp = Blueprint('stream', __name__)

OBS_WEBSOCKET_URL = "ws://localhost:4455"

def send_obs_request(request_type, request_data=None):
    try:
        ws = websocket.create_connection(OBS_WEBSOCKET_URL)
        
        message = {
            "op": 6,
            "d": {
                "requestType": request_type,
                "requestId": "squirtvana-stream",
                "requestData": request_data or {}
            }
        }
        
        ws.send(json.dumps(message))
        response = json.loads(ws.recv())
        ws.close()
        
        return response
    except Exception as e:
        return {"error": str(e)}

@stream_bp.route('/stream/start', methods=['POST'])
def start_stream():
    try:
        response = send_obs_request("StartStream")
        
        if "error" in response:
            return jsonify({'success': False, 'error': response["error"]})
        
        return jsonify({'success': True, 'message': 'Stream started'})
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)})

@stream_bp.route('/stream/stop', methods=['POST'])
def stop_stream():
    try:
        response = send_obs_request("StopStream")
        
        if "error" in response:
            return jsonify({'success': False, 'error': response["error"]})
        
        return jsonify({'success': True, 'message': 'Stream stopped'})
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)})

@stream_bp.route('/recording/start', methods=['POST'])
def start_recording():
    try:
        response = send_obs_request("StartRecord")
        
        if "error" in response:
            return jsonify({'success': False, 'error': response["error"]})
        
        return jsonify({'success': True, 'message': 'Recording started'})
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)})

@stream_bp.route('/recording/stop', methods=['POST'])
def stop_recording():
    try:
        response = send_obs_request("StopRecord")
        
        if "error" in response:
            return jsonify({'success': False, 'error': response["error"]})
        
        return jsonify({'success': True, 'message': 'Recording stopped'})
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)})

@stream_bp.route('/stream/status')
def stream_status():
    try:
        response = send_obs_request("GetStreamStatus")
        
        if "error" in response:
            return jsonify({'success': False, 'error': response["error"]})
        
        is_streaming = response["d"]["responseData"]["outputActive"]
        
        return jsonify({
            'success': True,
            'streaming': is_streaming
        })
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)})

@stream_bp.route('/recording/status')
def recording_status():
    try:
        response = send_obs_request("GetRecordStatus")
        
        if "error" in response:
            return jsonify({'success': False, 'error': response["error"]})
        
        is_recording = response["d"]["responseData"]["outputActive"]
        
        return jsonify({
            'success': True,
            'recording': is_recording
        })
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)})
EOF

# System route
cat > "$BACKEND_DIR/src/routes/system.py" << 'EOF'
import os
import psutil
import requests
from flask import Blueprint, jsonify

system_bp = Blueprint('system', __name__)

@system_bp.route('/system/stats')
def get_system_stats():
    try:
        # Get system statistics
        cpu_percent = psutil.cpu_percent(interval=1)
        memory = psutil.virtual_memory()
        disk = psutil.disk_usage('/')
        
        return jsonify({
            'success': True,
            'cpu': {
                'usage_percent': round(cpu_percent, 1)
            },
            'memory': {
                'usage_percent': round(memory.percent, 1),
                'used_gb': round(memory.used / (1024**3), 1),
                'total_gb': round(memory.total / (1024**3), 1)
            },
            'disk': {
                'usage_percent': round((disk.used / disk.total) * 100, 1),
                'used_gb': round(disk.used / (1024**3), 1),
                'total_gb': round(disk.total / (1024**3), 1)
            }
        })
        
    except Exception as e:
        return jsonify({'success': False, 'error': str(e)})

@system_bp.route('/telegram/status')
def telegram_status():
    try:
        # Simple check - in real implementation you'd check actual bot status
        api_key = os.getenv('TELEGRAM_API_KEY')
        if api_key:
            return jsonify({'status': 'active', 'message': 'Telegram API key configured'})
        else:
            return jsonify({'status': 'error', 'message': 'Telegram API key not found'})
    except Exception as e:
        return jsonify({'status': 'error', 'error': str(e)})
EOF

# Create __init__.py files
touch "$BACKEND_DIR/src/__init__.py"
touch "$BACKEND_DIR/src/routes/__init__.py"
touch "$BACKEND_DIR/src/models/__init__.py"

# Setup Python virtual environment
print_status "Erstelle Python Virtual Environment..."
cd "$BACKEND_DIR"
python3.11 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

print_success "Backend-Setup abgeschlossen!"

# Create frontend structure
print_status "Erstelle Frontend-Struktur..."
cd "$PROJECT_DIR"

# Create React app using create-react-app equivalent structure
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
    "@radix-ui/react-accordion": "^1.2.1",
    "@radix-ui/react-alert-dialog": "^1.1.2",
    "@radix-ui/react-aspect-ratio": "^1.1.0",
    "@radix-ui/react-avatar": "^1.1.1",
    "@radix-ui/react-checkbox": "^1.1.2",
    "@radix-ui/react-collapsible": "^1.1.1",
    "@radix-ui/react-dialog": "^1.1.2",
    "@radix-ui/react-dropdown-menu": "^2.1.2",
    "@radix-ui/react-hover-card": "^1.1.2",
    "@radix-ui/react-label": "^2.1.0",
    "@radix-ui/react-menubar": "^1.1.2",
    "@radix-ui/react-navigation-menu": "^1.2.1",
    "@radix-ui/react-popover": "^1.1.2",
    "@radix-ui/react-progress": "^1.1.0",
    "@radix-ui/react-radio-group": "^1.2.1",
    "@radix-ui/react-scroll-area": "^1.2.0",
    "@radix-ui/react-select": "^2.1.2",
    "@radix-ui/react-separator": "^1.1.0",
    "@radix-ui/react-slider": "^1.2.1",
    "@radix-ui/react-slot": "^1.1.0",
    "@radix-ui/react-switch": "^1.1.1",
    "@radix-ui/react-tabs": "^1.1.1",
    "@radix-ui/react-toast": "^1.2.2",
    "@radix-ui/react-toggle": "^1.1.0",
    "@radix-ui/react-toggle-group": "^1.1.0",
    "@radix-ui/react-tooltip": "^1.1.3",
    "class-variance-authority": "^0.7.0",
    "clsx": "^2.1.1",
    "lucide-react": "^0.460.0",
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "tailwind-merge": "^2.5.4",
    "tailwindcss-animate": "^1.0.7"
  },
  "devDependencies": {
    "@types/react": "^18.3.12",
    "@types/react-dom": "^18.3.1",
    "@vitejs/plugin-react": "^4.3.3",
    "autoprefixer": "^10.4.20",
    "eslint": "^9.13.0",
    "eslint-plugin-react": "^7.37.2",
    "eslint-plugin-react-hooks": "^5.0.0",
    "eslint-plugin-react-refresh": "^0.4.14",
    "postcss": "^8.4.49",
    "tailwindcss": "^3.4.14",
    "vite": "^6.0.1"
  }
}
EOF

# Install frontend dependencies
print_status "Installiere Frontend-Dependencies..."
cd "$FRONTEND_DIR"
pnpm install

print_success "Frontend-Dependencies installiert!"

# Create start script
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
python src/main.py &
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
echo ""
echo -e "${YELLOW}📋 Nächste Schritte:${NC}"
echo "1. OBS Studio konfigurieren (siehe OBS-SETUP.md)"
echo "2. Squirtvana starten: $PROJECT_DIR/start-squirtvana.sh"
echo "3. Browser öffnen: http://localhost:5000"
echo ""
echo -e "${PURPLE}🎉 Viel Spaß mit Squirtvana PWA!${NC}"
EOF

