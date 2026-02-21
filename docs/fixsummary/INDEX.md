# m2391 Fix Summary Index

This directory is the single entry point for m2391 bring-up fix knowledge.

## Read Order

1. Read this file and map the issue to a conflict class.
2. Read the matching playbook in `playbooks/`.
3. Read latest related entries in `entries/<year>/`.
4. Implement fix with the documented batch strategy first.
5. Add a new entry and update this index in the same change.

## Conflict Class Map

| Class | Use when | Playbook |
| --- | --- | --- |
| `duplicate_soong_vs_blob` | `kati` duplicate install rules, Soong-vs-blob path collisions | `playbooks/duplicate-soong-vs-blob-conflicts.md` |
| `vendor_boot_generated_path` | Generated `vendor_boot` mismatch vs stock (DTB/modules/packaging) | `playbooks/vendor-boot-generated-path.md` |
| `recovery_ota_bringup` | Recovery-side OTA failures (BootControl/USB/metadata/fstab) | `playbooks/recovery-ota-bringup.md` |

## Entries (Newest First)

### 2026-02-20

- `entries/2026/2026-02-20_VENDOR_BOOT_GENERATED_VENDOR_RAMDISK_MODULES.md`
- `entries/2026/2026-02-20_VENDOR_BOOT_GENERATED_DTB_INJECTION.md`
- `entries/2026/2026-02-20_VENDOR_BOOT_RECOVERY_STORAGE.md`
- `entries/2026/2026-02-20_VENDOR_RAMDISK_MODULES_NON_ELF_CHECK.md`
- `entries/2026/2026-02-20_RECOVERY_BOOTCONTROL_AND_FSTAB.md`
- `entries/2026/2026-02-20_RECOVERY_METADATA_OTA_RECREATE.md`
- `entries/2026/2026-02-20_RECOVERY_METADATA_OTA_INITRC_DIRECT.md`

### 2026-02-19

- `entries/2026/2026-02-19_PREBUILT_KERNEL_PACKAGING_MODE.md`
- `entries/2026/2026-02-19_BACON_OTA_PACKAGE.md`
- `entries/2026/2026-02-19_RECOVERYIMAGE_OTA_ALIGNMENT.md`
- `entries/2026/2026-02-19_RECOVERY_USB_CONFIGFS_ADB.md`
- `entries/2026/2026-02-19_VINTF_DUPLICATE_HAL.md`

### 2026-02-18

- `entries/2026/2026-02-18_SYSPROP_DUPLICATE.md`
- `entries/2026/2026-02-18_VENDOR_BOOT_HEADER.md`

### 2026-02-17

- `entries/2026/2026-02-17.md`

## Entry Naming Convention

- Path: `entries/<year>/`
- File name: `YYYY-MM-DD_<TOPIC>.md` (topic can be omitted for broad daily summary)
- Language: keep consistency with existing document context (Chinese or English are both acceptable)

