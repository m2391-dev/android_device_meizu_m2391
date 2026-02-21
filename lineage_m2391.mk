#
# SPDX-FileCopyrightText: 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit_only.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)

# Inherit from m2391 device.
$(call inherit-product, device/meizu/m2391/device.mk)

# Inherit some common Lineage stuff.
$(call inherit-product, vendor/lineage/config/common_full_phone.mk)

PRODUCT_NAME := lineage_m2391
PRODUCT_DEVICE := m2391
PRODUCT_MANUFACTURER := meizu
PRODUCT_BRAND := meizu
PRODUCT_MODEL := MEIZU 20 Pro

PRODUCT_GMS_CLIENTID_BASE := android-meizu

# Prebuilt-kernel bring-up: force OTA package generation so bacon always has
# INTERNAL_OTA_PACKAGE_TARGET.
PRODUCT_BUILD_GENERIC_OTA_PACKAGE := true

PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="qssi-user 16 BQ2A.251110.001-BP2A.250605.031.A3 1764145455 release-keys" \
    BuildFingerprint=meizu/meizu_20Pro_CN/meizu20Pro:16/BQ2A.251016.001-BP2A.250605.031.A3/1764145455:user/release-keys \
    DeviceName=meizu20Pro \
    DeviceProduct=meizu_20Pro_CN \
    SystemDevice=meizu20Pro \
    SystemName=meizu_20Pro_CN
