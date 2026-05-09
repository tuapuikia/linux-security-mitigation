# Kernel LPE Mitigator Helm Chart

This chart deploys a privileged DaemonSet to mitigate Linux kernel Local Privilege Escalation (LPE) vulnerabilities across all nodes in a Kubernetes cluster.

## Vulnerabilities Addressed

- **Copy-Fail (CVE-2026-31431)**: Disables `algif_aead`.
- **Dirty-Frag (CVE-2026-43284)**: Disables `esp4`, `esp6`, and `rxrpc`.

## Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `enabled` | Whether to deploy the DaemonSet. | `true` |
| `action` | `apply` to enable mitigations, `remove` to delete them. | `apply` |
| `mitigation.copyFail` | Enable mitigation for Copy-Fail. | `true` |
| `mitigation.dirtyFrag` | Enable mitigation for Dirty-Frag. | `true` |

## Usage

### Apply Mitigations
```bash
helm install kernel-lpe-mitigate ./kernel-lpe-mitigator -n kube-system
```

### Disable/Remove Mitigations
To remove the configuration files from the host nodes, update the release with `action=remove`:
```bash
helm upgrade kernel-lpe-mitigate ./kernel-lpe-mitigator -n kube-system --set action=remove
```
*Note: After removing the mitigation, a node reboot is recommended to fully restore the kernel modules.*

### Uninstall Chart
```bash
helm uninstall kernel-lpe-mitigate -n kube-system
```
