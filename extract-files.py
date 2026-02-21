#!/usr/bin/env -S PYTHONPATH=../../../tools/extract-utils python3
#
# SPDX-FileCopyrightText: 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

import os

from extract_utils.elf import get_file_machine_bits_libs
from extract_utils.file import FileArgs
from extract_utils.fixups_blob import (
    blob_fixup,
    blob_fixups_user_type,
)
from extract_utils.main import ExtractUtils, ExtractUtilsModule

namespace_imports = [
    'device/meizu/sm8550-common',
    'hardware/qcom-caf/sm8550',
    'hardware/qcom-caf/wlan',
    'vendor/qcom/opensource/commonsys-intf/display',
]

blob_fixups: blob_fixups_user_type = {
    # Android 16 sets BOARD_SEPOLICY_VERS (e.g. 202504). Keep vendor manifest
    # fragments from hardcoding legacy sepolicy versions (e.g. 33.0).
    'vendor/etc/vintf/manifest_kalama.xml': blob_fixup()
        .regex_replace(
            r'(?s)\n\s*<sepolicy>\s*<version>[^<]+</version>\s*</sepolicy>\s*',
            '\n',
        ),
    # FCM in Android 16 requires AIDL fingerprint HAL version >= 2.
    'vendor/etc/vintf/manifest/qfp-daemon.xml': blob_fixup()
        .regex_replace(
            r'(?s)(<name>android\.hardware\.biometrics\.fingerprint</name>\s*<version>)1(</version>)',
            r'\g<1>2\g<2>',
        ),
    # Drop legacy HIDL interface tags whose interface definitions are not
    # available in current source manifests; they trip host_init_verifier.
    'vendor/etc/init/qfp-daemon.rc': blob_fixup()
        .regex_replace(
            r'(?m)^\s*interface vendor\.qti\.hardware\.fingerprint@1\.0::IQtiExtendedFingerprint default\n',
            '',
        ),
    'vendor/etc/init/vendor.aks.gamepad@1.0-service.rc': blob_fixup()
        .regex_replace(
            r'(?m)^\s*interface vendor\.aks\.gamepad@1\.0::IGamepad default\n',
            '',
        ),
    'vendor/etc/init/vendor.qti.hardware.wifi.wifilearner@1.0-service.rc': blob_fixup()
        .regex_replace(
            r'(?m)^\s*interface vendor\.qti\.hardware\.wifi\.wifilearner@1\.0::IWifiStats wifiStats\n',
            '',
        ),
}

module = ExtractUtilsModule(
    'm2391',
    'meizu',
    blob_fixups=blob_fixups,
    namespace_imports=namespace_imports,
    skip_main_proprietary_file=True,
)


main_proprietary_file = module.add_proprietary_file('proprietary-files.txt')
module.add_proprietary_file('proprietary-files-product.txt')
module.add_proprietary_file('proprietary-files-system_ext.txt')
module.add_proprietary_file('proprietary-files-odm.txt')


def apply_elf_no_deps(*_args, **_kwargs):
    vendor_prop_path = os.path.join(module.vendor_path, 'proprietary')

    # Keep proprietary-files.txt clean while avoiding bring-up blockers from
    # unresolved DT_NEEDED variants in prebuilts.
    for file in main_proprietary_file.file_list.package_files:
        file_path = os.path.join(vendor_prop_path, file.dst)
        if not os.path.isfile(file_path):
            continue

        machine, bits, _ = get_file_machine_bits_libs(file_path, gen_deps=False)
        if machine is None or bits is None:
            continue

        file.set_arg(FileArgs.DISABLE_DEPS.value, True)


main_proprietary_file.add_pre_makefile_generation_fn(apply_elf_no_deps)

if __name__ == '__main__':
    utils = ExtractUtils.device(module)
    utils.run()
