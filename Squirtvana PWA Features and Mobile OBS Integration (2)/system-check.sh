#!/bin/bash

# Squirtvana PWA - System Check & Validation Script
# Prüft alle Voraussetzungen und Dependencies

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Counters
CHECKS_PASSED=0
CHECKS_FAILED=0
WARNINGS=0

echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║                SQUIRTVANA PWA SYSTEM CHECK                   ║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Helper functions
check_pass() {
    echo -e "${GREEN}✅ PASS:${NC} $1"
    ((CHECKS_PASSED++))
}

check_fail() {
    echo -e "${RED}❌ FAIL:${NC} $1"
    ((CHECKS_FAILED++))
}

check_warn() {
    echo -e "${YELLOW}⚠️  WARN:${NC} $1"
    ((WARNINGS++))
}

check_info() {
    echo -e "${BLUE}ℹ️  INFO:${NC} $1"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# System Information
echo -e "${BLUE}📋 System Information${NC}"
echo "────────────────────────────────────────"
echo "OS: $(cat /etc/fedora-release 2>/dev/null || echo 'Unknown')"
echo "Kernel: $(uname -r)"
echo "Architecture: $(uname -m)"
echo "Hostname: $(hostname)"
echo "User: $(whoami)"
echo "Date: $(date)"
echo ""

# Check Operating System
echo -e "${BLUE}🐧 Operating System Check${NC}"
echo "────────────────────────────────────────"
if [[ -f /etc/fedora-release ]]; then
    FEDORA_VERSION=$(cat /etc/fedora-release | grep -oP '\d+')
    if [[ $FEDORA_VERSION -ge 38 ]]; then
        check_pass "Fedora $FEDORA_VERSION (Supported)"
    else
        check_warn "Fedora $FEDORA_VERSION (Minimum: Fedora 38)"
    fi
else
    check_fail "Not running Fedora Linux"
fi
echo ""

# Check System Resources
echo -e "${BLUE}💾 System Resources${NC}"
echo "────────────────────────────────────────"

# RAM Check
TOTAL_RAM=$(free -m | awk 'NR==2{printf "%.0f", $2/1024}')
if [[ $TOTAL_RAM -ge 8 ]]; then
    check_pass "RAM: ${TOTAL_RAM}GB (Recommended: 8GB+)"
elif [[ $TOTAL_RAM -ge 4 ]]; then
    check_warn "RAM: ${TOTAL_RAM}GB (Minimum: 4GB, Recommended: 8GB+)"
else
    check_fail "RAM: ${TOTAL_RAM}GB (Insufficient, Minimum: 4GB)"
fi

# Disk Space Check
AVAILABLE_SPACE=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
if [[ $AVAILABLE_SPACE -ge 5 ]]; then
    check_pass "Disk Space: ${AVAILABLE_SPACE}GB available (Recommended: 5GB+)"
elif [[ $AVAILABLE_SPACE -ge 2 ]]; then
    check_warn "Disk Space: ${AVAILABLE_SPACE}GB available (Minimum: 2GB, Recommended: 5GB+)"
else
    check_fail "Disk Space: ${AVAILABLE_SPACE}GB available (Insufficient, Minimum: 2GB)"
fi

# CPU Check
CPU_CORES=$(nproc)
if [[ $CPU_CORES -ge 4 ]]; then
    check_pass "CPU Cores: $CPU_CORES (Recommended: 4+)"
elif [[ $CPU_CORES -ge 2 ]]; then
    check_warn "CPU Cores: $CPU_CORES (Minimum: 2, Recommended: 4+)"
else
    check_fail "CPU Cores: $CPU_CORES (Insufficient, Minimum: 2)"
fi
echo ""

# Check Internet Connection
echo -e "${BLUE}🌐 Internet Connection${NC}"
echo "────────────────────────────────────────"
if ping -c 1 google.com &> /dev/null; then
    check_pass "Internet connection available"
    
    # Check API endpoints
    if curl -s --max-time 5 https://openrouter.ai &> /dev/null; then
        check_pass "OpenRouter API reachable"
    else
        check_warn "OpenRouter API not reachable"
    fi
    
    if curl -s --max-time 5 https://api.elevenlabs.io &> /dev/null; then
        check_pass "ElevenLabs API reachable"
    else
        check_warn "ElevenLabs API not reachable"
    fi
    
    if curl -s --max-time 5 https://api.telegram.org &> /dev/null; then
        check_pass "Telegram API reachable"
    else
        check_warn "Telegram API not reachable"
    fi
else
    check_fail "No internet connection"
fi
echo ""

# Check Required Commands
echo -e "${BLUE}🔧 Required Commands${NC}"
echo "────────────────────────────────────────"

# System commands
for cmd in curl wget git unzip gcc make; do
    if command_exists $cmd; then
        check_pass "$cmd installed"
    else
        check_fail "$cmd not installed"
    fi
done

# Python
if command_exists python3.11; then
    PYTHON_VERSION=$(python3.11 --version 2>&1 | cut -d' ' -f2)
    check_pass "Python 3.11 installed ($PYTHON_VERSION)"
elif command_exists python3; then
    PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2)
    check_warn "Python 3 installed ($PYTHON_VERSION) - Python 3.11 recommended"
else
    check_fail "Python not installed"
fi

# Node.js
if command_exists node; then
    NODE_VERSION=$(node --version)
    check_pass "Node.js installed ($NODE_VERSION)"
else
    check_fail "Node.js not installed"
fi

# npm
if command_exists npm; then
    NPM_VERSION=$(npm --version)
    check_pass "npm installed ($NPM_VERSION)"
else
    check_fail "npm not installed"
fi

# pnpm
if command_exists pnpm; then
    PNPM_VERSION=$(pnpm --version)
    check_pass "pnpm installed ($PNPM_VERSION)"
else
    check_warn "pnpm not installed (will be installed automatically)"
fi

# OBS Studio
if command_exists obs; then
    check_pass "OBS Studio installed"
else
    check_fail "OBS Studio not installed"
fi
echo ""

# Check Squirtvana Installation
echo -e "${BLUE}🎯 Squirtvana Installation${NC}"
echo "────────────────────────────────────────"

PROJECT_DIR="$HOME/squirtvana-pwa-project"
BACKEND_DIR="$PROJECT_DIR/squirtvana-backend"
FRONTEND_DIR="$PROJECT_DIR/squirtvana-pwa"

if [[ -d "$PROJECT_DIR" ]]; then
    check_pass "Project directory exists"
    
    # Backend checks
    if [[ -d "$BACKEND_DIR" ]]; then
        check_pass "Backend directory exists"
        
        if [[ -f "$BACKEND_DIR/src/main.py" ]]; then
            check_pass "Backend main.py exists"
        else
            check_fail "Backend main.py missing"
        fi
        
        if [[ -f "$BACKEND_DIR/.env" ]]; then
            check_pass "Environment file exists"
        else
            check_fail "Environment file missing"
        fi
        
        if [[ -d "$BACKEND_DIR/venv" ]]; then
            check_pass "Python virtual environment exists"
        else
            check_fail "Python virtual environment missing"
        fi
    else
        check_fail "Backend directory missing"
    fi
    
    # Frontend checks
    if [[ -d "$FRONTEND_DIR" ]]; then
        check_pass "Frontend directory exists"
        
        if [[ -f "$FRONTEND_DIR/package.json" ]]; then
            check_pass "Frontend package.json exists"
        else
            check_fail "Frontend package.json missing"
        fi
        
        if [[ -d "$FRONTEND_DIR/node_modules" ]]; then
            check_pass "Frontend dependencies installed"
        else
            check_warn "Frontend dependencies not installed"
        fi
    else
        check_fail "Frontend directory missing"
    fi
else
    check_fail "Squirtvana not installed"
fi
echo ""

# Check Running Services
echo -e "${BLUE}🚀 Running Services${NC}"
echo "────────────────────────────────────────"

# Check if Squirtvana backend is running
if netstat -tlnp 2>/dev/null | grep -q ":5000"; then
    check_pass "Squirtvana backend running on port 5000"
else
    check_info "Squirtvana backend not running"
fi

# Check if OBS WebSocket is running
if netstat -tlnp 2>/dev/null | grep -q ":4455"; then
    check_pass "OBS WebSocket running on port 4455"
else
    check_info "OBS WebSocket not running"
fi

# Check if OBS is running
if pgrep -x "obs" > /dev/null; then
    check_pass "OBS Studio is running"
else
    check_info "OBS Studio not running"
fi
echo ""

# Port availability check
echo -e "${BLUE}🔌 Port Availability${NC}"
echo "────────────────────────────────────────"

for port in 5000 4455; do
    if netstat -tlnp 2>/dev/null | grep -q ":$port"; then
        check_info "Port $port is in use"
    else
        check_pass "Port $port is available"
    fi
done
echo ""

# Firewall check
echo -e "${BLUE}🛡️ Firewall Status${NC}"
echo "────────────────────────────────────────"

if command_exists firewall-cmd; then
    if systemctl is-active --quiet firewalld; then
        check_info "Firewalld is active"
        
        if firewall-cmd --list-ports | grep -q "5000/tcp"; then
            check_pass "Port 5000 is open in firewall"
        else
            check_warn "Port 5000 not open in firewall (may need manual opening for network access)"
        fi
    else
        check_info "Firewalld is not active"
    fi
else
    check_info "Firewalld not installed"
fi
echo ""

# Performance recommendations
echo -e "${BLUE}⚡ Performance Recommendations${NC}"
echo "────────────────────────────────────────"

# Check available RAM
AVAILABLE_RAM=$(free -m | awk 'NR==2{printf "%.0f", $7/1024}')
if [[ $AVAILABLE_RAM -lt 2 ]]; then
    check_warn "Low available RAM (${AVAILABLE_RAM}GB) - consider closing other applications"
else
    check_pass "Sufficient available RAM (${AVAILABLE_RAM}GB)"
fi

# Check CPU load
CPU_LOAD=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
CPU_LOAD_INT=$(echo "$CPU_LOAD" | cut -d'.' -f1)
if [[ $CPU_LOAD_INT -gt $CPU_CORES ]]; then
    check_warn "High CPU load ($CPU_LOAD) - system may be under stress"
else
    check_pass "Normal CPU load ($CPU_LOAD)"
fi

# Check disk I/O
if command_exists iostat; then
    check_pass "iostat available for I/O monitoring"
else
    check_info "Install sysstat for I/O monitoring: sudo dnf install sysstat"
fi
echo ""

# Summary
echo -e "${PURPLE}╔══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${PURPLE}║                        SUMMARY                               ║${NC}"
echo -e "${PURPLE}╚══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}✅ Checks Passed: $CHECKS_PASSED${NC}"
echo -e "${RED}❌ Checks Failed: $CHECKS_FAILED${NC}"
echo -e "${YELLOW}⚠️  Warnings: $WARNINGS${NC}"
echo ""

if [[ $CHECKS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}🎉 System is ready for Squirtvana PWA!${NC}"
    if [[ $WARNINGS -gt 0 ]]; then
        echo -e "${YELLOW}💡 Consider addressing warnings for optimal performance.${NC}"
    fi
    exit 0
else
    echo -e "${RED}🚨 System has issues that need to be resolved.${NC}"
    echo -e "${BLUE}💡 Run the installation script to fix missing dependencies:${NC}"
    echo "   ./install-squirtvana-fedora.sh"
    exit 1
fi

