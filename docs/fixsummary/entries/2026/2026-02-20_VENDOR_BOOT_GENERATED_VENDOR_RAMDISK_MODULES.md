# LineageOS 23 (m2391) generated vendor_boot vendor ramdisk modules alignment

Date: 2026-02-20  
Scope: `device/meizu/m2391`  
Target: fix generated `vendor_boot.img` early boot freeze after DTB injection by restoring stock kernel module payload in vendor ramdisk.

## 1. Symptom

After re-enabling generated `vendor_boot` and fixing DTB injection:

- image built and flashed successfully
- device still froze at early recovery splash / first screen

Unpack comparison:

- generated vendor ramdisk size: ~3.0 MB
- stock/prebuilt vendor ramdisk size: ~10.4 MB
- generated vendor ramdisk had no `lib/modules/*`
- stock vendor ramdisk had ~345 files under `lib/modules` (kernel modules + `modules.*` metadata)

## 2. Root cause

Generated vendor ramdisk path did not include stock module payload, so boot-critical
drivers were absent during early recovery boot flow.

## 3. Fix

### 3.1 Extract stock vendor ramdisk module payload

Populate:

- `device/meizu/m2391-kernel/vendor-ramdisk/lib/modules/*`

from stock `KERNEL_PATH/vendor_boot.img` (one-time extraction baseline).

### 3.2 Inject modules into generated vendor ramdisk

In `device/meizu/m2391/BoardConfig.mk`:

- define module source directory:
  - `M2391_VENDOR_RAMDISK_MODULE_DIR := .../vendor-ramdisk/lib/modules`
- set:
  - `BOARD_VENDOR_RAMDISK_KERNEL_MODULES := $(wildcard .../*.ko)`
  - `BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := $(shell cat .../modules.load)`
  - `BOARD_VENDOR_RAMDISK_KERNEL_MODULES_BLOCKLIST_FILE := .../modules.blocklist`

In `device/meizu/m2391/device.mk`:

- copy text load list for recovery mode:
  - `modules.load.recovery -> $(TARGET_COPY_OUT_VENDOR_RAMDISK)/lib/modules/modules.load.recovery`

Important:

- Do **not** copy `.ko` via `PRODUCT_COPY_FILES`; Android 16 non-ELF checks reject ELF files in
  `PRODUCT_COPY_FILES` and fail with:
  - `found ELF prebuilt in PRODUCT_COPY_FILES`

This preserves generated `vendor_boot` path while restoring stock-equivalent module payload
through the kernel-module pipeline.

## 4. Validation checklist

1. `source build/envsetup.sh`
2. `lunch lineage_m2391-bp4a-userdebug`
3. `mka vendorbootimage recoveryimage`
4. unpack generated `vendor_boot.img` and verify:
   - `vendor ramdisk total size` is close to stock class (not minimal 3MB)
   - `lib/modules` contains kernel modules and `modules.*` files
5. flash generated `vendor_boot.img` + recovery and verify:
   - recovery no longer freezes at first screen
   - `adb devices` shows recovery

## 5. Notes

- This change keeps the prebuilt-kernel strategy and does not switch to source-built kernel.
- If additional freeze remains, compare `modules.load*` and missing `.ko` delta against stock ramdisk.
