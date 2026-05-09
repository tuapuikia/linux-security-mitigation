# Linux Security Mitigation Script

A professional utility to mitigate the **Copy-Fail** and **Dirty-Frag** Linux kernel vulnerabilities on Ubuntu and Debian-based systems.

**Maintainer:** Stan Wong

---

## Vulnerabilities Addressed

### 1. Copy-Fail (CVE-2026-31431)
A local privilege escalation vulnerability in the `algif_aead` kernel module. This script mitigates the risk by:
- Upgrading the `kmod` package to the latest version containing built-in mitigations.
- Explicitly disabling the `algif_aead` module via `modprobe.d`.

### 2. Dirty-Frag (CVE-2026-43284)
A local privilege escalation vulnerability affecting IPsec (`esp4`, `esp6`) and AFS (`rxrpc`) kernel modules. This script mitigates the risk by:
- Disabling the affected modules (`esp4`, `esp6`, `rxrpc`) via `modprobe.d`.
- Updating the system `initramfs` to ensure these modules are not loaded during the boot process.

---

## Key Features

- **Vulnerability Detection:** Checks if vulnerable modules are currently active in memory and provides a high-visibility warning.
- **Upstream Scan:** Scans `/etc/modprobe.d/` for existing or conflicting mitigations provided by the distribution or other scripts.
- **Automated Application:** Automatically creates or repairs mitigation configuration files if they are missing or incorrect.
- **System Integration:** Handles `apt` updates for critical packages and regenerates `initramfs` for persistent protection.
- **Reversible:** Includes a `--disable` flag to safely remove all applied mitigations.

---

## Usage

### Remote Execution (One-Liner)
You can run the script directly from GitHub using `curl`:

```bash
curl -fsSL https://raw.githubusercontent.com/tuapuikia/linux-security-mitigation/main/linux-security-mitigation.sh | bash
```

### Local Execution
If you have downloaded the script:

```bash
chmod +x linux-security-mitigation.sh
sudo ./linux-security-mitigation.sh
```

---

## Disabling Mitigations

To revert the changes and re-enable the affected modules:

```bash
sudo ./linux-security-mitigation.sh --disable
```

*Note: If you ran the script via `curl`, you can disable it using:*
```bash
curl -fsSL https://raw.githubusercontent.com/tuapuikia/linux-security-mitigation/main/linux-security-mitigation.sh | sudo bash -s -- --disable
```

---

## Important Note
**A system reboot is required** after running this script to ensure that any vulnerable modules currently in memory are cleared and that the new boot-time protections are fully active.

---

## Disclaimer
This script is provided "as is" without warranty of any kind. Always review security scripts before running them with root privileges.
