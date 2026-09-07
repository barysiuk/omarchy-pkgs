# Experimental Surface Pro 12in installed boot support

This package embeds one fixed DTB in each normal and fallback UKI.  It is only
for the exact Microsoft Surface Pro 12in 1st Edition with Snapdragon identified
by the Omarchy ISO; it does not install Wi-Fi, audio, sensor, or camera support.

`x1p42100-microsoft-sp12in.dtb` was copied without modification from
`harrisonvanderbyl/surface-pro-12-inch-linux` commit
`ea0f07e66beea95898d96fbeb6daa472f4735af3`, `boot/dtb`; SHA-256
`d7ed4b073c7344cb0bb2c3f7d00655df60b473588a5c0364af54537dc2c672c7`.
The source repository does not clearly license redistribution of that prebuilt
binary.  This personal experimental package is **not upstream-ready**: confirm
redistribution permission or replace it with a reproducible upstream-DTS build
before publishing it.
