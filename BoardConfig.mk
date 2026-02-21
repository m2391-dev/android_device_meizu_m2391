#
# SPDX-FileCopyrightText: 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Partitions
BOARD_SUPER_PARTITION_SIZE := 8589934592 # 0x200000000

# Include the common SM8550 Meizu BoardConfig.
include device/meizu/sm8550-common/BoardConfigCommon.mk

DEVICE_PATH := device/meizu/m2391
KERNEL_PATH := device/meizu/m2391-kernel

# Assert
TARGET_OTA_ASSERT_DEVICE := m2391,meizu20Pro

# Prebuilt kernel artifacts
# Keep kernel binary prebuilt and generate boot/init_boot/vendor_boot in build.
TARGET_NO_KERNEL := false
TARGET_PREBUILT_KERNEL := $(KERNEL_PATH)/Image
# Required by vendor/lineage/build/tasks/kernel.mk version checks in prebuilt-kernel mode.
TARGET_KERNEL_VERSION := 5.15
# Feed stock vendor-ramdisk kernel modules through kernel-module build pipeline
# (not PRODUCT_COPY_FILES) to satisfy non-ELF prebuilt checks.
M2391_VENDOR_RAMDISK_MODULE_DIR := $(KERNEL_PATH)/vendor-ramdisk/lib/modules
BOARD_VENDOR_RAMDISK_KERNEL_MODULES := $(wildcard $(M2391_VENDOR_RAMDISK_MODULE_DIR)/*.ko)
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_LOAD := $(strip $(shell cat $(M2391_VENDOR_RAMDISK_MODULE_DIR)/modules.load))
BOARD_VENDOR_RAMDISK_KERNEL_MODULES_BLOCKLIST_FILE := $(M2391_VENDOR_RAMDISK_MODULE_DIR)/modules.blocklist
# Inject stock-derived DTB into generated vendor_boot (header v4 path).
BOARD_INCLUDE_DTB_IN_BOOTIMG := true
BOARD_PREBUILT_DTBOIMAGE := $(KERNEL_PATH)/dtbo.img
BOARD_PREBUILT_SYSTEM_DLKMIMAGE := $(KERNEL_PATH)/system_dlkm.img
BOARD_PREBUILT_VENDOR_DLKMIMAGE := $(KERNEL_PATH)/vendor_dlkm.img

# Display
TARGET_SCREEN_DENSITY := 440

# Recovery
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/init/recovery.fstab

# Properties
TARGET_ODM_PROP += $(DEVICE_PATH)/odm.prop
TARGET_SYSTEM_PROP += $(DEVICE_PATH)/system.prop
TARGET_VENDOR_PROP += $(DEVICE_PATH)/vendor.prop

# Include proprietary board flags when blobs are generated.
-include vendor/meizu/m2391/BoardConfigVendor.mk
