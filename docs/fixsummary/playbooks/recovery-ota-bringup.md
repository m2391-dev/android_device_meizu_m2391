# Playbook: Recovery OTA Bring-up

## Scope

Use this playbook for recovery-side OTA/sideload failures and early recovery
runtime readiness issues.

## Typical Signals

- BootControl initialization failure in recovery OTA flow
- recovery ADB USB gadget bring-up failure
- `/metadata/ota` missing during sideload/snapshot flow
- recovery fstab path compatibility issues

## Strategy

1. Confirm recovery boot chain assumptions first:
   - standalone `recovery.img` mode
   - expected `vendor_boot` composition for recovery runtime
2. Verify recovery runtime dependencies by subsystem:
   - boot control HAL/service registration in recovery context
   - USB configfs init import and controller mode handling
   - `metadata` directory bootstrap timing and trigger points
   - recovery fstab device-path compatibility
3. Make device-side changes in `device/meizu/m2391` first; avoid upstream/common edits unless required.
4. Validate on-device with explicit sideload regression flow.

## Validation

1. `source build/envsetup.sh`
2. `lunch lineage_m2391-bp4a-userdebug`
3. Build required targets (`mka recoveryimage vendorbootimage bacon`)
4. Flash test build and run `adb sideload` regression.
5. Confirm OTA completes without previous blocker signatures.

## References

- `../entries/2026/2026-02-19_RECOVERYIMAGE_OTA_ALIGNMENT.md`
- `../entries/2026/2026-02-19_RECOVERY_USB_CONFIGFS_ADB.md`
- `../entries/2026/2026-02-20_RECOVERY_BOOTCONTROL_AND_FSTAB.md`
- `../entries/2026/2026-02-20_RECOVERY_METADATA_OTA_RECREATE.md`
- `../entries/2026/2026-02-20_RECOVERY_METADATA_OTA_INITRC_DIRECT.md`

