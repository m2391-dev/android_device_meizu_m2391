#
# SPDX-FileCopyrightText: 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/meizu/m2391
KERNEL_PATH := device/meizu/m2391-kernel

# Inherit from the common SM8550 Meizu product makefile.
$(call inherit-product, device/meizu/sm8550-common/common.mk)

# Keep first-stage mount config consistent with stock vendor_boot ramdisk.
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/init/fstab.qcom:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/first_stage_ramdisk/fstab.qcom

# Keep recovery-specific module load order aligned with stock.
PRODUCT_COPY_FILES += \
    $(KERNEL_PATH)/vendor-ramdisk/lib/modules/modules.load.recovery:$(TARGET_COPY_OUT_VENDOR_RAMDISK)/lib/modules/modules.load.recovery

# Feed stock-derived DTB payload into generated vendor_boot (Soong fsgen looks
# for PRODUCT_COPY_FILES destination "dtb.img" when BOARD_INCLUDE_DTB_IN_BOOTIMG=true).
PRODUCT_COPY_FILES += \
    $(KERNEL_PATH)/dtb.img:dtb.img

# Device-specific init extension for debug and product hooks.
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/init/init.m2391.rc:$(TARGET_COPY_OUT_VENDOR)/etc/init/init.m2391.rc

# Recovery USB/configfs initialization hook (imported by recovery init as
# /init.recovery.${ro.hardware}.rc).
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/init/init.recovery.qcom.rc:$(TARGET_COPY_OUT_RECOVERY)/root/init.recovery.qcom.rc

# BootControl in recovery: required by update_engine_sideload on A/B devices.
PRODUCT_PACKAGES += \
    android.hardware.boot-service.qti \
    android.hardware.boot-service.qti.recovery

# VINTF (Android 16 forbids VINTF XML in PRODUCT_COPY_FILES).
# Exclude fragments that are already installed by source modules, otherwise
# they collide with entries generated into vendor/etc/vintf/manifest.xml.
DEVICE_MANIFEST_FRAGMENT_OVERLAPS := \
    vendor/meizu/m2391/proprietary/vendor/etc/vintf/manifest/android.hardware.atrace@1.0-service.xml \
    vendor/meizu/m2391/proprietary/vendor/etc/vintf/manifest/android.hardware.boot@1.2.xml \
    vendor/meizu/m2391/proprietary/vendor/etc/vintf/manifest/android.hardware.cas@1.2-service.xml \
    vendor/meizu/m2391/proprietary/vendor/etc/vintf/manifest/android.hardware.drm-service.clearkey.xml \
    vendor/meizu/m2391/proprietary/vendor/etc/vintf/manifest/android.hardware.graphics.mapper-impl-qti-display.xml \
    vendor/meizu/m2391/proprietary/vendor/etc/vintf/manifest/android.hardware.health-service.qti.xml \
    vendor/meizu/m2391/proprietary/vendor/etc/vintf/manifest/android.hardware.sensors-multihal.xml \
    vendor/meizu/m2391/proprietary/vendor/etc/vintf/manifest/android.hardware.usb.gadget@1.1-service.xml \
    vendor/meizu/m2391/proprietary/vendor/etc/vintf/manifest/android.hardware.wifi.hostapd.xml \
    vendor/meizu/m2391/proprietary/vendor/etc/vintf/manifest/android.hardware.wifi.supplicant.xml \
    vendor/meizu/m2391/proprietary/vendor/etc/vintf/manifest/bluetooth_audio.xml \
    vendor/meizu/m2391/proprietary/vendor/etc/vintf/manifest/manifest_non_qmaa.xml \
    vendor/meizu/m2391/proprietary/vendor/etc/vintf/manifest/memtrack_qti.xml \
    vendor/meizu/m2391/proprietary/vendor/etc/vintf/manifest/power.xml \
    vendor/meizu/m2391/proprietary/vendor/etc/vintf/manifest/vendor.qti.hardware.display.allocator-service.xml \
    vendor/meizu/m2391/proprietary/vendor/etc/vintf/manifest/vendor.qti.hardware.display.composer-service.xml \
    vendor/meizu/m2391/proprietary/vendor/etc/vintf/manifest/vendor.qti.hardware.display.demura-service.xml \
    vendor/meizu/m2391/proprietary/vendor/etc/vintf/manifest/vendor.qti.hardware.vibrator.service.xml \
    vendor/meizu/m2391/proprietary/vendor/etc/vintf/manifest/vendor.qti.qspa-service.xml

DEVICE_MANIFEST_FILE += \
    $(filter-out $(DEVICE_MANIFEST_FRAGMENT_OVERLAPS), \
        $(wildcard vendor/meizu/m2391/proprietary/vendor/etc/vintf/manifest/*.xml)) \
    $(wildcard vendor/meizu/m2391/proprietary/vendor/etc/vintf/manifest_kalama.xml)

DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE += \
    hardware/qcom-caf/common/vendor_framework_compatibility_matrix.xml \
    $(DEVICE_PATH)/vintf/device_framework_matrix.xml

# Overlays
DEVICE_PACKAGE_OVERLAYS += \
    $(DEVICE_PATH)/overlay-lineage

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(DEVICE_PATH) \
    $(KERNEL_PATH)

# Inherit from the proprietary files makefile when blobs are extracted.
$(call inherit-product-if-exists, vendor/meizu/m2391/m2391-vendor.mk)
