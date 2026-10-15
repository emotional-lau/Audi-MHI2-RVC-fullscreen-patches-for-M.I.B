[简体中文](#zh-cn) | [English](#english)

<a id="zh-cn"></a>

# 更新记录

## v1.2 — 已获实车正常反馈

- 保留全屏视频配置、透明主背景和分隔线。
- 恢复 P0916 原始车辆图、右侧按钮边框及四个雷达 KZB，修正测试车此前右侧雷达不出现的问题。
- 支持识别原始、v1.0/v1.1 和 v1.2 资源以及它们的已知组合，直接升级并按当次状态备份。
- 2026-10-16：车主反馈本版正常。GitHub 整理仅新增文档、验证与打包工具；已验证的安装脚本、清单和资源保持逐字节不变。

- 相关文档提供中英双语；本次文档更新不改变 v1.2 安装内容。

## v1.1 — 测试版本

- 移除目标环境没有的 rmdir 依赖，改用 RAM 锁文件。
- 安装成功，但测试车右侧雷达不显示，按“＋”后仍未出现。新用户应使用 v1.2。

## v1.0 — 初始适配

- 增加 P0916 校验、M.I.B. 自定义安装入口、备份、恢复及失败回退。
- 因目标环境缺少 rmdir 而在写入前停止；后续由 v1.1 修复。

---

<a id="english"></a>

# Changelog

## v1.2 — Normal operation reported on the test vehicle

- Retains the fullscreen video configuration, transparent main background and divider.
- Restores the original P0916 vehicle graphics, right-side button frame and four parking sensor KZB files, resolving the missing right-side parking sensor display reported on the test vehicle.
- Recognizes stock, v1.0/v1.1 and v1.2 resources, including known combinations; supports direct upgrades and backs up the state present before each run.
- 2026-10-16: the owner reported normal operation. GitHub preparation added documentation, verification and packaging tools only; the verified installer, manifest and resources remain byte-identical.
- Documentation is provided in Chinese and English. This documentation update does not change the v1.2 installation payload.

## v1.1 — Test version

- Removes the dependency on `rmdir`, which is unavailable in the target environment, and uses a RAM lock file.
- Installation succeeded, but the test vehicle's right-side parking sensor display was missing, even after pressing “+”. New users should use v1.2.

## v1.0 — Initial adaptation

- Adds P0916 verification, a M.I.B. custom installation entry point, backups, restoration and failure rollback.
- Stopped before writing because the target environment lacked `rmdir`; corrected in v1.1.
