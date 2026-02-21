# m2391 Recovery Log Issues Summary

Source log: `device/meizu/m2391/recovery.log` (1127 lines)

## 最新回归结论（2026-02-20）

- 关键结论: OTA sideload 已成功完成，主流程打通。
  - `device/meizu/m2391/recovery.log:1069` `Update successfully applied, waiting to reboot.`
  - `device/meizu/m2391/recovery.log:1125` `Install completed with status 0.`
- P0 BootControl 已确认修复生效：
  - `device/meizu/m2391/recovery.log:149` `Using AIDL version of IBootControl`
  - `device/meizu/m2391/recovery.log:151` `Loaded boot control hal.`
- `fstab resize` 告警已消失（新日志未再出现 `unknown flag: resize`）。
- 仍存在但当前非阻塞的告警：
  - `/metadata/ota` 缺失（例如 `:142`, `:212`, `:267`），会导致 snapshot 相关流程降级，但本次 sideload 最终成功。
  - `unable to start transaction in checkpointing` 大量出现（例如 `:391` 等），但未阻塞 payload 写入与校验完成。
  - thermal zone 读取 `Invalid argument` 噪声仍在（例如 `:1077` 起）。

> 注：下方分级条目包含历史失败日志证据；优先以“最新回归结论”判断当前状态。

## 修复进展（2026-02-20）

- 已修复: P0 `BootControl` 缺失问题，设备树已补齐 recovery 侧 AIDL boot HAL 包：
  - `android.hardware.boot-service.qti`
  - `android.hardware.boot-service.qti.recovery`
- 已修复: P2 `fstab resize` 兼容性问题，已从 recovery `/data` 条目移除不受支持标志 `resize`。
- P1 `/metadata/ota` 缺失：第一版脚本式 bootstrap 在最新回归日志仍复现告警，已切换为第二版 direct init.rc 方案：
  - 定义统一 trigger：`m2391-recovery-metadata-bootstrap`
  - `post-fs-data` + `sys.usb.config=sideload` + `sys.usb.state=sideload` 三处触发
  - 目录从仅 `/metadata/ota` 扩展到 AOSP metadata 标准子目录（`vold/password_slots/bootstat/ota/apex`）
- 待回归验证:
  - 重新刷入新构建后复测 `adb sideload`，确认不再出现 `Error getting bootctrl v1.0 module.`
  - 在「格式化 data/metadata 后立即 sideload」场景复测 `/metadata/ota` 目录是否持续可用。
  - 使用“非降级”OTA 包复测，避免 `timestamp downgrade` 失败掩盖 `/metadata/ota` 回归结论。

## P0 (必须先解决)

### 1) OTA sideload 安装失败：BootControl HAL/模块不可用
- Evidence:
  - `device/meizu/m2391/recovery.log:581` `Error getting bootctrl v1.0 module.`
  - `device/meizu/m2391/recovery.log:583` `Error initializing the BootControlInterface.`
  - `device/meizu/m2391/recovery.log:584` `Error in /sideload/package.zip (status 1)`
  - `device/meizu/m2391/recovery.log:635` `Installation aborted.`
- Impact:
  - recovery 无法完成 A/B OTA（sideload 直接失败）。
- Suspected direction:
  - recovery 侧缺失/未注册可用的 boot control 接口（AIDL/HIDL 回退后仍失败）。
  - 需要核对 recovery/vendor_boot 中 bootcontrol 相关 HAL、rc、manifest/compat 及对应依赖是否在 recovery 场景可用。

## P1 (高优先级)

### 2) `/metadata/ota` 不存在 + SnapshotManager 锁失败
- Evidence:
  - `device/meizu/m2391/recovery.log:574` `Open failed: /metadata/ota: No such file or directory`
  - `device/meizu/m2391/recovery.log:575` `Subsequent calls to SnapshotManager will fail.`
  - `device/meizu/m2391/recovery.log:655`
  - `device/meizu/m2391/recovery.log:656`
- Impact:
  - Virtual A/B 更新状态管理不可用，可能影响增量 OTA/快照相关流程。
- Notes:
  - 日志里 wipe 流程可继续执行（`:657 /metadata not found; allowing wipe.`），但 OTA 相关路径异常依然存在。

### 3) 初始 `/data` 挂载失败（F2FS superblock 异常）
- Evidence:
  - `device/meizu/m2391/recovery.log:58` `Invalid f2fs superblock on '/dev/block/by-name/userdata'`
  - `device/meizu/m2391/recovery.log:59` `Failed to mount /data`
  - `device/meizu/m2391/recovery.log:65` `emulated failed to mount ... Invalid argument`
- Impact:
  - recovery 初始阶段无法挂载 userdata；若并非预期“待格式化状态”，会影响 sideload/cache/日志写入等行为。
- Notes:
  - 本次日志中后续执行了 data/metadata wipe，挂载异常可能与 wipe 前状态有关；需确认是否可稳定复现。

## P2 (中优先级)

### 4) fstab 标志 `resize` 不被识别
- Evidence:
  - `device/meizu/m2391/recovery.log:4` `Warning: unknown flag: resize`
  - 同类告警贯穿全程（如 `:35`, `:64`, `:432`, `:720` 等）。
- Impact:
  - fstab 条目解析存在兼容性差异，可能导致部分预期挂载行为未生效。

### 5) 热区温度节点读取大量失败
- Evidence:
  - `device/meizu/m2391/recovery.log:521` 至 `:553` 多个 `thermal_zone*/temp: Invalid argument`
  - `device/meizu/m2391/recovery.log:586` 至 `:618` 再次重复
- Impact:
  - recovery 温控监测噪声较大，可能影响温度上报准确性与问题定位。

### 6) 电池信息初始化反复重试
- Evidence:
  - `device/meizu/m2391/recovery.log:48` 开始，直到 `:112` 持续出现 `Trying again for reinitializing battery info`
- Impact:
  - 电池状态读取/初始化链路异常，可能影响 recovery UI 显示与充电状态判断。

## P3 (低优先级/噪声类)

### 7) 只读属性写入失败
- Evidence:
  - `device/meizu/m2391/recovery.log:570` `Unable to set property "ro.boottime...": PROP_ERROR_READ_ONLY_PROPERTY`
  - `device/meizu/m2391/recovery.log:651` 同类
- Impact:
  - 通常不阻塞主流程，属于统计属性写入失败噪声。

### 8) secure discard 不支持，回退普通 discard
- Evidence:
  - `device/meizu/m2391/recovery.log:445` `Wipe via secure discard failed, used discard instead`
  - `device/meizu/m2391/recovery.log:660` 同类
- Impact:
  - 不影响 wipe 成功，但安全擦除能力降级。

### 9) 其他一次性告警（建议观察）
- Evidence:
  - `device/meizu/m2391/recovery.log:520` `unknown fuse request opcode 2016`
  - `device/meizu/m2391/recovery.log:561` `scudo: Can't populate more pages for size class 65552.`
- Impact:
  - 当前日志未显示其直接导致流程失败，先保留观察。

## 已确认正常点（避免误判）
- OTA 包签名校验通过：
  - `device/meizu/m2391/recovery.log:559` 开始验证
  - `device/meizu/m2391/recovery.log:564` 与 `device/meizu/m2391/recovery.log:565`（完整签名校验通过，result 0）
- 失败发生在签名校验之后、进入安装阶段时（BootControl 初始化阶段）。

## 建议修复顺序
1. `/metadata/ota` 与 SnapshotManager 锁失败（当前主要遗留项，非阻塞）
2. checkpointing 事务告警归因（确认是否可通过 metadata 目录结构初始化消除）
3. thermal/battery 噪声治理（可后置）
