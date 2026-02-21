# LineageOS 23 (m2391) recovery OTA BootControl + fstab compatibility fix

Date: 2026-02-20  
Scope: `device/meizu/m2391`  
Target: fix recovery sideload abort in BootControl init stage and remove repeated
`unknown flag: resize` parser warnings.

## 1. Symptom

From `device/meizu/m2391/recovery.log`:

- OTA sideload failed after signature verification:
  - `Error getting bootctrl v1.0 module.`
  - `Error initializing the BootControlInterface.`
  - `Error in /sideload/package.zip (status 1)`
- Recovery repeatedly warned:
  - `Warning: unknown flag: resize`

## 2. Root cause

### 2.1 BootControl service missing in recovery product packaging

`update_engine_sideload` uses `BootControlClient` and first looks for AIDL
`IBootControl/default`. In the current product config, qti boot HAL packages
for normal/recovery modes were not included, so recovery fell back to legacy
`bootctrl` module path and failed.

### 2.2 recovery.fstab carried unsupported `resize` fs_mgr flag

Current branch parser reported `resize` as unknown for `/data` entry, creating
persistent noise and potential behavior divergence from intended mount flags.

## 3. Fix

### 3.1 Add qti boot HAL packages to m2391 product

Updated `device/meizu/m2391/device.mk`:

- `android.hardware.boot-service.qti`
- `android.hardware.boot-service.qti.recovery`

This aligns with known SM8550 bring-up pattern and makes recovery-side
BootControl AIDL service available for OTA sideload.

### 3.2 Remove unsupported `resize` from recovery `/data` fstab entry

Updated `device/meizu/m2391/init/recovery.fstab`:

- removed `resize` from `/data` fs_mgr flags

### 3.3 Add metadata OTA directory bootstrap in recovery init

Updated `device/meizu/m2391/init/init.recovery.qcom.rc`:

- create `/metadata/ota`
- create `/metadata/ota/snapshots`

This reduces SnapshotManager lock-path failures when metadata directory layout
is absent.

## 4. Validation status

Environment validation was run with:

1. `source build/envsetup.sh`
2. `lunch lineage_m2391-bp4a-userdebug`

Result:

- Product configuration and Soong/Make graph generation succeeded with the new
  package wiring (`android.hardware.boot-service.qti(.recovery)` resolved).
- Full compile was intentionally stopped after entering large ninja phase due
  runtime cost in this session.

### 4.1 Device-side recovery log regression result (same day)

Updated `device/meizu/m2391/recovery.log` confirms:

- `Using AIDL version of IBootControl`
- `Loaded boot control hal.`
- `Update successfully applied, waiting to reboot.`
- `Install completed with status 0.`

So the previous hard failure (`Error getting bootctrl v1.0 module`) is resolved.

Residual warnings remained (non-blocking for this sideload run):

- `/metadata/ota` missing in some recovery flows after metadata format
- repeated `unable to start transaction in checkpointing`

## 5. Follow-up checklist

1. Build and flash updated recovery/vendor_boot artifacts.
2. Re-test `adb sideload` in recovery and confirm BootControl init no longer
   falls back to `bootctrl v1.0` error path.
3. Re-test after data/metadata wipe flow and confirm `/metadata/ota` remains
   available for snapshot operations.
