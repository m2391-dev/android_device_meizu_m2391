# LineageOS 23 (m2391) recovery USB ADB bring-up (configfs import fix)

Date: 2026-02-19  
Scope: `device/meizu/m2391`  
Target: fix recovery-side ADB enumeration failure with logs:
- `failed to open /sys/class/android_usb/android0/state`
- `cannot open control endpoint /dev/usb-ffs/adb/ep0: No such file or directory`

## 1. Symptom

Observed with stock-prebuilt `vendor_boot` + built `recovery.img`:

- device can enter recovery, but host `adb devices` does not show recovery device.
- recovery log prints missing legacy android_usb node and missing functionfs ep0 endpoint.

## 2. Root cause

Built recovery ramdisk did not include a device-specific `init.recovery.qcom.rc`.

`bootable/recovery/etc/init.rc` always imports:

- `/init.recovery.${ro.hardware}.rc`

For `m2391` (`ro.hardware=qcom`), missing this imported file caused:

1. no device hook to force `sys.usb.configfs=1` for recovery gadget path
2. no initialization of `sys.usb.controller` from `ro.boot.usbcontroller`
3. no controller mode switch (`.../mode -> peripheral`) and UDC wait sequence

Result: recovery attempted legacy `/sys/class/android_usb/android0/*` path on this device and USB ADB was not brought up reliably.

## 3. Fix

### 3.1 Add recovery qcom init hook

Added:

- `device/meizu/m2391/init/init.recovery.qcom.rc`

with stock-aligned bring-up actions:

- set `sys.usb.configfs=1` on init
- set `sys.usb.controller` from `ro.boot.usbcontroller`
- switch DWC3 mode to peripheral and wait UDC node
- keep `/dev/block/bootdevice` symlink creation for compatibility

### 3.2 Package the hook into recovery root

In `device/meizu/m2391/device.mk`:

- copy to recovery root as:
  - `$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.qcom.rc`

This satisfies `import /init.recovery.${ro.hardware}.rc` during recovery boot.

## 4. Validation checklist

1. `source build/envsetup.sh`
2. `lunch lineage_m2391-bp4a-userdebug`
3. `mka recoveryimage`
4. verify file exists in recovery ramdisk:
   - `out/target/product/m2391/recovery/root/init.recovery.qcom.rc`
5. flash recovery + stock-prebuilt vendor_boot and verify:
   - no persistent `android_usb/android0/state` failure loop
   - `adb devices` shows recovery

## 5. Notes

- This fix keeps prebuilt-kernel strategy unchanged.
- No upstream/common AOSP or Lineage source tree modifications are required.
