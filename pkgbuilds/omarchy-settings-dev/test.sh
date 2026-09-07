#!/usr/bin/env bash
set -euo pipefail
dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
pkgbuild="$dir/PKGBUILD"
grep -Fqx '  cp -a default/. "$pkgdir/usr/share/omarchy/default/"' "$pkgbuild"
if grep -Fq 'rm -rf "$pkgdir/usr/share/omarchy/default/limine"' "$pkgbuild"; then
  echo 'aarch64 omarchy-settings-dev must retain Limine templates for Surface installs' >&2
  exit 1
fi
echo 'ok - omarchy-settings-dev retains Limine templates on aarch64'
