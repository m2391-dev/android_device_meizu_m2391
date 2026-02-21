# Meizu 20 Pro (m2391) LineageOS 23 Bring-up

This tree targets:
- Device codename: `m2391`
- OTA/assert alias: `meizu20Pro`
- Platform: `kalama` (SM8550)
- Android base: 16 / API 36 (LineageOS 23)

## Tree layout

Meizu SM8550 device trees are split into:
- Common platform layer: `device/meizu/sm8550-common`
- Device layer: `device/meizu/m2391`

`m2391` now follows the same maintenance pattern as other SM8550 families:
- shared product/board definitions live in `sm8550-common`
- per-device specifics stay in `m2391` (asserts, panel density, prebuilt boot chain, props)

## Prebuilt kernel strategy

Kernel-side artifacts are kept under `KERNEL_PATH`
(`device/meizu/m2391-kernel`):
- `Image` (used to build `boot.img` / `init_boot.img`)
- `dtbo.img`
- `vendor-ramdisk/lib/modules/*` (stock module set mirrored for generated `vendor_boot`)
- `dtb.img` (injected into generated `vendor_boot`)
- `vendor_dlkm.img` and `system_dlkm.img`

Legacy stock `boot.img` / `init_boot.img` / `vendor_boot.img` are intentionally
removed from `KERNEL_PATH` to keep only actively-consumed prebuilts.

`BoardConfig.mk` keeps prebuilt kernel input while generating `boot`/`init_boot`,
generates `vendor_boot` in-tree, injects stock-derived `dtb.img`, and injects
stock vendor-ramdisk kernel modules via `BOARD_VENDOR_RAMDISK_KERNEL_MODULES`
(instead of `PRODUCT_COPY_FILES`), while keeping standalone `recovery`
(ramdisk-only), with prebuilt `dtbo` and `*_dlkm`.

## Bring-up fix knowledge base

Fix summaries are organized under:

- `device/meizu/m2391/docs/fixsummary/INDEX.md` (entry point)
- `device/meizu/m2391/docs/fixsummary/playbooks/` (class-based strategy)
- `device/meizu/m2391/docs/fixsummary/entries/<year>/` (dated fix records)

When adding a new fix summary entry, update `INDEX.md` in the same change.

## Blob extraction

Use the mounted dump supplied by the user:

```bash
cd device/meizu/m2391
./extract-files.py /home/zhi/Downloads/system_dump/mnt
```

If your dump location is different, pass a different source path.

## Blob profile and layering

The extraction flow supports partition-layered blob lists:
- `proprietary-files.txt` (vendor)
- `proprietary-files-product.txt`
- `proprietary-files-system_ext.txt`
- `proprietary-files-odm.txt`

Recommended strategy:
- Keep vendor list stable for baseline boot.
- Add non-vendor blobs incrementally in partition-specific lists.
- After each batch, regenerate makefiles and run overlap checks against Soong installs.
- Continue using copy-rule-first for unstable binaries; keep APKs as package modules.

## Notes

- Dynamic partition sizing comes from `fastboot getvar` data (`super = 0x200000000`).
- `fstab.qcom` is synced from stock vendor ramdisk to keep first-stage mount behavior aligned.
- Recovery uses a dedicated `recovery.fstab` to avoid `/dev/block/bootdevice` alias dependency.
