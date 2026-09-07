#!/usr/bin/env bash
set -euo pipefail
dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
dtb="$dir/x1p42100-microsoft-sp12in.dtb"
[[ $(sha256sum "$dtb" | cut -d' ' -f1) == d7ed4b073c7344cb0bb2c3f7d00655df60b473588a5c0364af54537dc2c672c7 ]]
python3 - "$dtb" <<'PY'
import struct, sys
p=open(sys.argv[1], 'rb').read(); assert p[:4] == b'\xd0\r\xfe\xed'; assert b'microsoft,surface-pro-12in\0' in p[:struct.unpack_from('>I',p,4)[0]]
PY
grep -Fqx 'MKINITCPIO_UKI_OPTIONS="--ukiconfig /etc/kernel/uki-surface-pro-12.conf"' "$dir/omarchy-surface-pro-12.conf"
grep -Fqx 'DeviceTree=/usr/lib/omarchy-surface-pro-12/x1p42100-microsoft-sp12in.dtb' "$dir/uki-surface-pro-12.conf"
grep -Fqx 'HWIDs=' "$dir/uki-surface-pro-12.conf"
grep -Fqx 'HOOKS=(${HOOKS[@]/filesystems/sd-encrypt filesystems})' "$dir/90-omarchy-surface-pro-12-sd-encrypt.conf"
! grep -Fq -- '--dtb' "$dir/omarchy-surface-pro-12.conf"
grep -Fqx 'ENABLE_UKI=yes' "$dir/omarchy-surface-pro-12.conf"
grep -Fqx 'CUSTOM_UKI_NAME=omarchy' "$dir/omarchy-surface-pro-12.conf"
grep -Fqx 'MKINITCPIO_FALLBACK=yes' "$dir/omarchy-surface-pro-12.conf"
grep -Fqx 'KERNEL_CMDLINE[default]+="initramfs_async=0 clk_ignore_unused pd_ignore_unused arm64.nopauth"' "$dir/omarchy-surface-pro-12.conf"
! grep -Eq 'archiso|systemd\.tpm2_wait|modprobe\.blacklist|debug' "$dir/omarchy-surface-pro-12.conf"
grep -Fqx "arch=('aarch64')" "$dir/PKGBUILD"
for dep in limine-mkinitcpio-hook limine-snapper-sync mkinitcpio snapper systemd-ukify; do
  grep -Fqx "depends=('limine-mkinitcpio-hook' 'limine-snapper-sync' 'mkinitcpio' 'snapper' 'systemd-ukify')" "$dir/PKGBUILD"
done
[[ $(jq -r '.source' "$dir/.omarchy/package.json") == local ]]
[[ $(jq -r '.channels[]' "$dir/.omarchy/package.json") == edge ]]
grep -Fqx 'rm -f /etc/limine-entry-tool.d/qualcomm-snapdragon.conf' "$dir/surface-pre-boot-cleanup"
grep -Fqx 'rm -f /etc/modprobe.d/qualcomm-adsp-nofw.conf' "$dir/surface-pre-boot-cleanup"
grep -Fqx 'rm -f /etc/mkinitcpio.conf.d/surface_device_modules.conf' "$dir/surface-pre-boot-cleanup"
grep -Fq 'BEGIN OMARCHY QUALCOMM DEVICE TREES' "$dir/surface-pre-boot-cleanup"
scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/etc/limine-entry-tool.d" "$scratch/etc/modprobe.d" "$scratch/etc/mkinitcpio.conf.d" "$scratch/etc/kernel"
touch "$scratch/etc/limine-entry-tool.d/qualcomm-snapdragon.conf" "$scratch/etc/modprobe.d/qualcomm-adsp-nofw.conf" "$scratch/etc/mkinitcpio.conf.d/surface_device_modules.conf"
printf '# BEGIN OMARCHY QUALCOMM DEVICE TREES\n[UKI]\nDeviceTreeAuto=/bad\n# END OMARCHY QUALCOMM DEVICE TREES\n' >"$scratch/etc/kernel/uki.conf"
sed "s# /etc/# $scratch/etc/#g" "$dir/surface-pre-boot-cleanup" | bash
test ! -e "$scratch/etc/mkinitcpio.conf.d/surface_device_modules.conf"
test ! -e "$scratch/etc/limine-entry-tool.d/qualcomm-snapdragon.conf"
test ! -e "$scratch/etc/modprobe.d/qualcomm-adsp-nofw.conf"
! grep -Fq 'DeviceTreeAuto=' "$scratch/etc/kernel/uki.conf"
grep -Fqx 'HOOKS=(${HOOKS[@]/filesystems/sd-encrypt filesystems})' "$dir/90-omarchy-surface-pro-12-sd-encrypt.conf"
echo 'ok - Surface Pro 12 fixed DTB package metadata and Limine semantics'
