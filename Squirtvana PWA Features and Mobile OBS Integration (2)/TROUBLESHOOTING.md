# Squirtvana PWA - Troubleshooting Guide

## 🚨 Häufige Probleme & Lösungen

### 🔧 Installation-Probleme

#### Problem: "Script kann nicht ausgeführt werden"
```bash
# Lösung 1: Berechtigung setzen
chmod +x install-squirtvana-fedora.sh

# Lösung 2: Direkt mit bash ausführen
bash install-squirtvana-fedora.sh

# Lösung 3: Als sudo (nur wenn nötig)
sudo bash install-squirtvana-fedora.sh
```

#### Problem: "Python 3.11 nicht gefunden"
```bash
# Prüfen welche Python-Versionen verfügbar sind
dnf list available | grep python3

# Alternative Installation
sudo dnf install -y python3 python3-pip python3-devel

# Script anpassen (python3 statt python3.11)
sed -i 's/python3.11/python3/g' install-squirtvana-fedora.sh
```

#### Problem: "npm/pnpm Installation fehlgeschlagen"
```bash
# Node.js Repository hinzufügen
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
sudo dnf install -y nodejs

# pnpm global installieren
sudo npm install -g pnpm

# Berechtigung prüfen
npm config get prefix
```

#### Problem: "OBS Studio nicht verfügbar"
```bash
# RPM Fusion Repository aktivieren
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm

# OBS aus RPM Fusion installieren
sudo dnf install -y obs-studio

# Alternative: Flatpak
flatpak install flathub com.obsproject.Studio
```

### 🌐 Backend-Probleme

#### Problem: "Backend startet nicht"
```bash
# Virtual Environment aktivieren
cd ~/squirtvana-pwa-project/squirtvana-backend
source venv/bin/activate

# Dependencies prüfen
pip list

# Fehlende Dependencies installieren
pip install -r requirements.txt

# Debug-Modus starten
FLASK_DEBUG=1 python src/main.py
```

#### Problem: "Port 5000 bereits belegt"
```bash
# Prüfen welcher Prozess Port 5000 verwendet
sudo netstat -tlnp | grep :5000
sudo lsof -i :5000

# Prozess beenden
sudo kill -9 <PID>

# Alternative: Anderen Port verwenden
# In src/main.py: app.run(host='0.0.0.0', port=5001, debug=True)
```

#### Problem: "ModuleNotFoundError"
```bash
# Python-Path prüfen
python -c "import sys; print(sys.path)"

# Virtual Environment neu erstellen
rm -rf venv
python3.11 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
```

### 🎨 Frontend-Probleme

#### Problem: "React App lädt nicht"
```bash
# Node.js Version prüfen
node --version
npm --version

# Dependencies neu installieren
cd ~/squirtvana-pwa-project/squirtvana-pwa
rm -rf node_modules package-lock.json
pnpm install

# Build-Prozess prüfen
pnpm run build
```

#### Problem: "Vite Build fehlgeschlagen"
```bash
# Cache löschen
rm -rf node_modules/.vite

# Memory-Limit erhöhen
export NODE_OPTIONS="--max-old-space-size=4096"

# Alternative Build-Tool
npm run build
```

#### Problem: "CSS/Styling nicht geladen"
```bash
# Tailwind CSS prüfen
npx tailwindcss --version

# PostCSS konfiguration prüfen
cat postcss.config.js

# Build neu erstellen
pnpm run build
```

### 🔌 API-Integration Probleme

#### Problem: "GPT API-Calls fehlschlagen"
```bash
# API-Key prüfen
cat ~/squirtvana-pwa-project/squirtvana-backend/.env | grep OPENROUTER

# Internet-Verbindung testen
curl -H "Authorization: Bearer $OPENROUTER_KEY" https://openrouter.ai/api/v1/models

# Backend-Logs prüfen
tail -f ~/squirtvana-pwa-project/squirtvana-backend/logs/app.log
```

#### Problem: "ElevenLabs Audio-Generierung fehlschlägt"
```bash
# API-Key validieren
curl -H "xi-api-key: $ELEVENLABS_API_KEY" https://api.elevenlabs.io/v1/voices

# Voice-ID prüfen
curl -H "xi-api-key: $ELEVENLABS_API_KEY" https://api.elevenlabs.io/v1/voices | grep voice_id

# Audio-Ordner Berechtigung
mkdir -p ~/squirtvana-pwa-project/squirtvana-backend/src/static
chmod 755 ~/squirtvana-pwa-project/squirtvana-backend/src/static
```

#### Problem: "Telegram Bot nicht erreichbar"
```bash
# Bot-Token testen
curl "https://api.telegram.org/bot$TELEGRAM_API_KEY/getMe"

# Webhook-Status prüfen
curl "https://api.telegram.org/bot$TELEGRAM_API_KEY/getWebhookInfo"

# Bot-Logs
tail -f ~/squirtvana-pwa-project/squirtvana-backend/logs/telegram.log
```

### 📹 OBS-Integration Probleme

#### Problem: "OBS WebSocket Verbindung fehlgeschlagen"
```bash
# OBS WebSocket-Plugin prüfen
obs --version

# WebSocket-Server Status
netstat -tlnp | grep 4455

# OBS mit WebSocket starten
obs --websocket-port 4455
```

#### Problem: "Szenen nicht gefunden"
```bash
# OBS-Szenen auflisten
curl -X POST http://localhost:4455 -d '{"op":6,"d":{"requestType":"GetSceneList","requestId":"test"}}'

# OBS-Konfiguration prüfen
ls ~/.config/obs-studio/basic/scenes/

# Neue Szene erstellen
# OBS → Sources → Add → Scene
```

#### Problem: "Text-Quelle Update fehlschlägt"
```bash
# Text-Quellen auflisten
curl -X POST http://localhost:4455 -d '{"op":6,"d":{"requestType":"GetInputList","requestId":"test"}}'

# Text-Quelle "DirtyTalk" erstellen
# OBS → Sources → Add → Text (GDI+) → Name: "DirtyTalk"

# Berechtigung prüfen
ls -la ~/.config/obs-studio/basic/sources/
```

### 📱 PWA-Probleme

#### Problem: "PWA nicht installierbar auf Smartphone"
```bash
# HTTPS erforderlich für PWA (außer localhost)
# Lösung 1: ngrok verwenden
ngrok http 5000

# Lösung 2: Lokales Netzwerk
ip addr show | grep inet

# Lösung 3: SSL-Zertifikat
# Für Produktion: Let's Encrypt verwenden
```

#### Problem: "Service Worker nicht registriert"
```bash
# Manifest.json prüfen
curl http://localhost:5000/manifest.json

# Service Worker prüfen
curl http://localhost:5000/sw.js

# Browser-Cache löschen
# Chrome: F12 → Application → Storage → Clear storage
```

#### Problem: "Push-Notifications funktionieren nicht"
```bash
# VAPID-Keys generieren
npm install -g web-push
web-push generate-vapid-keys

# Notification-Berechtigung prüfen
# Browser: Settings → Site Settings → Notifications
```

### 🔥 Performance-Probleme

#### Problem: "Backend langsam"
```bash
# Python-Profiling
pip install cProfile
python -m cProfile src/main.py

# Memory-Usage prüfen
pip install memory-profiler
python -m memory_profiler src/main.py

# Gunicorn für Produktion
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:5000 src.main:app
```

#### Problem: "Frontend langsam"
```bash
# Bundle-Größe analysieren
pnpm add --dev webpack-bundle-analyzer
pnpm run build --analyze

# React DevTools verwenden
# Chrome Extension: React Developer Tools

# Lighthouse-Audit
# Chrome: F12 → Lighthouse → Generate report
```

#### Problem: "OBS Performance-Probleme"
```bash
# Hardware-Encoding aktivieren
# OBS → Settings → Output → Encoder: Hardware (NVENC/VAAPI)

# CPU-Usage reduzieren
# OBS → Settings → Video → Output Resolution: 720p

# GPU-Monitoring
nvidia-smi  # Für NVIDIA
radeontop   # Für AMD
```

### 🛡️ Sicherheits-Probleme

#### Problem: "API-Keys kompromittiert"
```bash
# Neue API-Keys generieren
# OpenRouter: https://openrouter.ai/keys
# ElevenLabs: https://elevenlabs.io/app/settings
# Telegram: @BotFather

# .env-Datei aktualisieren
nano ~/squirtvana-pwa-project/squirtvana-backend/.env

# Git-History bereinigen (falls committed)
git filter-branch --force --index-filter 'git rm --cached --ignore-unmatch .env' --prune-empty --tag-name-filter cat -- --all
```

#### Problem: "Firewall blockiert Verbindungen"
```bash
# Firewall-Status prüfen
sudo firewall-cmd --state

# Port 5000 öffnen
sudo firewall-cmd --permanent --add-port=5000/tcp
sudo firewall-cmd --reload

# Firewall-Regeln anzeigen
sudo firewall-cmd --list-all
```

### 📊 Monitoring & Debugging

#### Problem: "System-Ressourcen überwachen"
```bash
# CPU/Memory/Disk
htop
iotop
df -h

# Netzwerk
iftop
netstat -i

# Logs
journalctl -f
tail -f /var/log/messages
```

#### Problem: "Debug-Informationen sammeln"
```bash
# System-Info
uname -a
cat /etc/fedora-release
python3 --version
node --version

# Squirtvana-Status
ps aux | grep python
ps aux | grep node
netstat -tlnp | grep 5000

# Log-Sammlung
mkdir ~/squirtvana-debug
cp ~/.config/obs-studio/logs/* ~/squirtvana-debug/
cp ~/squirtvana-pwa-project/squirtvana-backend/logs/* ~/squirtvana-debug/
journalctl --since "1 hour ago" > ~/squirtvana-debug/system.log
```

## 🆘 Notfall-Recovery

### Komplette Neuinstallation
```bash
# Altes Projekt entfernen
rm -rf ~/squirtvana-pwa-project

# Cache löschen
rm -rf ~/.cache/pip
rm -rf ~/.npm
rm -rf ~/.pnpm-store

# Neuinstallation
./install-squirtvana-fedora.sh
```

### Backup & Restore
```bash
# Backup erstellen
tar -czf squirtvana-backup-$(date +%Y%m%d).tar.gz ~/squirtvana-pwa-project

# Restore
tar -xzf squirtvana-backup-*.tar.gz -C ~/
```

## 📞 Support kontaktieren

Wenn alle Lösungsversuche fehlschlagen:

1. **Debug-Informationen sammeln** (siehe oben)
2. **Screenshots/Videos** von Fehlern erstellen
3. **Genaue Fehlermeldungen** kopieren
4. **System-Informationen** bereitstellen

**Kontakt:**
- 📧 Email: support@squirtvana.com
- 💬 Discord: discord.gg/squirtvana
- 🐛 GitHub Issues: github.com/squirtvana/issues

---

**Tipp:** Die meisten Probleme lassen sich durch eine Neuinstallation lösen! 🔄

