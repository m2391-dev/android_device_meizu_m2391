# LineageOS 23 (m2391) sysprop duplicate fix summary

Date: 2026-02-18  
Scope: `device/meizu/m2391`  
Target: fix `vendor/build.prop` generation failure caused by duplicate sysprop assignments.

## 1. Symptom

`brunch lineage_m2391-bp4a-userdebug` failed while generating:

- `out/target/product/m2391/vendor/build.prop`

Error:

- duplicate `ro.vendor.build.version.release` (`16` vs `13`)
- duplicate `ro.vendor.build.version.sdk` (`36` vs `33`)

## 2. Root cause

`device/meizu/m2391/vendor.prop` still hardcoded Android 13-era values:

- `ro.vendor.build.version.release=13`
- `ro.vendor.build.version.sdk=33`

On LineageOS 23 / Android 16, build system already emits:

- `ro.vendor.build.version.release=16`
- `ro.vendor.build.version.sdk=36`

So `post_process_props` aborted on duplicates.

## 3. Fix

Removed only these two keys from `device/meizu/m2391/vendor.prop`:

- `ro.vendor.build.version.release=13`
- `ro.vendor.build.version.sdk=33`

Kept compatibility-critical baseline properties:

- `ro.product.first_api_level=33`
- `ro.board.first_api_level=33`
- `ro.board.api_level=33`
- `ro.vendor.build.security_patch=2023-10-01`

## 4. Rule for future bring-up

For platform-upgrade builds (Android 15/16+), do not set:

- `ro.vendor.build.version.release`
- `ro.vendor.build.version.sdk`

in device/vendor static property files. Let build system generate them from
the current platform target, and keep only vendor baseline compatibility
properties (first API level, board API, security patch) in `vendor.prop`.
