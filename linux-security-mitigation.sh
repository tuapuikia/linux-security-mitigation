#!/bin/bash
# linux-security-mitigation.sh
# Mitigations for Copy-Fail (CVE-2026-31431) and Dirty-Frag (CVE-2026-43284)
# Maintainer: Stan Wong
# Based on Ubuntu Security Bulletins.

set -e

# Configuration
COPY_FAIL_CONF="/etc/modprobe.d/disable-algif_aead.conf"
DIRTY_FRAG_CONF="/etc/modprobe.d/dirty-frag.conf"
COPY_FAIL_CONTENT="install algif_aead /bin/false"
DIRTY_FRAG_CONTENT="install esp4 /bin/false
install esp6 /bin/false
install rxrpc /bin/false"

echo "----------------------------------------------------------"
echo "Linux Security Mitigation Script"
echo "Mitigating Copy-Fail and Dirty-Frag Vulnerabilities"
echo "----------------------------------------------------------"

# Check for root/sudo
if [[ $EUID -ne 0 ]]; then
   echo "[!] Note: This script requires root privileges. You will be prompted for your password by sudo."
fi

# Helper: Check if module is loaded
is_module_loaded() {
    lsmod | grep -q "^$1"
}

# Helper: Scan for existing mitigations in other files
check_existing_mitigations() {
    local module=$1
    local current_script_conf=$2
    
    if [ ! -d "/etc/modprobe.d" ]; then
        return
    fi

    # Search for 'install <module> /bin/false' or 'blacklist <module>'
    # Exclude the file this script manages to avoid self-reporting
    local matches
    matches=$(grep -lRE "install $module /bin/false|blacklist $module" /etc/modprobe.d/ 2>/dev/null | grep -v "$current_script_conf" || true)
    
    if [ -n "$matches" ]; then
        echo "[!] Note: Existing mitigation for '$module' detected in:"
        echo "$matches" | sed 's/^/    - /'
    fi
}

# Helper: Big Warning
print_vulnerable_warning() {
    local module=$1
    local cve=$2
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    echo "!! CRITICAL WARNING: VULNERABLE MODULE LOADED           !!"
    echo "!! Module '$module' is currently ACTIVE in memory.      !!"
    echo "!! Your system is VULNERABLE to $cve.                   !!"
    echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
}

# Disable Logic
if [[ "$1" == "--disable" ]]; then
    echo "[*] Disabling mitigations..."
    
    if [ -f "$COPY_FAIL_CONF" ]; then
        sudo rm -v "$COPY_FAIL_CONF"
    fi
    
    if [ -f "$DIRTY_FRAG_CONF" ]; then
        sudo rm -v "$DIRTY_FRAG_CONF"
    fi
    
    echo "[*] Updating initramfs to reflect changes..."
    sudo update-initramfs -u -k all
    
    echo ""
    echo "[+] Mitigations have been disabled. Please reboot to restore modules."
    exit 0
fi

# Apply Logic
echo "[*] Starting mitigation application..."

# 1. Copy-Fail (CVE-2026-31431)
echo ""
echo "[*] Checking Copy-Fail (CVE-2026-31431) status..."

# Scan for other mitigations
check_existing_mitigations "algif_aead" "$COPY_FAIL_CONF"

# Check if loaded
if is_module_loaded "algif_aead"; then
    print_vulnerable_warning "algif_aead" "Copy-Fail (CVE-2026-31431)"
else
    echo "[+] Module 'algif_aead' is not loaded."
fi

# Check config file
if [ -f "$COPY_FAIL_CONF" ]; then
    if grep -q "$COPY_FAIL_CONTENT" "$COPY_FAIL_CONF"; then
        echo "[+] Mitigation file '$COPY_FAIL_CONF' is already active."
    else
        echo "[!] Mitigation file exists but content is incorrect. Fixing..."
        echo "$COPY_FAIL_CONTENT" | sudo tee "$COPY_FAIL_CONF" > /dev/null
    fi
else
    echo "[*] Mitigation file missing. Enabling Copy-Fail mitigation by default..."
    echo "$COPY_FAIL_CONTENT" | sudo tee "$COPY_FAIL_CONF" > /dev/null
fi

# 2. Dirty-Frag (CVE-2026-43284)
echo ""
echo "[*] Checking Dirty-Frag (CVE-2026-43284) status..."

# Scan for other mitigations
for mod in esp4 esp6 rxrpc; do
    check_existing_mitigations "$mod" "$DIRTY_FRAG_CONF"
done

# Check if any loaded
VULN_LOADED=false
for mod in esp4 esp6 rxrpc; do
    if is_module_loaded "$mod"; then
        print_vulnerable_warning "$mod" "Dirty-Frag (CVE-2026-43284)"
        VULN_LOADED=true
    fi
done

if [ "$VULN_LOADED" = false ]; then
    echo "[+] Dirty-Frag modules (esp4, esp6, rxrpc) are not loaded."
fi

# Check config file
if [ -f "$DIRTY_FRAG_CONF" ]; then
    # Check if all lines exist
    ALL_PRESENT=true
    for line in "install esp4 /bin/false" "install esp6 /bin/false" "install rxrpc /bin/false"; do
        if ! grep -q "$line" "$DIRTY_FRAG_CONF"; then
            ALL_PRESENT=false
        fi
    done
    
    if [ "$ALL_PRESENT" = true ]; then
        echo "[+] Mitigation file '$DIRTY_FRAG_CONF' is already active."
    else
        echo "[!] Mitigation file exists but is incomplete. Fixing..."
        echo "$DIRTY_FRAG_CONTENT" | sudo tee "$DIRTY_FRAG_CONF" > /dev/null
    fi
else
    echo "[*] Mitigation file missing. Enabling Dirty-Frag mitigation by default..."
    echo "$DIRTY_FRAG_CONTENT" | sudo tee "$DIRTY_FRAG_CONF" > /dev/null
fi

# 3. System Updates and Cleanup
echo ""
echo "[*] Updating kmod package and initramfs..."
sudo apt-get update
sudo apt-get install --only-upgrade -y kmod
sudo update-initramfs -u -k all

echo "[*] Attempting to unload modules from current session..."
sudo rmmod algif_aead esp4 esp6 rxrpc 2>/dev/null || echo "[!] Some modules could not be unloaded (they may be in use)."

echo ""
echo "----------------------------------------------------------"
echo "Mitigation process complete."
echo "A reboot is REQUIRED to ensure all changes are active."

# Handle cases where script is piped to bash
SCRIPT_NAME=$(basename "$0")
if [[ "$SCRIPT_NAME" == "bash" || "$SCRIPT_NAME" == "sh" ]]; then
    SCRIPT_NAME="linux-security-mitigation.sh"
fi
echo "To disable these mitigations later, run: sudo ./$SCRIPT_NAME --disable"
echo "----------------------------------------------------------"
