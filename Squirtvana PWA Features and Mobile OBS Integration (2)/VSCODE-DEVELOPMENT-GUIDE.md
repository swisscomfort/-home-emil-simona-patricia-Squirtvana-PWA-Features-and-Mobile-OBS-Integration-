# 💻 Squirtvana PWA - Visual Studio Code Development Guide

**Vollständige Entwicklungsumgebung für Visual Studio Code**

## 🚀 **Schnellstart:**

### **1. Projekt in VSCode öffnen:**
```bash
# Workspace öffnen
code squirtvana-workspace.code-workspace

# Oder Ordner öffnen
code .
```

### **2. Empfohlene Extensions installieren:**
VSCode wird automatisch vorschlagen, die empfohlenen Extensions zu installieren. Klicken Sie auf **"Install All"**.

### **3. Projekt starten:**
- **Ctrl+Shift+P** → "Tasks: Run Task" → "🚀 Start Squirtvana (Full Stack)"
- Oder **F1** → "🚀 Start Squirtvana (Full Stack)"

## 🎯 **VSCode Features:**

### **📁 Multi-Root Workspace:**
Das Projekt ist als Multi-Root Workspace konfiguriert:
- **🎯 Root**: Gesamtprojekt-Übersicht
- **⚛️ Frontend**: React-Entwicklung
- **🐍 Backend**: Python/Flask-Entwicklung

### **⚡ Vordefinierte Tasks:**
| Task | Beschreibung | Shortcut |
|------|-------------|----------|
| 🚀 Start Squirtvana | Vollständiges System starten | Ctrl+Shift+P → Tasks |
| ⚛️ Frontend: Dev Server | React Development Server | F1 → Frontend Dev |
| 🐍 Backend: Start Server | Flask Development Server | F1 → Backend Start |
| 📦 Build & Deploy | Frontend bauen und deployen | F1 → Build Deploy |
| 🔧 System Check | System-Voraussetzungen prüfen | F1 → System Check |

### **🐛 Debug-Konfigurationen:**
| Debug Config | Beschreibung | Verwendung |
|-------------|-------------|------------|
| 🐍 Debug Backend | Flask-App debuggen | F5 im Backend |
| ⚛️ Debug Frontend | React-App in Chrome debuggen | F5 im Frontend |
| 🚀 Full Stack Debug | Beide gleichzeitig debuggen | F5 im Root |
| 🧪 Debug Tests | Python-Tests debuggen | F5 bei Tests |

## 🛠️ **Entwicklungsworkflow:**

### **Frontend-Entwicklung (React):**
```bash
# 1. Dependencies installieren
Ctrl+Shift+P → "⚛️ Frontend: Install Dependencies"

# 2. Development Server starten
Ctrl+Shift+P → "⚛️ Frontend: Dev Server"

# 3. Code bearbeiten in src/
# Hot Reload ist aktiviert

# 4. Build für Production
Ctrl+Shift+P → "⚛️ Frontend: Build Production"
```

### **Backend-Entwicklung (Python/Flask):**
```bash
# 1. Virtual Environment erstellen
Ctrl+Shift+P → "🐍 Backend: Create Virtual Environment"

# 2. Dependencies installieren
Ctrl+Shift+P → "🐍 Backend: Install Dependencies"

# 3. Development Server starten
Ctrl+Shift+P → "🐍 Backend: Start Development Server"

# 4. Code bearbeiten in src/
# Auto-Reload ist aktiviert
```

### **Full-Stack-Entwicklung:**
```bash
# 1. Komplettes System starten
Ctrl+Shift+P → "🚀 Start Squirtvana (Full Stack)"

# 2. Debugging starten
F5 → "🚀 Full Stack Debug"

# 3. Beide Teile gleichzeitig entwickeln
```

## 🔧 **VSCode-Konfiguration:**

### **Automatische Formatierung:**
- **Python**: Black Formatter (88 Zeichen)
- **JavaScript/React**: Prettier
- **Format on Save**: Aktiviert
- **Auto Import**: Aktiviert

### **Linting & Code Quality:**
- **Python**: Pylint + Flake8
- **JavaScript**: ESLint
- **Auto Fix on Save**: Aktiviert

### **IntelliSense & Autocomplete:**
- **Python**: Vollständige Typprüfung
- **React**: TypeScript-ähnliche Unterstützung
- **Tailwind CSS**: Klassen-Autocomplete
- **API**: REST Client für API-Tests

### **Terminal-Integration:**
- **Python**: Automatische venv-Aktivierung
- **Node.js**: npm/pnpm-Integration
- **Multi-Terminal**: Separate Terminals für Frontend/Backend

## 📂 **Projektstruktur in VSCode:**

```
squirtvana-vscode-dev/
├── .vscode/                          # VSCode-Konfiguration
│   ├── settings.json                 # Workspace-Einstellungen
│   ├── tasks.json                    # Build/Run-Tasks
│   ├── launch.json                   # Debug-Konfigurationen
│   └── extensions.json               # Empfohlene Extensions
├── squirtvana-workspace.code-workspace # Multi-Root Workspace
├── squirtvana-complete-frontend/     # React Frontend
│   ├── src/                          # React-Quellcode
│   ├── package.json                  # npm-Konfiguration
│   ├── vite.config.js               # Vite-Build-Konfiguration
│   └── tailwind.config.js           # Tailwind CSS
├── squirtvana-backend/               # Flask Backend
│   ├── src/                          # Python-Quellcode
│   ├── requirements.txt              # Python-Dependencies
│   ├── .env                          # Umgebungsvariablen
│   └── venv/                         # Virtual Environment
└── 📖 Dokumentation & Scripts
```

## 🎨 **Theme & Appearance:**

### **Empfohlene Themes:**
- **Color Theme**: One Dark Pro
- **Icon Theme**: Material Icon Theme
- **Custom Colors**: Purple/Pink Squirtvana-Branding

### **Workspace-Farben:**
- **Title Bar**: Purple (#8b5cf6)
- **Status Bar**: Purple (#8b5cf6)
- **Activity Bar**: Dark Blue (#1e1b4b)

## 🔌 **Extensions-Guide:**

### **Essential Extensions (Auto-Install):**
- **Python**: ms-python.python
- **Prettier**: esbenp.prettier-vscode
- **ESLint**: dbaeumer.vscode-eslint
- **Tailwind CSS**: bradlc.vscode-tailwindcss
- **Thunder Client**: rangav.vscode-thunder-client

### **Productivity Extensions:**
- **GitLens**: eamodio.gitlens
- **GitHub Copilot**: github.copilot
- **Todo Tree**: gruntfuggly.todo-tree
- **Bookmarks**: alefragnani.bookmarks

### **API Development:**
- **REST Client**: humao.rest-client
- **Thunder Client**: rangav.vscode-thunder-client
- **OpenAPI**: 42crunch.vscode-openapi

## 🧪 **Testing & Debugging:**

### **Frontend Testing:**
```bash
# ESLint prüfen
Ctrl+Shift+P → "⚛️ Frontend: Lint"

# Build testen
Ctrl+Shift+P → "⚛️ Frontend: Build Production"
```

### **Backend Testing:**
```bash
# Python Tests ausführen
Ctrl+Shift+P → "🐍 Backend: Run Tests"

# Code formatieren
Ctrl+Shift+P → "🐍 Backend: Format Code (Black)"
```

### **API Testing:**
1. **Thunder Client** verwenden (Extension)
2. **REST Client** Files erstellen (.http)
3. **Debug-Modus** für Live-API-Tests

## 🚀 **Deployment aus VSCode:**

### **Frontend Build & Deploy:**
```bash
# 1. Frontend bauen
Ctrl+Shift+P → "📦 Build & Deploy Frontend to Backend"

# 2. Backend starten
Ctrl+Shift+P → "🐍 Backend: Start Development Server"

# 3. Testen auf http://localhost:5000
```

### **Production Deployment:**
```bash
# 1. System-Check
Ctrl+Shift+P → "🔧 System Check"

# 2. Dependencies installieren
Ctrl+Shift+P → "🔧 Install Fedora Dependencies"

# 3. Vollständiges System starten
Ctrl+Shift+P → "🚀 Start Squirtvana (Full Stack)"
```

## 🔍 **Troubleshooting:**

### **Häufige Probleme:**
1. **Python Interpreter nicht gefunden**:
   - Ctrl+Shift+P → "Python: Select Interpreter"
   - `./squirtvana-backend/venv/bin/python` wählen

2. **Node.js Dependencies fehlen**:
   - Terminal: `cd squirtvana-complete-frontend && npm install`

3. **ESLint Errors**:
   - Ctrl+Shift+P → "ESLint: Fix all auto-fixable Problems"

4. **Port bereits belegt**:
   - Terminal: `lsof -ti:5000 | xargs kill -9`

### **Debug-Tipps:**
- **Breakpoints**: F9 setzen
- **Step Through**: F10 (Step Over), F11 (Step Into)
- **Variables**: Debug-Panel verwenden
- **Console**: Debug Console für Expressions

## 📱 **Mobile Development:**

### **PWA Testing:**
1. **Frontend** auf `http://localhost:5174` öffnen
2. **Chrome DevTools** → Application → Manifest
3. **"Add to homescreen"** testen
4. **Service Worker** prüfen

### **Responsive Design:**
1. **Chrome DevTools** → Device Toolbar
2. **Mobile Viewports** testen
3. **Touch Events** simulieren

## 🎯 **Produktivitäts-Tipps:**

### **Keyboard Shortcuts:**
- **Ctrl+Shift+P**: Command Palette
- **Ctrl+`**: Terminal öffnen/schließen
- **Ctrl+Shift+E**: Explorer
- **Ctrl+Shift+D**: Debug Panel
- **F5**: Debug starten
- **Ctrl+F5**: Run ohne Debug

### **Multi-Cursor:**
- **Alt+Click**: Cursor hinzufügen
- **Ctrl+Alt+↑/↓**: Cursor oben/unten
- **Ctrl+D**: Nächstes Vorkommen auswählen

### **Code Navigation:**
- **Ctrl+P**: Datei öffnen
- **Ctrl+Shift+O**: Symbol in Datei
- **Ctrl+T**: Symbol im Workspace
- **F12**: Go to Definition

## 🔒 **Git Integration:**

### **Source Control:**
- **Ctrl+Shift+G**: Source Control Panel
- **GitLens**: Erweiterte Git-Features
- **GitHub Integration**: Pull Requests, Issues

### **Branching:**
- **Ctrl+Shift+P** → "Git: Create Branch"
- **Status Bar**: Current Branch anzeigen
- **Merge Conflicts**: Visuell lösen

---

**🎉 Viel Spaß beim Entwickeln mit VSCode!** 💻

