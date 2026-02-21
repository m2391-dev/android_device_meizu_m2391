# LineageOS 23 (m2391) vendor_boot + recovery storage bring-up fix

Date: 2026-02-20  
Scope: `device/meizu/m2391`  
Target: fix two linked bring-up failures:
- build-generated `vendor_boot.img` cannot boot recovery
- recovery entered with stock `vendor_boot.img` but cannot resolve `/dev/block/bootdevice/by-name/*`

## 1. Symptom

Observed on device:

- flashing build-generated `vendor_boot.img` fails to boot into recovery.
- flashing stock `vendor_boot.img` enters recovery, but recovery logs include:
  - `Failed to stat /dev/block/bootdevice/by-name/misc`
  - `Failed to open '/dev/block/bootdevice/by-name/userdata'`
  - `minadbd ... /dev/usb-ffs/adb/ep0: No such file or directory`

## 2. Root cause

### 2.1 Generated vendor_boot content mismatch vs stock

Unpack comparison showed:

- stock `vendor_boot.img`:
  - `vendor_ramdisk` contains full module set (`.ko` + `modules.load*`)
  - `dtb size` is non-zero
- build-generated `out/target/product/m2391/vendor_boot.img`:
  - `vendor_ramdisk` contains only minimal userspace files (no kernel modules)
  - `dtb size: 0`

So generated `vendor_boot` was missing required runtime pieces for stable recovery bring-up.

### 2.2 Recovery fstab depended on `bootdevice` alias path

Current recovery was using a fstab with entries like:

- `/dev/block/bootdevice/by-name/misc`
- `/dev/block/bootdevice/by-name/userdata`

On this bring-up path, `bootdevice` alias availability was not reliable at recovery stage.

## 3. Fix

### 3.1 Use stock-prebuilt vendor_boot in BoardConfig

In `device/meizu/m2391/BoardConfig.mk`:

- add `BOARD_PREBUILT_VENDOR_BOOTIMAGE := $(KERNEL_PATH)/vendor_boot.img`
- keep:
  - `TARGET_NO_KERNEL := false`
  - `TARGET_PREBUILT_KERNEL := .../Image`
  - prebuilt `dtbo/system_dlkm/vendor_dlkm`

This keeps prebuilt-kernel strategy and restores known-good vendor ramdisk + DTB composition.

### 3.2 Split recovery fstab from first-stage vendor fstab

Added a dedicated recovery fstab:

- `device/meizu/m2391/init/recovery.fstab`

and switched:

- `TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/init/recovery.fstab`

Recovery fstab uses `/dev/block/by-name/*` for non-logical partitions, avoiding dependency on
`/dev/block/bootdevice/by-name/*` alias creation timing.

First-stage mount flow remains unchanged:

- `device.mk` still copies `init/fstab.qcom` to `$(TARGET_COPY_OUT_VENDOR_RAMDISK)/first_stage_ramdisk/fstab.qcom`

## 4. Validation checklist

1. `source build/envsetup.sh`
2. `lunch lineage_m2391-bp4a-userdebug`
3. `mka vendorbootimage recoveryimage`
4. Verify:
   - `out/target/product/m2391/vendor_boot.img` is prebuilt-based (stock-size class, with modules + dtb)
   - recovery uses `device/meizu/m2391/init/recovery.fstab`
5. Flash and verify in recovery:
   - `/misc` and `/data` no longer fail on missing `/dev/block/bootdevice/by-name/*`
   - `adb devices` works once USB gadget is brought up

## 5. Follow-up (if switching back to generated vendor_boot later)

If bring-up later re-enables generated `vendor_boot`, ensure both are solved first:

- vendor ramdisk module packaging (including load list behavior)
- dtb inclusion path for vendor_boot

Do not switch back until unpacked output matches stock boot-critical composition.
