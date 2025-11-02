# Squirtvana PWA - Mobile Streaming Control Center

## 🎯 Projektübersicht

Squirtvana ist eine vollständige Progressive Web App (PWA) für die mobile Steuerung von Streaming-Funktionen. Die App bietet eine intuitive mobile Benutzeroberfläche zur Kontrolle von OBS, KI-gestützter Content-Generierung, Audio-Ausgabe und Stream-Management.

## ✨ Hauptfunktionen

### 🧠 KI-Integration
- **GPT DirtyTalk Generator**: Text-zu-Text Generierung über OpenRouter API
- **Automatische OBS Text-Aktualisierung**: Generierte Inhalte werden automatisch in OBS-Textquellen eingefügt

### 🎵 Audio-Steuerung
- **ElevenLabs Integration**: Text-zu-Sprache Konvertierung
- **Audio-Wiedergabe**: Direkte Wiedergabe generierter Audio-Dateien
- **Voice-Test Funktion**: Schnelle Sprachausgabe-Tests

### 📹 OBS-Steuerung
- **Szenen-Wechsel**: Dropdown-Auswahl und Wechsel zwischen OBS-Szenen
- **WebSocket-Integration**: Echtzeitsteuerung von OBS Studio
- **Textquellen-Update**: Automatische Aktualisierung von Text-Overlays

### 🎥 Stream & Recording
- **Live-Stream Kontrolle**: Start/Stop von OBS-Streams
- **Aufnahme-Steuerung**: Recording-Funktionen mit Pause/Resume
- **Echtzeit-Status**: Live-Anzeige von Stream- und Recording-Status

### 📊 System-Monitoring
- **Ressourcen-Überwachung**: CPU, RAM, Disk-Usage
- **Service-Status**: Überwachung aller integrierten Services
- **Telegram Bot Status**: Verbindungsstatus zum Telegram Bot

## 🏗️ Architektur

### Backend (Flask API)
```
squirtvana-backend/
├── src/
│   ├── routes/
│   │   ├── gpt.py          # GPT/OpenRouter Integration
│   │   ├── audio.py        # ElevenLabs Audio-Generierung
│   │   ├── obs.py          # OBS WebSocket-Steuerung
│   │   ├── stream.py       # Stream/Recording-Kontrolle
│   │   ├── system.py       # System-Monitoring
│   │   └── user.py         # User-Management (Template)
│   ├── models/             # Datenbank-Modelle
│   ├── static/             # Frontend-Build (PWA)
│   └── main.py             # Flask-Hauptanwendung
├── .env                    # API-Schlüssel und Konfiguration
└── requirements.txt        # Python-Dependencies
```

### Frontend (React PWA)
```
squirtvana-pwa/
├── src/
│   ├── components/ui/      # shadcn/ui Komponenten
│   ├── App.jsx            # Haupt-PWA-Interface
│   ├── App.css            # Tailwind CSS Styles
│   └── main.jsx           # React Entry Point
├── public/
│   └── manifest.json      # PWA-Manifest
└── index.html             # HTML Entry Point
```

## 🔧 Installation & Setup

### 1. Backend-Setup
```bash
cd squirtvana-backend
source venv/bin/activate
pip install -r requirements.txt
```

### 2. Umgebungsvariablen (.env)
```env
OPENROUTER_KEY=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
TELEGRAM_API_KEY=7512900295:AAHhwRKamqq9gQj55LNF3mbKV63IQuJ8dQY
ELEVENLABS_API_KEY=sk_226e2f2cec752de5561266ae5043937dc08a7e52597ec069
ELEVENLABS_VOICE_ID=21m00Tcm4TlvDq8ikWAM
```

### 3. OBS-Konfiguration
- OBS Studio installieren
- WebSocket-Plugin aktivieren (OBS 28+ hat es eingebaut)
- WebSocket-Server auf Port 4455 starten
- Text-Quelle "DirtyTalk" erstellen

### 4. Backend starten
```bash
cd squirtvana-backend
source venv/bin/activate
python src/main.py
```
Backend läuft auf: `http://localhost:5000`

### 5. Frontend-Entwicklung (optional)
```bash
cd squirtvana-pwa
pnpm install
pnpm run dev
```
Frontend läuft auf: `http://localhost:5174`

## 📱 PWA-Features

### Mobile-First Design
- Responsive Layout für alle Bildschirmgrößen
- Touch-optimierte Bedienelemente
- Gradient-Design (Purple/Pink/Black)

### Progressive Web App
- Installierbar auf mobilen Geräten
- Offline-fähige Basis-Funktionen
- App-ähnliche Benutzerererfahrung

### Status-Monitoring
- Echtzeit-Systemstatistiken
- Service-Verbindungsstatus
- Visuelle Status-Indikatoren

## 🔌 API-Endpunkte

### GPT-Integration
- `POST /api/gpt/generate` - DirtyTalk generieren
- `GET /api/gpt/status` - GPT-Service Status

### Audio-Steuerung
- `POST /api/audio/generate` - Audio aus Text generieren
- `POST /api/audio/test` - Voice-Test ausführen
- `GET /api/audio/file/{filename}` - Audio-Datei abrufen
- `GET /api/audio/status` - Audio-Service Status

### OBS-Steuerung
- `GET /api/obs/scenes` - Verfügbare Szenen abrufen
- `POST /api/obs/scene/switch` - Szene wechseln
- `POST /api/obs/text/update` - Text-Quelle aktualisieren
- `GET /api/obs/status` - OBS-Verbindungsstatus

### Stream-Kontrolle
- `POST /api/stream/start` - Live-Stream starten
- `POST /api/stream/stop` - Live-Stream stoppen
- `GET /api/stream/status` - Stream-Status abrufen
- `POST /api/recording/start` - Aufnahme starten
- `POST /api/recording/stop` - Aufnahme stoppen
- `GET /api/recording/status` - Aufnahme-Status abrufen

### System-Monitoring
- `GET /api/system/stats` - System-Ressourcen
- `GET /api/telegram/status` - Telegram-Bot Status
- `GET /api/health` - Gesundheitscheck

## 🎨 UI-Komponenten

### Hauptbereiche
1. **System Status** - Service-Überwachung mit Farbindikatoren
2. **DirtyTalk Generator** - Text-Input und KI-Generierung
3. **Audio Controls** - Mikrofon, Play, Test-Buttons
4. **Scene Control** - OBS-Szenen Dropdown und Switch-Button
5. **Stream & Recording** - Start/Stop-Buttons mit Live-Indikatoren
6. **Refresh Status** - Manuelle Status-Aktualisierung

### Design-System
- **Farben**: Purple/Pink Gradient auf schwarzem Hintergrund
- **Komponenten**: shadcn/ui mit Tailwind CSS
- **Icons**: Lucide React Icons
- **Typography**: Gradient-Text für Titel

## 🔒 Sicherheit

### API-Schlüssel
- Alle API-Schlüssel in .env-Datei
- Keine Hardcoded-Credentials im Code
- Environment-basierte Konfiguration

### CORS-Konfiguration
- Cross-Origin-Requests für Frontend-Backend-Kommunikation
- Sichere API-Endpunkt-Konfiguration

## 🚀 Deployment

### Lokale Entwicklung
1. Backend und Frontend separat starten
2. API-Base auf `http://localhost:5000/api` setzen

### Produktions-Deployment
1. Frontend builden: `pnpm run build`
2. Build-Files in Flask static/ kopieren
3. API-Base auf relative Pfade setzen (`/api`)
4. Flask-App deployen

### Cloud-Deployment
- Dependency-Konflikte in Cloud-Umgebungen möglich
- Lokale Entwicklung empfohlen
- Docker-Container für konsistente Umgebung

## 🛠️ Troubleshooting

### Häufige Probleme

**OBS-Verbindung fehlgeschlagen**
- WebSocket-Plugin aktiviert?
- Port 4455 verfügbar?
- OBS läuft?

**Audio-Generierung fehlgeschlagen**
- ElevenLabs API-Key korrekt?
- Voice-ID existiert?
- Internet-Verbindung?

**GPT-Generierung fehlgeschlagen**
- OpenRouter API-Key gültig?
- Model verfügbar?
- Rate-Limits erreicht?

### Debug-Tipps
- Browser-Konsole für Frontend-Fehler
- Flask-Logs für Backend-Fehler
- Network-Tab für API-Call-Status

## 📋 Erweiterungsmöglichkeiten

### Geplante Features
- **Lovense-Integration**: Vibrator-Steuerung
- **Szene-Automation**: KI-basierte Szenen-Auswahl
- **Voice-Clips Archiv**: Sprachausgaben speichern
- **Token-Zahlungen**: Web3-Integration für Viewer-Aktionen
- **Multi-Language**: Mehrsprachige Unterstützung

### Technische Verbesserungen
- WebSocket-Verbindung für Echtzeit-Updates
- Offline-Funktionalität erweitern
- Push-Notifications
- Erweiterte Analytics

## 📞 Support

Bei Fragen oder Problemen:
1. Logs überprüfen (Browser-Konsole + Flask-Terminal)
2. API-Schlüssel validieren
3. Service-Status in der App überprüfen
4. OBS-WebSocket-Verbindung testen

## 📄 Lizenz

Dieses Projekt wurde für private/kommerzielle Nutzung entwickelt. Alle API-Schlüssel und Credentials sind im Projekt enthalten und einsatzbereit.

