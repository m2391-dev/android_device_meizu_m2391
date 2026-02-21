# LineageOS 23 (m2391) recovery `/metadata/ota` recreate fix

Date: 2026-02-20  
Scope: `device/meizu/m2391`  
Target: remove recovery warning `Open failed: /metadata/ota` in the
`wipe data/metadata -> sideload in same recovery session` flow.

## 1. Symptom

From `device/meizu/m2391/recovery.log`:

- `Open failed: /metadata/ota: No such file or directory`
- `Subsequent calls to SnapshotManager will fail.`

OTA could still complete, but SnapshotManager lock path degraded and `/metadata`
was repeatedly unmounted.

## 2. Root cause

`init.recovery.qcom.rc` previously created `/metadata/ota` only in
`on post-fs-data`.

In the same recovery session, `wipe data` reformats `/metadata` after that
one-shot trigger has already run, so the created directories are removed and are
not recreated before sideload install starts.

## 3. Fix

### 3.1 Add recovery bootstrap service for metadata OTA directory

Added script:

- `device/meizu/m2391/init/recovery_metadata_ota_bootstrap.sh`

Behavior:

- wait for `/dev/block/by-name/metadata`
- mount `/metadata` if needed
- recreate:
  - `/metadata/ota`
  - `/metadata/ota/snapshots`
- restore ownership/permissions/selabel

### 3.2 Trigger bootstrap in both startup and sideload flows

Updated `device/meizu/m2391/init/init.recovery.qcom.rc`:

- add `service metadata_ota_bootstrap ...` (oneshot, disabled)
- replace direct `mkdir` in `on post-fs-data` with `start metadata_ota_bootstrap`
- add `on property:sys.usb.config=sideload` -> `start metadata_ota_bootstrap`

This keeps prior boot-time behavior and adds re-bootstrap right before sideload.

### 3.3 Package script into recovery ramdisk

Updated `device/meizu/m2391/device.mk`:

- copy script to
  `$(TARGET_COPY_OUT_RECOVERY)/root/system/bin/recovery_metadata_ota_bootstrap.sh`

## 4. Validation checklist

1. `source build/envsetup.sh`
2. `lunch lineage_m2391-bp4a-userdebug`
3. `mka recoveryimage vendorbootimage`
4. Flash and reproduce:
   - wipe data/metadata
   - in same recovery session run `adb sideload <package>`
5. Verify in recovery log:
   - no `Open failed: /metadata/ota`
   - no SnapshotManager shared-lock failure due to missing `/metadata/ota`
