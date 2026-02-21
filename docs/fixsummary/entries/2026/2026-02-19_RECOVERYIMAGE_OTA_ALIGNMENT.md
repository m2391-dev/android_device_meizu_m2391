# LineageOS 23 (m2391) recoveryimage + OTA partition alignment

Date: 2026-02-19  
Scope: `device/meizu/sm8550-common` and `device/meizu/m2391` docs  
Target: align recovery build/OTA behavior with stock package layout.

## 1. Symptom

- `mka recoveryimage` returned `ninja: no work to do`.
- Stock package under `/home/zhi/Downloads/system_dump/images` includes
  `recovery.img` and official `payload.bin` also contains `recovery`.

## 2. Stock behavior confirmation

Validation used local stock dump artifacts:

- `/home/zhi/Downloads/system_dump/images/recovery.img` exists.
- `out/host/linux-x86/bin/ota_extractor --payload ... --partitions recovery`
  successfully extracted `recovery`.
- `unpack_bootimg` showed:
  - stock `boot.img`: kernel present, ramdisk empty
  - stock `recovery.img`: kernel empty, ramdisk present

This indicates standalone recovery partition usage with recovery ramdisk content
packaged separately from boot kernel.

## 3. Root cause in current tree

`device/meizu/sm8550-common/BoardConfigCommon.mk` had:

- `TARGET_NO_RECOVERY := true` (disables standalone recovery build)
- `AB_OTA_PARTITIONS` list without `recovery`

So `recoveryimage` target was intentionally disabled and OTA partition metadata
did not include recovery.

## 4. Fix

Updated `device/meizu/sm8550-common/BoardConfigCommon.mk`:

1. add `recovery` to `AB_OTA_PARTITIONS`
2. set `BOARD_EXCLUDE_KERNEL_FROM_RECOVERY_IMAGE := true`
3. remove `TARGET_NO_RECOVERY := true`

Resulting mode:

- standalone `recovery.img` is build-enabled
- recovery remains kernel-excluded (ramdisk-oriented), matching stock split
- prebuilt kernel strategy for `boot` / `init_boot` / `vendor_boot` is unchanged

## 5. Validation checklist

1. `source build/envsetup.sh`
2. `lunch lineage_m2391-bp4a-userdebug`
3. `mka recoveryimage`
4. verify output:
   - `out/target/product/m2391/recovery.img`
5. optional:
   - inspect `out/target/product/m2391/fastboot-info.txt`
   - confirm `recovery` appears in AB OTA partition metadata

## 6. Notes

- This change does not switch to source-built kernel.
- OTA assert aliases remain unchanged (`m2391,meizu20Pro`).
