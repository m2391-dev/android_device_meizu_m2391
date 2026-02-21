# LineageOS 23 (m2391) vendor_boot header mismatch fix

Date: 2026-02-18  
Scope: `device/meizu/sm8550-common`, `device/meizu/m2391` bring-up docs  
Target: Fix `mkbootimg` failure when building `vendor_boot.img`.

## 1. Symptom

Build fails at `vendor_boot.img` with:

- `ValueError: --vendor_boot not compatible with given header version`

Observed command did not include `--header_version`, for example:

- `mkbootimg ... --vendor_ramdisk ... --vendor_boot out/target/product/m2391/vendor_boot.img`

## 2. Root cause

`BOARD_BOOT_HEADER_VERSION := 4` and `BOARD_INIT_BOOT_HEADER_VERSION := 4` were set, but
this branch does not auto-inject `--header_version` into `mkbootimg` arguments for
`vendor_boot`/`init_boot` builds.

As a result, `mkbootimg` used an incompatible default header for `--vendor_boot`.

## 3. Fix

In `device/meizu/sm8550-common/BoardConfigCommon.mk`, explicitly pass header versions:

- `BOARD_MKBOOTIMG_ARGS += --header_version $(BOARD_BOOT_HEADER_VERSION)`
- `BOARD_MKBOOTIMG_INIT_ARGS += --header_version $(BOARD_INIT_BOOT_HEADER_VERSION)`

This matches the pattern already used in other SM8550 trees in this source base.

## 4. Validation checklist

1. `source build/envsetup.sh`
2. `lunch lineage_m2391-bp4a-userdebug`
3. Build target that reproduces the failure:
   - `mka vendorbootimage` (or full `mka bacon`)
4. Confirm `mkbootimg` command contains `--header_version 4` and no longer throws
   the compatibility `ValueError`.

