# LineageOS 23 (m2391) vendor ramdisk modules non-ELF check fix

Date: 2026-02-20  
Scope: `device/meizu/m2391`  
Target: fix Android 16 build failure when injecting `.ko` into vendor ramdisk.

## 1. Symptom

`mka vendorbootimage` failed with many errors like:

- `found ELF prebuilt in PRODUCT_COPY_FILES`
- destination under `out/.../vendor_ramdisk/lib/modules/*.ko`

## 2. Root cause

Kernel modules (`.ko`, ELF files) were added via `PRODUCT_COPY_FILES`, but Android 16 enforces
non-ELF-only policy for `PRODUCT_COPY_FILES` inputs.

## 3. Fix

Move module injection to kernel-module variables in BoardConfig:

- `BOARD_VENDOR_RAMDISK_KERNEL_MODULES`
- `BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD`
- `BOARD_VENDOR_RAMDISK_KERNEL_MODULES_BLOCKLIST_FILE`

Keep only non-ELF text file copy in `PRODUCT_COPY_FILES`:

- `modules.load.recovery` -> vendor ramdisk modules directory

## 4. Validation checklist

1. `source build/envsetup.sh`
2. `lunch lineage_m2391-bp4a-userdebug`
3. `mka vendorbootimage`
4. confirm no `found ELF prebuilt in PRODUCT_COPY_FILES` errors

## 5. Notes

- This change is required even when using prebuilt module payload.
- `.ko` files must be installed through kernel-module pipeline, not generic copy rules.
