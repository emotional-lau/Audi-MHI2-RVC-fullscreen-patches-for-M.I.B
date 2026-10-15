[简体中文](#zh-cn) | [English](#english)

<a id="zh-cn"></a>

# v1.2 · P0916 全屏倒车影像，保留雷达显示

适用：MHI2_CN_AU37x_P0916 + M.I.B. 3.7.3，且资源哈希匹配。

- 保留全屏视频配置，恢复原车车辆与雷达资源。
- 2026-10-16 已有一台测试车反馈本版正常。
- 支持直接从已知原始状态或本项目 v1.0/v1.1 升级，以及 CHECK / INSTALL / RESTORE。
- 写入前备份并校验 20 个资源，检测到替换失败时尝试回退。
- 本次发布整理没有改变实车验证过的脚本或资源。
- 包含中英双语说明文档。

下载 `Audi-MHI2-P0916-RVC-MIB-v1.2.zip`，解压后将 `SD_ROOT/mod` 整体合并到现有 M.I.B. SD 卡根目录，不能只复制 sh 文件。按 README 从 Custom Script 执行；看到 INSTALL COMPLETE 后手动重启。

同名 `.sha256.txt` 可核对下载完整性。其他固件未验证，不要绕过哈希或版本检查。请保留自己的备份，执行过程中保持供电。

感谢 mrfixpl 的原始方案和 M.I.B. 项目。遵循上游非商业用途说明，详见 NOTICE.md。

---

<a id="english"></a>

# v1.2 · P0916 fullscreen rear-view camera with parking sensor display retained

Compatible environment: MHI2_CN_AU37x_P0916 + M.I.B. 3.7.3, with matching resource hashes.

- Retains the fullscreen video configuration and restores stock vehicle and parking sensor resources.
- Normal operation was reported on one test vehicle on 2026-10-16.
- Supports direct upgrades from known stock states or this project's v1.0/v1.1, with CHECK / INSTALL / RESTORE actions.
- Backs up and verifies 20 resources before writing, and attempts rollback if file replacement fails.
- Release preparation does not change the installer or resources verified on the vehicle.
- Includes Chinese and English documentation.

Download `Audi-MHI2-P0916-RVC-MIB-v1.2.zip`, extract it, and merge the entire `SD_ROOT/mod` folder into the root of an existing M.I.B. SD card. Do not copy only the shell script. Follow the README to run it through Custom Script; manually restart after `INSTALL COMPLETE`.

The corresponding `.sha256.txt` checks download integrity. Other firmware versions have not been verified; do not bypass hash or version checks. Keep your own backup and maintain power throughout execution.

Thanks to mrfixpl for the original approach and to the M.I.B. project. Follow the upstream non-commercial-use notice; see NOTICE.md.
