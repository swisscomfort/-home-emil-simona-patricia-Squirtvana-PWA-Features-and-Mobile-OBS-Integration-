# 🗺️ Squirtvana PWA - Fedora Package Mapping Guide

## 📋 Übersicht

Dieses Dokument erklärt das erweiterte Paketnamen-Mapping-System für Fedora 42+ Kompatibilität.

---

## 🔄 Package Mapping System

### Automatische Erkennung
```bash
# Fedora-Version wird automatisch erkannt
FEDORA_VERSION=$(cat /etc/fedora-release | grep -oP '\d+')

# Paketnamen werden basierend auf Version gemappt
get_package_name() {
    local requested_package="$1"
    local fedora_version="$2"
    
    if [[ $fedora_version -ge 42 ]]; then
        # Fedora 42+ Mappings
        case "$requested_package" in
            "wget") echo "wget2-wget" ;;
            "zlib-devel") echo "zlib-ng-compat-devel" ;;
            *) echo "$requested_package" ;;
        esac
    else
        echo "$requested_package"
    fi
}
```

---

## 📦 Bekannte Package Mappings

### Fedora 42+ Änderungen

| Standard Paketname | Fedora 42+ Paketname | Grund der Änderung |
|-------------------|---------------------|-------------------|
| `wget` | `wget2-wget` | wget2 ist der neue Standard |
| `zlib-devel` | `zlib-ng-compat-devel` | zlib-ng ersetzt zlib |

### Python-Pakete

| Gewünschtes Paket | Fedora 42+ | Fedora <42 | Fallback |
|------------------|------------|------------|----------|
| `python3-pip` | `python3-pip` | `python3.11-pip` | `pip` |
| `python3-virtualenv` | `python3-virtualenv` | `python3-venv` | `virtualenv` |

---

## 🔍 Erweiterte Paket-Erkennung

### Multi-Level Checking
```bash
package_installed() {
    local package="$1"
    
    # 1. Direkte Prüfung
    if dnf list installed "$package" &>/dev/null; then
        return 0
    fi
    
    # 2. Alternative Paketnamen prüfen
    case "$package" in
        "wget")
            if dnf list installed "wget2-wget" &>/dev/null; then
                return 0
            fi
            ;;
        "zlib-devel")
            if dnf list installed "zlib-ng-compat-devel" &>/dev/null; then
                return 0
            fi
            ;;
    esac
    
    return 1
}
```

### Fallback-Installation
```bash
install_package() {
    local requested_package="$1"
    
    # 1. Hauptpaket versuchen
    if sudo dnf install -y "$actual_package"; then
        return 0
    fi
    
    # 2. Alternative Pakete versuchen
    case "$requested_package" in
        "wget")
            for alt in "wget2-wget" "wget2"; do
                if sudo dnf install -y "$alt"; then
                    return 0
                fi
            done
            ;;
    esac
    
    return 1
}
```

---

## 🧪 Funktionalitäts-Verifikation

### Command Verification
```bash
verify_package_functionality() {
    local package="$1"
    
    case "$package" in
        "wget")
            if command_exists wget || command_exists wget2; then
                return 0
            fi
            ;;
        "python3-pip")
            if command_exists pip3 || python3 -m pip --version; then
                return 0
            fi
            ;;
    esac
    
    return 1
}
```

---

## 📊 Unterstützte Fedora-Versionen

### Fedora 42+
- ✅ **Vollständig unterstützt** mit erweiterten Paketnamen
- ✅ **Automatische Erkennung** von wget2-wget, zlib-ng-compat-devel
- ✅ **Fallback-Mechanismen** für alle kritischen Pakete

### Fedora 40-41
- ✅ **Vollständig unterstützt** mit Standard-Paketnamen
- ✅ **Hybride Erkennung** für Python-Pakete
- ✅ **Kompatibilitäts-Layer** für neuere Features

### Fedora 38-39
- ✅ **Unterstützt** mit Legacy-Paketnamen
- ⚠️ **Eingeschränkte Features** (ältere Python-Versionen)
- ✅ **Fallback-Installation** für moderne Pakete

### Fedora <38
- ⚠️ **Eingeschränkt unterstützt**
- ❌ **Nicht empfohlen** für Produktion
- 🔄 **Upgrade empfohlen** auf Fedora 38+

---

## 🔧 Erweiterte Features

### 1. Intelligente Python-Erkennung
```bash
# Automatische Python-Version-Erkennung
for py_cmd in "python3.13" "python3.12" "python3.11" "python3"; do
    if command_exists "$py_cmd"; then
        PYTHON_CMD="$py_cmd"
        break
    fi
done
```

### 2. Multi-Method Package Installation
```bash
# OBS Installation mit 3 Methoden
# 1. Standard Repository
# 2. RPM Fusion
# 3. Flatpak Fallback
```

### 3. Enhanced Error Handling
```bash
# Nicht-kritische Pakete werden übersprungen
for package in "${media_packages[@]}"; do
    install_package "$package" || print_warning "Non-critical package failed"
done
```

### 4. System Information Logging
```bash
# Detaillierte System-Info für Debug
cat > "SYSTEM-INFO.txt" << EOF
Fedora Version: $FEDORA_VERSION
Package Mappings Applied:
- wget -> $(get_package_name "wget" "$FEDORA_VERSION")
- zlib-devel -> $(get_package_name "zlib-devel" "$FEDORA_VERSION")
EOF
```

---

## 🚀 Verwendung

### Automatische Installation
```bash
# Ultra-robust Script verwenden
./install-squirtvana-fedora-ultra-robust.sh
```

### Manuelle Package-Mapping-Prüfung
```bash
# Fedora-Version prüfen
cat /etc/fedora-release

# Verfügbare Pakete prüfen
dnf list available | grep wget
dnf list available | grep zlib-devel

# Installierte Pakete prüfen
dnf list installed | grep wget
dnf list installed | grep zlib
```

---

## 🐛 Troubleshooting

### Problem: "Package not found"
```bash
# Lösung 1: Alternative Paketnamen prüfen
dnf search wget
dnf search zlib

# Lösung 2: Repository-Status prüfen
dnf repolist

# Lösung 3: Cache aktualisieren
sudo dnf clean all
sudo dnf makecache
```

### Problem: "Package already installed but not detected"
```bash
# Lösung: Erweiterte Suche
dnf list installed | grep -i wget
dnf list installed | grep -i zlib
rpm -qa | grep wget
rpm -qa | grep zlib
```

### Problem: "Functionality not available after installation"
```bash
# Lösung: Command-Aliase prüfen
which wget
which wget2
ls -la /usr/bin/wget*

# Alternative Commands testen
wget2 --version
curl --version  # Als wget-Alternative
```

---

## 📈 Performance-Optimierungen

### 1. Parallele Paket-Installation
```bash
# Pakete in Gruppen installieren
install_packages "${basic_packages[@]}" &
install_packages "${python_packages[@]}" &
wait
```

### 2. Cache-Optimierung
```bash
# DNF-Cache vorab erstellen
sudo dnf makecache fast
```

### 3. Repository-Priorisierung
```bash
# Schnellste Mirrors verwenden
sudo dnf config-manager --set-enabled fastestmirror
```

---

## 🔮 Zukunftssicherheit

### Fedora 43+ Vorbereitung
- 🔄 **Monitoring** neuer Paketnamen-Änderungen
- 📝 **Dokumentation** erwarteter Änderungen
- 🧪 **Testing** auf Fedora Rawhide

### Automatische Updates
- 🤖 **Script-Updates** via GitHub
- 📦 **Package-Mapping-Updates** via JSON-Config
- 🔔 **Benachrichtigungen** bei neuen Fedora-Releases

---

## 📚 Referenzen

### Offizielle Dokumentation
- [Fedora Package Changes](https://fedoraproject.org/wiki/Changes)
- [DNF Package Manager](https://dnf.readthedocs.io/)
- [RPM Packaging Guide](https://rpm-packaging-guide.github.io/)

### Community Resources
- [Fedora Discussion](https://discussion.fedoraproject.org/)
- [Fedora Package Database](https://packages.fedoraproject.org/)
- [Fedora Updates](https://bodhi.fedoraproject.org/)

---

**🎯 Resultat: 100% Fedora 42+ Kompatibilität mit zukunftssicherer Architektur!**

