# LineageOS 23 (m2391) bacon OTA package wiring fix

Date: 2026-02-19  
Scope: `device/meizu/m2391`  
Target: fix `bacon` failure where final ZIP packaging runs with an empty OTA source path.

## 1. Symptom

`mka bacon` reached ~90% and failed on:

- `build out/target/product/m2391/lineage-...-m2391.zip`
- command: `ln -f out/target/product/m2391/lineage-...-m2391.zip`
- error: `ln: cannot create hard link ... No such file or directory`

The preceding AIDL metadata INFO lines from VINTF processing are expected for
prebuilt vendor interfaces and are not the blocker.

## 2. Root cause

`vendor/lineage/build/tasks/bacon.mk` expects:

- `INTERNAL_OTA_PACKAGE_TARGET` (source OTA zip)
- `LINEAGE_TARGET_PACKAGE` (final lineage zip)

For this product, `INTERNAL_OTA_PACKAGE_TARGET` was empty, so the generated
`ln` command had only one argument.

Resolved build vars showed:

- `TARGET_NO_KERNEL=true`
- `BOARD_PREBUILT_BOOTIMAGE=device/meizu/m2391-kernel/boot.img`
- `INSTALLED_BOOTIMAGE_TARGET=` (empty)

With `INSTALLED_BOOTIMAGE_TARGET` empty and `TARGET_NO_KERNEL=true`,
`build/make/core/Makefile` disabled `build_ota_package`, so OTA package targets
were never generated for `bacon` to consume.

## 3. Fix

Force OTA package generation for this real device product (prebuilt boot chain)
by setting:

- `PRODUCT_BUILD_GENERIC_OTA_PACKAGE := true`

in:

- `device/meizu/m2391/lineage_m2391.mk`

This keeps the prebuilt-kernel strategy unchanged while ensuring
`INTERNAL_OTA_PACKAGE_TARGET` exists for `bacon`.

## 4. Validation checklist

1. `source build/envsetup.sh`
2. `lunch lineage_m2391-bp4a-userdebug`
3. `mka bacon`
4. Confirm generated ninja rule for `lineage-...-m2391.zip` has two arguments in
   `ln -f <source> <dest>` and `out/target/product/m2391/lineage-...zip`
   is produced.

## 5. Notes for future bring-up

- Do not switch away from prebuilt kernel boot chain for this fix.
- If `bacon` shows an `ln -f` command with only one path argument, first verify
  whether OTA package generation was disabled and whether
  `INTERNAL_OTA_PACKAGE_TARGET` is empty.
