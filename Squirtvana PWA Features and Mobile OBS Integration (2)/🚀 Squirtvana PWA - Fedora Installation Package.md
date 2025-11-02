# 🚀 Squirtvana PWA - Fedora Installation Package

## 📦 Was ist enthalten?

Dieses Installations-Paket enthält alles, was Sie für die automatische Installation von Squirtvana PWA auf Fedora Linux benötigen:

### 📋 Dateien im Paket:

| Datei | Beschreibung |
|-------|-------------|
| `install-squirtvana-fedora.sh` | **Haupt-Installations-Script** - Installiert alles automatisch |
| `system-check.sh` | **System-Prüfung** - Überprüft Voraussetzungen und Installation |
| `FEDORA-INSTALLATION-GUIDE.md` | **Detaillierte Anleitung** - Schritt-für-Schritt Installation |
| `TROUBLESHOOTING.md` | **Problemlösung** - Häufige Probleme und Lösungen |
| `squirtvana-fixed-contrast.zip` | **Projekt-Dateien** - Vollständiger Quellcode |

## ⚡ Schnell-Installation (Empfohlen)

### 1. System prüfen (Optional)
```bash
./system-check.sh
```

### 2. Installation starten
```bash
./install-squirtvana-fedora.sh
```

### 3. Nach der Installation
```bash
# Squirtvana starten
~/squirtvana-pwa-project/start-squirtvana.sh

# Browser öffnen
firefox http://localhost:5000
```

## 📋 Voraussetzungen

### System
- **OS**: Fedora 38+ (64-bit)
- **RAM**: 4 GB (8 GB empfohlen)
- **Disk**: 2 GB freier Speicher (5 GB empfohlen)
- **Internet**: Für API-Calls erforderlich

### Benutzer-Berechtigung
- **Normaler Benutzer** (nicht root)
- **sudo-Berechtigung** für System-Pakete

## 🎯 Was wird installiert?

### System-Dependencies
- ✅ Python 3.11 + pip + venv
- ✅ Node.js + npm + pnpm
- ✅ Git, curl, wget, unzip
- ✅ Build-Tools (gcc, make, etc.)
- ✅ OBS Studio + FFmpeg

### Squirtvana PWA
- ✅ Flask Backend mit API-Routen
- ✅ React Frontend (PWA)
- ✅ Alle Python/Node.js Dependencies
- ✅ Vorkonfigurierte API-Schlüssel
- ✅ Desktop-Verknüpfung

## 🔧 Manuelle Installation

Falls das automatische Script fehlschlägt, folgen Sie der detaillierten Anleitung in `FEDORA-INSTALLATION-GUIDE.md`.

## 🆘 Probleme?

1. **Erst prüfen**: `./system-check.sh`
2. **Troubleshooting**: Siehe `TROUBLESHOOTING.md`
3. **Support**: support@squirtvana.com

## 📱 Nach der Installation

### OBS Studio konfigurieren
1. OBS öffnen
2. Tools → WebSocket Server Settings
3. Enable WebSocket server ✅
4. Port: 4455, Password: (leer)

### PWA testen
1. Text in DirtyTalk Generator eingeben
2. "Generate Response" klicken
3. "Test Voice" für Audio-Test
4. OBS-Szenen wechseln

### Smartphone-Installation
1. Browser öffnen: `http://YOUR-IP:5000`
2. "Zur Startseite hinzufügen"
3. App-Icon auf Homescreen

## 🔐 Sicherheit

- ✅ API-Keys sind vorkonfiguriert (für Demo)
- ⚠️ Für Produktion: Eigene API-Keys verwenden
- 🔒 .env-Datei nicht öffentlich teilen

## 📊 Features

### 🧠 KI-Integration
- GPT DirtyTalk-Generator
- ElevenLabs Text-zu-Sprache
- Automatische OBS Text-Updates

### 📹 OBS-Steuerung
- Szenen-Wechsel
- Stream/Recording Start/Stop
- Text-Quellen Updates
- Live-Status-Monitoring

### 📱 PWA-Features
- Mobile-optimierte UI
- Installierbar auf Smartphones
- Touch-optimierte Bedienung
- Offline-Funktionalität

## 🎉 Viel Erfolg!

Nach der Installation haben Sie eine vollständige mobile Streaming-Kontrollzentrale!

---

**Made with ❤️ for the Streaming Community**

**Version**: 1.0.0  
**Datum**: $(date +%Y-%m-%d)  
**Support**: support@squirtvana.com

