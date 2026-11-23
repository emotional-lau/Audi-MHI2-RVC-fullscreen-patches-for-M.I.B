[简体中文](#zh-cn) | [English](#english)

<a id="zh-cn"></a>

# Audi MHI2 P0916 全屏倒车影像 · M.I.B. 补丁

适用于 **MHI2_CN_AU37x_P0916** 的全屏倒车影像补丁，通过 **M.I.B. 3.7.3** 的 Custom Script 安装，保留原车车辆与雷达相关界面资源。可视雷达显示效果未验证，详见下方测试说明。

**当前版本：v1.2。2026-10-16，测试车主反馈本版显示正常。** 目前只有一台车的实车反馈，不代表所有同版本设备均兼容；脚本还会逐项检查资源哈希。其他固件与 M.I.B. 版本不在本包支持范围内。

基于 [mrfixpl/Audi-MHI2-RVC-fullscreen](https://github.com/mrfixpl/Audi-MHI2-RVC-fullscreen) 的 AU37x 修改方案，加入国行 P0916 资源适配、M.I.B. 安装入口、校验、备份和恢复流程。原项目要求非商业用途，详见 [来源与使用说明](NOTICE.md)。

## 安装前后对比

> **测试说明：测试车辆只有后雷达，没有前雷达，无法测试可视雷达显示效果。以下图片仅展示倒车影像布局及车辆图层的变化，仅供参考，不代表可视雷达功能已验证。**

### 图片 1：原厂效果

![图片 1：原厂倒车影像，左侧为视频，右侧为车辆图层](docs/images/before-stock.jpg)

### 图片 2：安装后效果

![图片 2：安装 v1.2 后的全屏倒车影像，保留右侧车辆图层](docs/images/after-v1.2.jpg)

## 下载与安装

优先下载 Releases 中的 `Audi-MHI2-P0916-RVC-MIB-v1.2.zip`。使用 GitHub 的 Download ZIP 也可以，解压后找到 `SD_ROOT`。

1. 准备已能正常运行的 M.I.B. 3.7.3 SD 卡，安装前保留自己的车机备份。
2. 将 `SD_ROOT` 内的**整个 `mod` 文件夹**合并到 SD 卡根目录，覆盖本补丁的同名文件。若已有其他用途的 `mod/custom.sh`，先另存它。
3. 确认 `mod/rvc_p0916/ACTION.txt` 第一行为 `INSTALL`（发布包默认值）。不能只复制 `custom.sh`。
4. 插卡，打开 `M.I.B. → Advanced Settings → Run Custom Script`，执行 SD 卡上的 `/mod/custom.sh`。
5. 开头应显示 `installer v1.2 radar recovery`。出现 **`INSTALL COMPLETE`** 后再手动重启 MMI；执行期间保持供电，不拔卡或重启。
6. 重启后在车辆停稳状态下检查倒车画面和右侧雷达显示。

SD 卡目录应为：

```text
SD卡根目录/
├── apps/                         # 现有 M.I.B. 文件
├── VERSION                       # 现有 M.I.B. 文件
└── mod/
    ├── custom.sh
    └── rvc_p0916/
        ├── ACTION.txt
        ├── manifest.txt
        ├── originals/
        └── patched/
```

不要把 `SD_ROOT` 本身放到卡根目录后就直接运行。脚本使用 M.I.B. 自带的 `apps/sbin/sha1sum`，本仓库不包含完整 M.I.B.。

## 检查、安装与恢复

编辑 `mod/rvc_p0916/ACTION.txt`，第一行填写下列一个大写动作，再执行同一个菜单：

| 动作 | 行为 |
| --- | --- |
| `CHECK` | 验证环境、包内容与当前资源，不修改车机资源文件。 |
| `INSTALL` | 安装 v1.2；支持从本项目已知的原始资源及 v1.0/v1.1 状态升级，无需先卸载。 |
| `RESTORE` | 将 20 个目标文件恢复为包内 P0916 基准原始资源，包括原来的视频布局。 |

`RESTORE` 不是从最新 `run-N` 自动选择快照。写入异常时，脚本另外会尝试用当次备份回退到操作前状态。

出现 `RESTORE COMPLETE` 后手动重启。`ALREADY INSTALLED` / `ALREADY ORIGINAL` 表示已经处于相应状态，没有重复写入。菜单外层的 `execution finished` 不代表本脚本成功，应查看本脚本的 `COMPLETE`、`ALREADY ...` 或 `ERROR`。

每次实际写入前，会把当时的 20 个资源备份并校验到：

```text
SD卡/backup/RVC_P0916_FULLSCREEN/run-N/
├── before/       # 操作前资源
├── before.txt    # 操作前 SHA-1
└── run.log
```

## v1.2 修改范围

相对于原始 P0916 资源，最终只保留三项修改：

| 文件 | 用途 |
| --- | --- |
| `displaymanager.json` | 视频 source 为 720×480，target 为 800×438。 |
| `2100002.png` | 透明主背景。 |
| `2100003.png` | 修改后的分隔线。 |

`2100137.png`、`2100145.png` 至 `2100156.png` 以及四个 `OPS_AU37*.kzb` 使用该 P0916 基准车机的原始资源，保留车辆、雷达和按钮图层。安装器处理全部 20 个文件，以便修正前版状态并支持恢复。v1.2 不修改 KZB 内部结构，不重新编码图片。

本包只替换显示配置和界面资源，不写入 IFS、EEPROM、FEC、车辆编码或 CarPlay 文件。

## 兼容性与故障处理

- 固件必须是 `MHI2_CN_AU37x_P0916`，M.I.B. 必须为 3.7.3，资源内容还需匹配清单。不要删除版本或哈希保护来适配其他车机。
- `Target differs from all known versions`：存在未知资源差异，脚本会停止。反馈软件版本、错误文本及相关资源哈希；不要直接发布完整备份。
- 缺少 `sha1sum`：检查原有 M.I.B. 的 `apps/sbin/sha1sum` 是否完整。脚本不依赖 `cmp` 或 `rmdir`。
- SD 写入错误：脚本会尝试重新挂载 SD 并实际检查写入；查看报错的具体命令，不能仅凭一条提示断定卡损坏。
- 若显示异常，可执行 `RESTORE` 并重启。菜单无法进入时，不能依靠该菜单恢复。
- 检测到替换错误时尝试恢复当次备份；断电或强制终止无法保证回退。跨 20 个文件的替换不是单一原子事务。

## 验证与维护

[测试记录](docs/VALIDATION.md) 区分了八项离线模拟测试和车主的实车反馈。[更新记录](CHANGELOG.md) 说明各版本区别。

维护者可使用 Python 3.9+，无需第三方依赖：

```bash
python tools/verify.py
python tools/build_release.py
```

生成的安装 ZIP 和 SHA-256 位于 `dist/`。构建不修改安装脚本或资源。SHA-1 用于匹配已有车机文件，SHA-256 用于核验下载；校验值不能代替对发布来源的信任。

本仓库只包含安装所需资源、脚本与文档；不包含整机备份、VIN、密码文件、FEC 或运行日志。反馈问题前请自行遮蔽个人信息。

## 致谢

- [mrfixpl / Audi-MHI2-RVC-fullscreen](https://github.com/mrfixpl/Audi-MHI2-RVC-fullscreen)：原始全屏方案及 AU37x 资源修改。
- [M.I.B. / More Incredible Bash](https://github.com/Mr-MIBonk/M.I.B._More-Incredible-Bash)：Custom Script 执行环境与校验工具。
- [MIB Helper Wiki](https://wiki.mib-helper.com/index.php?title=Audi_MHI2_RVC_fullscreen_patch)：原项目说明。

---

<a id="english"></a>

# Audi MHI2 P0916 Fullscreen Rear-View Camera · M.I.B. Patch

A fullscreen rear-view camera patch for **MHI2_CN_AU37x_P0916**, installed through the Custom Script menu in **M.I.B. 3.7.3**, retaining the stock vehicle and parking sensor interface resources. The visual parking sensor display has not been verified; see the testing note below.

**Current version: v1.2. On 2026-10-16, the test vehicle's owner reported that this version worked normally.** This is feedback from one vehicle, not a compatibility guarantee for every unit running the same firmware. The installer also checks individual resource hashes. Other firmware and M.I.B. versions are outside this package's supported scope.

Based on the AU37x modifications in [mrfixpl/Audi-MHI2-RVC-fullscreen](https://github.com/mrfixpl/Audi-MHI2-RVC-fullscreen), with adaptation for Chinese-market P0916 resources, a M.I.B. installer, verification, backups and restoration. The upstream project specifies non-commercial use; see [Attribution and usage notice](NOTICE.md#english).

## Before and after installation

> **Testing note: The test vehicle has rear parking sensors only, with no front parking sensors. We could not test the visual parking sensor display. The photos below show changes to the camera layout and vehicle graphic only and are provided for reference; they do not establish that the visual parking sensor display works.**

### Image 1: Factory appearance

![Image 1: Factory rear-view camera layout, with video on the left and the vehicle graphic on the right](docs/images/before-stock.jpg)

### Image 2: After installation

![Image 2: Fullscreen rear-view camera after installing v1.2, with the right-side vehicle graphic retained](docs/images/after-v1.2.jpg)

## Download and installation

Prefer `Audi-MHI2-P0916-RVC-MIB-v1.2.zip` from Releases. GitHub's Download ZIP also works: extract it and locate `SD_ROOT`.

1. Prepare an SD card with a working M.I.B. 3.7.3 installation. Keep your own head-unit backup before installing.
2. Merge the **entire `mod` folder** inside `SD_ROOT` into the SD card root, replacing files belonging to this patch. If you already use `mod/custom.sh` for something else, save a separate copy first.
3. Confirm that the first line of `mod/rvc_p0916/ACTION.txt` is `INSTALL`, the release default. Copying only `custom.sh` is insufficient.
4. Insert the card, open `M.I.B. → Advanced Settings → Run Custom Script`, and run `/mod/custom.sh` from the SD card.
5. The opening banner should contain `installer v1.2 radar recovery`. Wait for **`INSTALL COMPLETE`**, then manually restart the MMI. Maintain power throughout execution; do not remove the card or restart early.
6. After restarting, check the camera image and right-side parking sensor display while the vehicle is stationary.

The SD card layout should be:

```text
SD card root/
├── apps/                         # Existing M.I.B. files
├── VERSION                       # Existing M.I.B. file
└── mod/
    ├── custom.sh
    └── rvc_p0916/
        ├── ACTION.txt
        ├── manifest.txt
        ├── originals/
        └── patched/
```

Copy the contents of `SD_ROOT` into the card root, rather than placing the `SD_ROOT` folder itself there. The script uses `apps/sbin/sha1sum` from your existing M.I.B. installation. This repository does not include a complete M.I.B. installation.

## Check, install and restore

Edit the first line of `mod/rvc_p0916/ACTION.txt` to contain one of these uppercase actions, then run the same menu entry:

| Action | Behavior |
| --- | --- |
| `CHECK` | Verifies the environment, package and current resources without modifying head-unit resource files. |
| `INSTALL` | Installs v1.2. Supports upgrades from this project's known stock resources and v1.0/v1.1 states without uninstalling first. |
| `RESTORE` | Restores all 20 target files to the packaged P0916 stock baseline, including the original video layout. |

`RESTORE` uses the packaged stock baseline; it does not automatically select the latest `run-N` snapshot. Separately, if an update fails during file replacement, the script attempts to roll back using that run's backup.

Manually restart after `RESTORE COMPLETE`. `ALREADY INSTALLED` / `ALREADY ORIGINAL` means the requested state is already present, with no repeated writes. The surrounding menu's `execution finished` message does not establish installer success; check this script's own `COMPLETE`, `ALREADY ...` or `ERROR` messages.

Before each actual update, the current 20 resources are backed up and verified at:

```text
SD card/backup/RVC_P0916_FULLSCREEN/run-N/
├── before/       # Resources before this run
├── before.txt    # SHA-1 hashes before this run
└── run.log
```

## Changes in v1.2

Compared with the P0916 stock baseline, only three modifications remain:

| File | Purpose |
| --- | --- |
| `displaymanager.json` | Video source: 720×480; target: 800×438. |
| `2100002.png` | Transparent main background. |
| `2100003.png` | Modified divider. |

`2100137.png`, `2100145.png` through `2100156.png`, and the four `OPS_AU37*.kzb` files use the original resources from the P0916 reference unit, retaining the vehicle, parking sensor and button layers. The installer handles all 20 files to correct earlier versions' states and support restoration. v1.2 does not alter internal KZB structures or re-encode images.

This package replaces display configuration and interface resources only. It does not write IFS, EEPROM, FEC, vehicle coding or CarPlay files.

## Compatibility and troubleshooting

- Firmware must be `MHI2_CN_AU37x_P0916`, M.I.B. must be 3.7.3, and resource contents must match the manifest. Do not remove the version or hash checks to adapt this package to another unit.
- `Target differs from all known versions`: an unknown resource difference was detected, so the script stops. Report the software version, error text and relevant resource hashes; do not publicly upload a full backup.
- Missing `sha1sum`: check that `apps/sbin/sha1sum` is present and intact in your existing M.I.B. installation. This script does not require `cmp` or `rmdir`.
- SD write errors: the script attempts to remount the SD card and checks actual writes. Inspect the failing command; a single message does not establish that the card is damaged.
- For display problems, run `RESTORE` and restart. If the engineering menu is inaccessible, restoration through that menu is unavailable.
- A detected replacement failure triggers an attempt to restore the current run's backup. Rollback cannot be guaranteed after power loss or forced termination. Replacing 20 files is not a single atomic transaction.

## Validation and maintenance

The [validation record](docs/VALIDATION.md#english) distinguishes eight offline simulation tests from the owner's vehicle feedback. The [changelog](CHANGELOG.md#english) describes version differences.

Maintainers can use Python 3.9+ with no third-party dependencies:

```bash
python tools/verify.py
python tools/build_release.py
```

The installation ZIP and its SHA-256 file are generated in `dist/`. Building does not modify the installer or resources. SHA-1 matches existing head-unit files; SHA-256 checks downloads. Checksums do not replace trust in the release source.

This repository contains only the required installation resources, scripts and documentation. It excludes full head-unit backups, VINs, password files, FEC data and runtime logs. Redact personal information before reporting issues.

## Credits

- [mrfixpl / Audi-MHI2-RVC-fullscreen](https://github.com/mrfixpl/Audi-MHI2-RVC-fullscreen): original fullscreen approach and AU37x resource modifications.
- [M.I.B. / More Incredible Bash](https://github.com/Mr-MIBonk/M.I.B._More-Incredible-Bash): Custom Script execution environment and checksum utility.
- [MIB Helper Wiki](https://wiki.mib-helper.com/index.php?title=Audi_MHI2_RVC_fullscreen_patch): upstream project documentation.
