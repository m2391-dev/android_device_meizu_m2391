# LineageOS 23 (m2391) VINTF duplicate HAL manifest fix

Date: 2026-02-19  
Scope: `device/meizu/m2391`  
Target: fix `checkvintf` failure caused by duplicate HAL instance declarations.

## 1. Symptom

Build fails at:

- `out/target/product/m2391/obj/PACKAGING/check_vintf_all_intermediates/check_vintf_vendor.log`
- `out/target/product/m2391/obj/PACKAGING/check_vintf_all_intermediates/check_vintf_compatible.log`

Representative error:

- `VINTF parse error: ... HAL "android.hardware.cas" has a conflict`
- conflict path pair:
  - `/vendor/etc/vintf/manifest.xml`
  - `/vendor/etc/vintf/manifest/android.hardware.cas@1.2-service.xml`

## 2. Root cause

`device/meizu/m2391/device.mk` used:

- `DEVICE_MANIFEST_FILE += $(wildcard vendor/meizu/m2391/proprietary/vendor/etc/vintf/manifest/*.xml)`

This made `vendor_manifest.xml` generate `vendor/etc/vintf/manifest.xml` from
blob fragments.

At the same time, a subset of those same fragment filenames were installed by
source modules into `vendor/etc/vintf/manifest/*.xml` (for example
`android.hardware.cas@1.2-service.xml`).

Result: one HAL/FqInstance was declared in both:

- generated `manifest.xml`
- installed fragment file

which `checkvintf` rejects.

## 3. Fix strategy (batch)

Apply a **batch overlap filter** in `device.mk`:

1. Keep vendor blob fragment inputs for merge.
2. Exclude fragment files whose install paths are already provided by source
   modules.
3. Continue to include `manifest_kalama.xml`.

Implemented via:

- `DEVICE_MANIFEST_FRAGMENT_OVERLAPS := ...` (19 entries)
- `DEVICE_MANIFEST_FILE += $(filter-out $(DEVICE_MANIFEST_FRAGMENT_OVERLAPS), $(wildcard .../manifest/*.xml)) ...`

## 4. Overlap set removed from merge input

- `android.hardware.atrace@1.0-service.xml`
- `android.hardware.boot@1.2.xml`
- `android.hardware.cas@1.2-service.xml`
- `android.hardware.drm-service.clearkey.xml`
- `android.hardware.graphics.mapper-impl-qti-display.xml`
- `android.hardware.health-service.qti.xml`
- `android.hardware.sensors-multihal.xml`
- `android.hardware.usb.gadget@1.1-service.xml`
- `android.hardware.wifi.hostapd.xml`
- `android.hardware.wifi.supplicant.xml`
- `bluetooth_audio.xml`
- `manifest_non_qmaa.xml`
- `memtrack_qti.xml`
- `power.xml`
- `vendor.qti.hardware.display.allocator-service.xml`
- `vendor.qti.hardware.display.composer-service.xml`
- `vendor.qti.hardware.display.demura-service.xml`
- `vendor.qti.hardware.vibrator.service.xml`
- `vendor.qti.qspa-service.xml`

## 5. Validation checklist

1. `source build/envsetup.sh`
2. `lunch lineage_m2391-bp4a-userdebug`
3. `brunch lineage_m2391-bp4a-userdebug` (or `mka bacon`)
4. Confirm no `VINTF parse error ... Conflicting FqInstance` in
   `check_vintf_vendor.log` / `check_vintf_compatible.log`.
