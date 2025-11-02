#!/bin/bash

# Squirtvana PWA - Einfacher Start für Fedora
# Dieses Script installiert alles und startet die Anwendung

echo "🚀 Squirtvana PWA - Einfacher Start für Fedora"
echo "=============================================="

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

print_error() {
    echo -e "${RED}[FEHLER]${NC} $1"
}

# 1. Python und pip installieren
print_status "Installiere Python und pip..."
sudo dnf install -y python3 python3-pip python3-venv

if [ $? -eq 0 ]; then
    print_success "Python installiert"
else
    print_error "Python Installation fehlgeschlagen"
    exit 1
fi

# 2. OBS Studio installieren (optional)
print_status "Installiere OBS Studio..."
sudo dnf install -y obs-studio

if [ $? -eq 0 ]; then
    print_success "OBS Studio installiert"
else
    print_error "OBS Installation fehlgeschlagen (optional)"
fi

# 3. Virtual Environment erstellen
print_status "Erstelle Python Virtual Environment..."
cd backend
python3 -m venv venv

if [ $? -eq 0 ]; then
    print_success "Virtual Environment erstellt"
else
    print_error "Virtual Environment fehlgeschlagen"
    exit 1
fi

# 4. Dependencies installieren
print_status "Installiere Python Dependencies..."
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

if [ $? -eq 0 ]; then
    print_success "Dependencies installiert"
else
    print_error "Dependencies Installation fehlgeschlagen"
    exit 1
fi

# 5. Static Ordner erstellen
mkdir -p static

# 6. PWA Manifest erstellen
cat > static/manifest.json << 'EOF'
{
  "name": "Squirtvana PWA",
  "short_name": "Squirtvana",
  "description": "Mobile Streaming Control Center",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#667eea",
  "theme_color": "#8b5cf6",
  "icons": [
    {
      "src": "data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iMTkyIiBoZWlnaHQ9IjE5MiIgdmlld0JveD0iMCAwIDE5MiAxOTIiIGZpbGw9Im5vbmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyI+CjxyZWN0IHdpZHRoPSIxOTIiIGhlaWdodD0iMTkyIiByeD0iMjQiIGZpbGw9InVybCgjZ3JhZGllbnQwX2xpbmVhcl8xXzEpIi8+CjxkZWZzPgo8bGluZWFyR3JhZGllbnQgaWQ9ImdyYWRpZW50MF9saW5lYXJfMV8xIiB4MT0iMCIgeTE9IjAiIHgyPSIxOTIiIHkyPSIxOTIiIGdyYWRpZW50VW5pdHM9InVzZXJTcGFjZU9uVXNlIj4KPHN0b3Agc3RvcC1jb2xvcj0iIzY2N2VlYSIvPgo8c3RvcCBvZmZzZXQ9IjEiIHN0b3AtY29sb3I9IiM3NjRiYTIiLz4KPC9saW5lYXJHcmFkaWVudD4KPC9kZWZzPgo8L3N2Zz4K",
      "sizes": "192x192",
      "type": "image/svg+xml"
    }
  ]
}
EOF

print_success "PWA Manifest erstellt"

# 7. Anwendung starten
echo ""
echo -e "${PURPLE}🎉 Installation abgeschlossen!${NC}"
echo ""
echo -e "${GREEN}Starte Squirtvana PWA...${NC}"
echo ""
echo -e "${YELLOW}📱 Frontend: http://localhost:5000${NC}"
echo -e "${YELLOW}🔌 API: http://localhost:5000/api/health${NC}"
echo ""
echo -e "${BLUE}💡 Tipps:${NC}"
echo "   • OBS Studio öffnen für volle Funktionalität"
echo "   • PWA auf Handy installieren: Browser → 'Zur Startseite hinzufügen'"
echo "   • Ctrl+C zum Beenden"
echo ""

# Flask App starten
python3 app.py

