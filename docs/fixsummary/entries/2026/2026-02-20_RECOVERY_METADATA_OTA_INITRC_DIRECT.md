# LineageOS 23 (m2391) recovery `/metadata/ota` direct init.rc re-bootstrap

Date: 2026-02-20  
Scope: `device/meizu/m2391`  
Target: fix persistent `/metadata/ota` missing warning after applying the first
bootstrap attempt.

## 1. Symptom after previous fix

New recovery regression log still showed:

- `Open failed: /metadata/ota: No such file or directory`
- SnapshotManager shared-lock failure and `/metadata` unmount

even after adding `metadata_ota_bootstrap` shell service.

## 2. Root cause hypothesis

The service-based implementation depended on an external script execution path in
recovery ramdisk (`/system/bin/recovery_metadata_ota_bootstrap.sh`). This added
extra failure points (packaging path, execution context, runtime visibility), and
the log did not show evidence that directory bootstrap actually executed.

## 3. Fix (v2)

Replaced service+script with direct init builtins in
`device/meizu/m2391/init/init.recovery.qcom.rc`.
The directory bootstrap now also aligns with AOSP metadata layout practice
(same class of change as
`rahulsnair/android_device_motorola_cybert_bak@45de71938d89`).

Added a dedicated trigger action:

- `on m2391-recovery-metadata-bootstrap`

with:

1. `wait /dev/block/by-name/metadata`
2. `mount f2fs /dev/block/by-name/metadata /metadata ...`
3. restore and create metadata subdirs (`vold`, `password_slots`, `bootstat`,
   `ota`, `ota/snapshots`, `apex/*`)
4. `restorecon_recursive` for `/metadata/ota` and `/metadata/apex`

Trigger points:

- `on post-fs-data`
- `on property:sys.usb.config=sideload`
- `on property:sys.usb.state=sideload`

Also removed obsolete script packaging from `device/meizu/m2391/device.mk`.

## 4. Why this is more robust

- no external script dependency
- no extra shell process/exec path
- all operations are native init commands under the same trigger context
- re-bootstrap happens exactly when entering sideload mode (after wipe flow)

## 5. Validation checklist

1. Rebuild and flash updated recovery artifacts.
2. Reproduce sequence:
   - wipe data (includes metadata format)
   - stay in same recovery session
   - run `adb sideload <package>`
3. Confirm in recovery log:
   - no `Open failed: /metadata/ota`
   - no SnapshotManager lock failure due to missing `/metadata/ota`

Note: if sideload ends with downgrade rejection, that is independent from this
directory bootstrap issue and should be validated with a non-downgrade package.
