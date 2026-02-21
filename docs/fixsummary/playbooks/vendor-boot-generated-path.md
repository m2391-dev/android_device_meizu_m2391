# Playbook: Generated Vendor Boot Path

## Scope

Use this playbook when moving between prebuilt and build-generated `vendor_boot`
or when generated output differs from stock in boot-critical content.

## Typical Signals

- recovery fails to boot with generated `vendor_boot.img`
- unpacked generated image has `dtb size: 0`
- generated vendor ramdisk lacks stock-equivalent kernel module payload

## Strategy

1. Keep prebuilt kernel mode unchanged:
   - keep `TARGET_PREBUILT_KERNEL`
   - do not switch to source-built kernel as a side effect
2. Compare stock and generated `vendor_boot` composition:
   - DTB presence
   - vendor ramdisk module payload (`.ko`, `modules.load*`, blocklist)
3. Apply fixes in this order:
   - DTB inclusion path
   - vendor ramdisk kernel module pipeline
   - non-ELF packaging compliance (`PRODUCT_COPY_FILES` vs kernel-module vars)
4. Rebuild `vendorbootimage` and validate unpacked image before flashing.

## Validation

1. `source build/envsetup.sh`
2. `lunch lineage_m2391-bp4a-userdebug`
3. `mka vendorbootimage recoveryimage`
4. Unpack generated `vendor_boot.img` and verify DTB/modules match expected class.
5. Flash and verify recovery boot stability.

## References

- `../entries/2026/2026-02-19_PREBUILT_KERNEL_PACKAGING_MODE.md`
- `../entries/2026/2026-02-20_VENDOR_BOOT_GENERATED_DTB_INJECTION.md`
- `../entries/2026/2026-02-20_VENDOR_BOOT_GENERATED_VENDOR_RAMDISK_MODULES.md`
- `../entries/2026/2026-02-20_VENDOR_RAMDISK_MODULES_NON_ELF_CHECK.md`
- `../entries/2026/2026-02-20_VENDOR_BOOT_RECOVERY_STORAGE.md`

