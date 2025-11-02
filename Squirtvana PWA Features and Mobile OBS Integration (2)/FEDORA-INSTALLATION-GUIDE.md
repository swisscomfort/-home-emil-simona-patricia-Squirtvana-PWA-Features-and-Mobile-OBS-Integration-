# Squirtvana PWA - Fedora Linux Installation Guide

## 🐧 Automatische Installation

### Schnell-Installation (Empfohlen)

```bash
# 1. Script herunterladen
wget https://raw.githubusercontent.com/your-repo/squirtvana-pwa/main/install-squirtvana-fedora.sh

# 2. Ausführbar machen
chmod +x install-squirtvana-fedora.sh

# 3. Installation starten
./install-squirtvana-fedora.sh
```

### Was wird installiert?

Das Script installiert automatisch:

#### System-Dependencies
- ✅ Python 3.11 + pip + venv
- ✅ Node.js + npm + pnpm
- ✅ Git, curl, wget, unzip
- ✅ Build-Tools (gcc, make, etc.)
- ✅ Development-Libraries

#### Media & Streaming
- ✅ OBS Studio
- ✅ FFmpeg
- ✅ GStreamer-Plugins

#### Squirtvana PWA
- ✅ Backend (Flask API)
- ✅ Frontend (React PWA)
- ✅ Alle Python-Dependencies
- ✅ Alle Node.js-Dependencies
- ✅ API-Schlüssel (vorkonfiguriert)

## 📋 System-Anforderungen

### Minimum
- **OS**: Fedora 38+ (64-bit)
- **RAM**: 4 GB
- **Disk**: 2 GB freier Speicher
- **CPU**: Dual-Core 2.0 GHz
- **Internet**: Für API-Calls erforderlich

### Empfohlen
- **OS**: Fedora 39+ (64-bit)
- **RAM**: 8 GB+
- **Disk**: 5 GB+ freier Speicher
- **CPU**: Quad-Core 2.5 GHz+
- **GPU**: Für OBS Hardware-Encoding

## 🚀 Nach der Installation

### 1. OBS Studio konfigurieren

```bash
# OBS starten
obs

# WebSocket aktivieren:
# Tools → WebSocket Server Settings
# ✅ Enable WebSocket server
# Port: 4455
# Password: (leer lassen)
```

### 2. Squirtvana starten

```bash
# Automatischer Start
~/squirtvana-pwa-project/start-squirtvana.sh

# Oder manuell:
cd ~/squirtvana-pwa-project/squirtvana-backend
source venv/bin/activate
python src/main.py
```

### 3. PWA öffnen

```bash
# Browser öffnen
firefox http://localhost:5000

# Oder
google-chrome http://localhost:5000
```

## 📱 PWA auf Smartphone installieren

### Android
1. Chrome öffnen → `http://YOUR-IP:5000`
2. Menü → "Zur Startseite hinzufügen"
3. App-Icon erscheint auf Homescreen

### iOS
1. Safari öffnen → `http://YOUR-IP:5000`
2. Teilen-Button → "Zum Home-Bildschirm"
3. App-Icon erscheint auf Homescreen

## 🔧 Manuelle Installation (Falls Script fehlschlägt)

### 1. System-Updates

```bash
sudo dnf update -y
```

### 2. Dependencies installieren

```bash
# Build-Tools
sudo dnf install -y gcc gcc-c++ make openssl-devel bzip2-devel libffi-devel zlib-devel

# Python 3.11
sudo dnf install -y python3.11 python3.11-pip python3.11-devel python3.11-venv

# Node.js
sudo dnf install -y nodejs npm
sudo npm install -g pnpm

# OBS Studio
sudo dnf install -y obs-studio

# Media-Libraries
sudo dnf install -y ffmpeg gstreamer1-plugins-base gstreamer1-plugins-good
```

### 3. Projekt-Setup

```bash
# Projekt-Verzeichnis erstellen
mkdir -p ~/squirtvana-pwa-project
cd ~/squirtvana-pwa-project

# Backend-Setup
mkdir -p squirtvana-backend/src/{routes,models,static}
cd squirtvana-backend

# Virtual Environment
python3.11 -m venv venv
source venv/bin/activate

# Dependencies installieren
pip install flask flask-cors openai requests websocket-client python-telegram-bot elevenlabs psutil python-dotenv

# Frontend-Setup
cd ../
mkdir -p squirtvana-pwa/src/{components/ui,hooks,lib}
cd squirtvana-pwa
pnpm init
pnpm add react react-dom @vitejs/plugin-react vite tailwindcss
```

## 🛠️ Troubleshooting

### Problem: "Permission denied"
```bash
# Script ausführbar machen
chmod +x install-squirtvana-fedora.sh

# Oder als sudo ausführen (nicht empfohlen)
sudo ./install-squirtvana-fedora.sh
```

### Problem: "Python 3.11 not found"
```bash
# Alternative Python-Installation
sudo dnf install -y python3-devel python3-pip
# Script mit python3 statt python3.11 anpassen
```

### Problem: "OBS WebSocket connection failed"
```bash
# OBS WebSocket prüfen
obs --help

# Port prüfen
netstat -tlnp | grep 4455

# OBS neu starten
killall obs
obs
```

### Problem: "npm/pnpm not found"
```bash
# Node.js neu installieren
sudo dnf remove -y nodejs npm
sudo dnf install -y nodejs npm
sudo npm install -g pnpm
```

### Problem: "API calls failing"
```bash
# Internet-Verbindung prüfen
ping google.com

# API-Keys prüfen
cat ~/squirtvana-pwa-project/squirtvana-backend/.env

# Backend-Logs prüfen
cd ~/squirtvana-pwa-project/squirtvana-backend
source venv/bin/activate
python src/main.py
```

## 🔐 Sicherheit

### API-Schlüssel
- ✅ Alle API-Keys sind vorkonfiguriert
- ⚠️ Für Produktion: Eigene Keys verwenden
- 🔒 .env-Datei nicht öffentlich teilen

### Firewall
```bash
# Port 5000 für lokales Netzwerk öffnen
sudo firewall-cmd --permanent --add-port=5000/tcp
sudo firewall-cmd --reload

# Nur für lokale Nutzung (sicherer)
# Keine Firewall-Änderung nötig
```

## 📊 Performance-Optimierung

### System-Tuning
```bash
# Mehr RAM für Node.js
export NODE_OPTIONS="--max-old-space-size=4096"

# Python-Optimierung
export PYTHONOPTIMIZE=1

# OBS Hardware-Encoding aktivieren
# Settings → Output → Hardware (NVENC/VAAPI)
```

### Monitoring
```bash
# System-Ressourcen überwachen
htop

# Netzwerk-Traffic
iftop

# Disk-Usage
df -h
```

## 🆘 Support

### Log-Dateien
```bash
# Backend-Logs
tail -f ~/squirtvana-pwa-project/squirtvana-backend/app.log

# System-Logs
journalctl -f

# OBS-Logs
tail -f ~/.config/obs-studio/logs/
```

### Debug-Modus
```bash
# Backend mit Debug
cd ~/squirtvana-pwa-project/squirtvana-backend
source venv/bin/activate
FLASK_DEBUG=1 python src/main.py

# Frontend mit Debug
cd ~/squirtvana-pwa-project/squirtvana-pwa
pnpm run dev
```

### Community
- 📧 Email: support@squirtvana.com
- 💬 Discord: discord.gg/squirtvana
- 🐛 Issues: github.com/squirtvana/issues

## 📝 Changelog

### v1.0.0 (Initial Release)
- ✅ Automatische Fedora-Installation
- ✅ Vollständige PWA-Funktionalität
- ✅ OBS-Integration
- ✅ API-Integration (GPT, ElevenLabs, Telegram)
- ✅ Mobile-optimierte UI

---

**Made with ❤️ for the Streaming Community**

