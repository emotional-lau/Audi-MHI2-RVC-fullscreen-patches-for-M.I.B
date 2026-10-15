[简体中文](#zh-cn) | [English](#english)

<a id="zh-cn"></a>

# 来源与使用说明

原项目：[mrfixpl/Audi-MHI2-RVC-fullscreen](https://github.com/mrfixpl/Audi-MHI2-RVC-fullscreen)。原作者为 mrfixpl。上游 README 标注非商业用途（原文拼写保留）：

> Not for commecrial use - if you bought this, you got ripped off!

请保留原作者署名、项目链接和非商业用途说明。本仓库未给第三方资源另行授予 MIT、Apache 或其他通用开源许可。公开可下载及本说明均不代表对所有第三方文件作出了额外授权。

## 内容来源

- 全屏显示配置及两张改动纹理来自上游 AU37x 修改方案。
- 包内 originals 为测试车机导出的 P0916 显示资源基准；其显示配置与此前该车机备份中的配置一致。此处不是完整车机备份。
- 其余 17 个目标资源与上述基准逐字节相同。
- 安装脚本为本适配项目编写；未打包 M.I.B. 可执行程序、IFS 固件、EEPROM、FEC 或账户数据。

最初取得的是官方 GitHub main 分支下载包。整体下载未完成，但使用的 AU37x 条目均单独通过解压长度与 ZIP CRC32 检验，未使用截断条目。未取得该次下载的固定提交号，不能将它追溯为某个确定的上游 commit。

`docs/asset-analysis.json` 记录原始、前版及 v1.2 目标的 SHA-1；`PAYLOAD_SHA256SUMS.txt` 记录本版 SD_ROOT 全部文件的 SHA-256。它们可复核本次发布内容，但不补足缺失的上游提交溯源。

安装器依赖 [M.I.B.](https://github.com/Mr-MIBonk/M.I.B._More-Incredible-Bash) 现有安装中的校验工具和脚本入口，相关权利归各自权利人所有。

---

<a id="english"></a>

# Attribution and usage notice

Upstream project: [mrfixpl/Audi-MHI2-RVC-fullscreen](https://github.com/mrfixpl/Audi-MHI2-RVC-fullscreen), by mrfixpl. Its README specifies non-commercial use (original spelling retained):

> Not for commecrial use - if you bought this, you got ripped off!

Retain the original author's attribution, project link and non-commercial-use notice. This repository does not relicense third-party resources under MIT, Apache or another general open-source license. Public availability and this notice do not grant additional permissions for all third-party files.

## Content provenance

- The fullscreen display configuration and two modified textures come from the upstream AU37x modification approach.
- The packaged `originals` are a P0916 display-resource baseline exported from the test unit. Its display configuration matches the configuration in an earlier backup of that unit. This is not a full head-unit backup.
- The remaining 17 target resources are byte-identical to that baseline.
- The installer was written for this adaptation. M.I.B. executables, IFS firmware, EEPROM, FEC and account data are not included.

The initial source download was the official GitHub main-branch archive. The overall download did not complete, but every AU37x entry used was independently checked against its uncompressed size and ZIP CRC32. No truncated entry was used. An immutable commit ID was not obtained for that download, so it cannot be attributed to a specific upstream commit.

`docs/asset-analysis.json` records SHA-1 hashes for the original, previous-version and v1.2 target resources. `PAYLOAD_SHA256SUMS.txt` records SHA-256 hashes for every file in this release's `SD_ROOT`. These inventories allow verification of the release contents but do not recover the missing upstream commit provenance.

The installer relies on the checksum utility and script entry point in an existing [M.I.B.](https://github.com/Mr-MIBonk/M.I.B._More-Incredible-Bash) installation. Rights remain with their respective holders.
