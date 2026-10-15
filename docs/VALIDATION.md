[简体中文](#zh-cn) | [English](#english)

<a id="zh-cn"></a>

# 验证记录

## 实车反馈

2026-10-16，使用 MHI2_CN_AU37x_P0916 与 M.I.B. 3.7.3 的测试车主，在此前报告右侧雷达消失、按“＋”无效后，安装 v1.2 并反馈：“这一版非常正常”。

据此记录为本台车的显示问题已解决。未获得其他车型、其他固件或长期耐久测试结果，也未单独验证全部传感器、报警声和所有车辆工况。未把此前异常照片当作成功效果图发布。

## 历史离线模拟测试：8 项通过

使用 Windows BusyBox sh，把目标路径重定向到临时目录；模拟 mount/sync，实际执行文件复制、重命名和哈希。未向真实 SD 卡或车机写入模拟数据。

| 场景 | 结果 |
| --- | --- |
| 资源范围：17 个原始文件，3 个全屏修改 | PASS |
| 从 v1.1 执行 CHECK | PASS |
| 从 v1.1 升级并精确备份操作前状态 | PASS |
| 重复 INSTALL 不重复写入 | PASS |
| RESTORE 恢复全部 20 个原始文件 | PASS |
| 从原始状态安装 | PASS |
| 模拟升级中途失败，回退到完整的 v1.1 操作前状态 | PASS |
| 未知资源拒绝写入 | PASS |

这些是打包前的已有测试记录，模拟环境不能证明 QNX 的实际权限语义、断电恢复能力或全部界面行为。完整模拟工具依赖开发时的旧版本夹具，未作为本仓库的可移植测试套件发布。

## 本次发布整理

已将 SD_ROOT 全部 43 个文件与车主实测的 v1.2 安装包逐字节比较，内容一致。新增的 tools/verify.py 可独立检查清单、包内哈希、20 个资源集合、17/3 的修改范围、脚本内嵌清单校验与文件换行。

发布使用白名单整理，仅包含安装所需显示资源、脚本及说明；未复制完整备份、密码文件、车辆编码、VIN 文件或运行日志。发布文件另扫描了已知车辆 VIN（若从本地版本记录取得）及本地用户路径。资源本身作为基准保留用于哈希匹配与恢复，未删改二进制内容。

中英双语文档更新保持安装内容不变。源码包和安装包会重新构建，因此整个压缩包的 SHA-256 会变化；安装内容的校验值保持不变。

---

<a id="english"></a>

# Validation record

## Vehicle feedback

On 2026-10-16, the test vehicle's owner, using MHI2_CN_AU37x_P0916 and M.I.B. 3.7.3, installed v1.2 after previously reporting that the right-side parking sensor display was missing and pressing “+” had no effect. The owner then reported: “这一版非常正常” (“This version works perfectly normally”).

This is recorded as resolution of the display issue on that vehicle. There are no results for other models, firmware versions or long-term endurance testing. All sensors, audible warnings and operating conditions have not been independently verified. The earlier photo showing the problem has not been published as a successful-result image.

## Prior offline simulations: eight tests passed

Tests used Windows BusyBox sh with target paths redirected to temporary directories. `mount` and `sync` were simulated, while file copying, renaming and hashing were executed. Simulation data was not written to an actual SD card or vehicle.

| Scenario | Result |
| --- | --- |
| Resource scope: 17 stock files and 3 fullscreen modifications | PASS |
| CHECK from v1.1 | PASS |
| Upgrade from v1.1 with an exact backup of the pre-run state | PASS |
| Repeated INSTALL without repeated writes | PASS |
| RESTORE of all 20 stock files | PASS |
| Installation from stock | PASS |
| Simulated mid-upgrade failure, rolling back to the complete pre-run v1.1 state | PASS |
| Refusal to write unknown resources | PASS |

These are existing test records from before packaging. Simulation does not establish actual QNX permission semantics, power-loss recovery or all interface behavior. The full simulation tooling depends on development fixtures from previous versions and is not distributed as a portable test suite in this repository.

## Release preparation

All 43 files in `SD_ROOT` were compared byte for byte with the v1.2 installation archive tested by the owner and are identical. The added `tools/verify.py` independently checks the manifest, payload hashes, set of 20 resources, 17/3 modification scope, embedded manifest checksum and relevant line-ending requirements.

Release contents were selected using an allowlist, including only the required display resources, scripts and documentation. Full backups, password files, vehicle coding, VIN files and runtime logs were not copied. Release files were also scanned for known vehicle VINs, where available from local version records, and local user paths. Binary resources are retained unchanged as the baseline for hash matching and restoration.

The bilingual documentation update leaves the installation payload unchanged. Source and installation archives are rebuilt, so their archive-level SHA-256 values change; the payload checksums remain unchanged.
