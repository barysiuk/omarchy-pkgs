#!/usr/bin/env bash
set -euo pipefail
dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
dtb="$dir/x1p42100-microsoft-sp12in.dtb"
[[ $(sha256sum "$dtb" | cut -d' ' -f1) == d7ed4b073c7344cb0bb2c3f7d00655df60b473588a5c0364af54537dc2c672c7 ]]
python3 - "$dtb" <<'PY'
import struct, sys
p=open(sys.argv[1], 'rb').read(); assert p[:4] == b'\xd0\r\xfe\xed'; assert b'microsoft,surface-pro-12in\0' in p[:struct.unpack_from('>I',p,4)[0]]
PY
grep -Fqx 'MKINITCPIO_UKI_OPTIONS="--dtb /usr/lib/omarchy-surface-pro-12/x1p42100-microsoft-sp12in.dtb"' "$dir/omarchy-surface-pro-12.conf"
grep -Fqx 'MKINITCPIO_FALLBACK=yes' "$dir/omarchy-surface-pro-12.conf"
grep -Fqx 'KERNEL_CMDLINE[default]+="initramfs_async=0 clk_ignore_unused pd_ignore_unused arm64.nopauth"' "$dir/omarchy-surface-pro-12.conf"
! grep -Eq 'archiso|systemd\.tpm2_wait|modprobe\.blacklist|debug' "$dir/omarchy-surface-pro-12.conf"
grep -Fqx "arch=('aarch64')" "$dir/PKGBUILD"
[[ $(jq -r '.source' "$dir/.omarchy/package.json") == local ]]
[[ $(jq -r '.channels[]' "$dir/.omarchy/package.json") == edge ]]
echo 'ok - Surface Pro 12 fixed DTB package metadata and Limine semantics'
