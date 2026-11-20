# Cudy TR3600 v1 — 双系统 OpenWrt 编译（含深澜 srun 认证）

为酷迪 Cudy TR3600 v1 编译带 **A/B 双系统（dual-image）** 支持的 OpenWrt 25.12 固件，
并预装 **深澜（SRun）校园网网页认证** 插件。

## 组成

| 目录 | 内容 |
|------|------|
| `patches/openwrt/0001-…support.patch` | TR3600 v1 设备支持（DTS、镜像定义、网络配置） |
| `patches/openwrt/0002-…uboot-env.patch` | u-boot 环境变量（fw_setenv 支持，双系统切换必需） |
| `patches/openwrt/0004-…dualboot-upgrade.patch` | 双系统升级逻辑（写入备用槽位并切换） |
| `patches/kernel/999-ubi-add-configurable-rootdev.patch` | Cudy 官方内核补丁（boot_param + 可配置 rootfs 卷） |
| `feeds/srun/` | srun CLI（zu1k/srun 预编译 aarch64 二进制） |
| `files/` | 根文件系统覆盖层（`dual-boot-switch` 槽位切换脚本等） |

srun 的 LuCI 界面来自 [xin-521/luci-app-srun](https://github.com/xin-521/luci-app-srun)（编译时作为 feed 拉取）。

## 双系统原理

Flash 布局（与 Cudy 中转固件一致）：

```
UBI 卷:  u-boot-env | kernel | kernel2 | rootfs | rootfs2 | rootfs_data(共享)
```

- u-boot 读 `dual_boot.current_slot` 决定从 kernel/kernel2 哪个槽启动
- 升级时写入 **备用槽**（`upgrade_kernel_part` / `upgrade_rootfs_part`），成功后翻转 slot 标志
- 任一槽启动失败可切回另一槽 —— 不会变砖

## 编译（GitHub Actions）

1. 把本目录推到 GitHub 仓库（保持 `main` 分支）
2. Actions 页面手动触发 **Build TR3600 OpenWrt**（或 push 自动触发）
3. 编译约 1–3 小时，完成后在 run 的 Artifacts 里下载 `tr3600-openwrt-firmware`
4. 产物关键文件：`openwrt-mediatek-filogic-cudy_tr3600-v1-sysupgrade.bin`

## 刷机

> 前提：路由器已刷好官方 **中转固件**（cudy_tr3600-v1-sysupgrade_260715.bin），
> 当前正运行在中转系统上。

1. 电脑连接路由器 LAN 口，浏览器打开中转系统的管理页（通常 `192.168.1.1`）
2. 在 **系统 → 备份/升级**（Sysupgrade）页面上传
   `openwrt-mediatek-filogic-cudy_tr3600-v1-sysupgrade.bin`
3. 保留配置可选（首次建议不保留），确认升级
4. 中转固件的双系统脚本会把 OpenWrt 写入 **另一个槽位** 并切换，重启后进入 OpenWrt
5. 此时：一个槽位是中转固件，另一个槽位是 OpenWrt —— 双系统就绪

**注意**：升级过程中不要断电。

## 双系统切换

SSH 登录 OpenWrt 后：

```sh
dual-boot-switch status   # 查看当前槽位
dual-boot-switch          # 切换到另一槽（即切回中转固件）
dual-boot-switch 1        # 明确切到槽 1
```

也可以手动操作：`fw_setenv dual_boot.current_slot 0 && reboot`

## 深澜（SRun）校园网认证

固件预装 `srun` + `luci-app-srun`。刷好后：

1. LuCI 菜单 **服务 → SRun**
2. 在 **配置** 页添加校园网账号（认证服务器地址、用户名、密码）
3. 开启开机自动登录 / 断线重连
4. **概览/日志** 页可看登录状态

多账号（多拨）、按网卡/IP 绑定等高级用法见插件页面。

## 本地文件说明

工作目录 `Develop_files_for_TR3600/`：

- `readme.txt` — Cudy 官方双系统 UBI 布局说明
- `Intermediate firmware/` — 官方中转固件
- `TR3600v1_dts/` — 官方 DTS（R126）
- `999-ubi-add-configurable-rootdev.patch` — 官方内核补丁
