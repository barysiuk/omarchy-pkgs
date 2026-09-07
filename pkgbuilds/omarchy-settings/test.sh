#!/usr/bin/env bash
# Keep the aarch64 settings payload compatible with the ISO's Limine-template
# contract.  This is source-level by design: building omarchy-settings needs
# the large, commit-pinned Omarchy source tree.
set -euo pipefail

dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
pkgbuild="$dir/PKGBUILD"

grep -Fqx '  cp -a default/. "$pkgdir/usr/share/omarchy/default/"' "$pkgbuild"
if grep -Fq 'rm -rf "$pkgdir/usr/share/omarchy/default/limine"' "$pkgbuild"; then
  echo 'aarch64 omarchy-settings must retain Limine templates for Limine-based installs' >&2
  exit 1
fi
echo 'ok - omarchy-settings retains Limine templates on aarch64'
