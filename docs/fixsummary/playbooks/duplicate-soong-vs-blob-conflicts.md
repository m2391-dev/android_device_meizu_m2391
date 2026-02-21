# Playbook: Duplicate Soong-vs-Blob Conflicts

## Scope

Use this playbook when build errors indicate duplicated install rules for the same
`out/target/product/m2391/vendor/...` path, typically during `kati`.

## Typical Signals

- `overriding commands for target ...`
- same install target appears in both:
  - generated vendor blob makefiles
  - Soong/AOSP/QCOM source install lists

## Batch Strategy

1. Identify overlap set by install path category:
   - `vendor/bin`
   - `vendor/etc`
   - `vendor/lib`
   - `vendor/lib64`
2. Remove overlapping blob entries from `device/meizu/m2391/proprietary-files.txt`
   (or partition-specific proprietary list if applicable).
3. Regenerate vendor makefiles via `device/meizu/m2391/extract-files.py`.
4. Rebuild to confirm conflicts are removed.

Do not patch one path at a time unless the overlap set is tiny and isolated.

## Validation

1. `source build/envsetup.sh`
2. `lunch lineage_m2391-bp4a-userdebug`
3. Build target that reproduces conflict (`mka recoveryimage` / `mka bacon`)
4. Confirm no duplicate target override errors remain.

## References

- `../entries/2026/2026-02-17.md`
- `../entries/2026/2026-02-19_VINTF_DUPLICATE_HAL.md`
- `../entries/2026/2026-02-18_SYSPROP_DUPLICATE.md`

