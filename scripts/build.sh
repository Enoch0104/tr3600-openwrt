#!/bin/bash
# Cudy TR3600 v1 dual-boot OpenWrt build script (runs in GitHub Actions).
# Produces: openwrt/bin/targets/mediatek/filogic/openwrt-mediatek-filogic-cudy_tr3600-v1-sysupgrade.bin
set -euo pipefail

OPENWRT_REPO="${OPENWRT_REPO:-https://github.com/openwrt/openwrt.git}"
OPENWRT_BRANCH="${OPENWRT_BRANCH:-openwrt-25.12}"
OPENWRT_DIR="${OPENWRT_DIR:-$PWD/openwrt}"
SRC_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "==> Workspace : $SRC_DIR"
echo "==> OpenWrt   : $OPENWRT_REPO @ $OPENWRT_BRANCH -> $OPENWRT_DIR"

# ---------------------------------------------------------------- 1. source
if [ ! -d "$OPENWRT_DIR/.git" ]; then
	echo "==> Cloning OpenWrt ($OPENWRT_BRANCH, depth=1)"
	git clone --depth=1 -b "$OPENWRT_BRANCH" "$OPENWRT_REPO" "$OPENWRT_DIR"
fi
cd "$OPENWRT_DIR"

# --------------------------------------------------------------- 2. patches
echo "==> Applying OpenWrt-tree patches"
for p in "$SRC_DIR"/patches/openwrt/*.patch; do
	echo "    - $(basename "$p")"
	patch -p1 --forward < "$p"
done

echo "==> Installing kernel patches"
mkdir -p target/linux/mediatek/patches-6.12
cp -v "$SRC_DIR"/patches/kernel/*.patch target/linux/mediatek/patches-6.12/

# --------------------------------------------------------------- 3. feeds
echo "==> Configuring feeds"
cat >> feeds.conf.default <<EOF
src-git srunui https://github.com/xin-521/luci-app-srun.git
src-link localextra $SRC_DIR/feeds
EOF
./scripts/feeds update -a
./scripts/feeds install -a

# --------------------------------------------------------------- 4. config
echo "==> Writing build config"
cat > .config <<'EOF'
CONFIG_TARGET_mediatek=y
CONFIG_TARGET_mediatek_filogic=y
CONFIG_TARGET_mediatek_filogic_DEVICE_cudy_tr3600-v1=y
CONFIG_PACKAGE_luci=y
CONFIG_PACKAGE_luci-ssl=y
CONFIG_PACKAGE_luci-app-srun=y
CONFIG_PACKAGE_srun=y
CONFIG_PACKAGE_luci-i18n-base-zh-cn=y
EOF
make defconfig

echo "==> Selected device / packages:"
grep -E "^CONFIG_TARGET_mediatek_filogic_DEVICE_cudy|^CONFIG_PACKAGE_(luci-app-srun|srun)=" .config || true

# --------------------------------------------------------------- 5. rootfs overlay
if [ -d "$SRC_DIR/files" ]; then
	echo "==> Installing rootfs overlay (files/)"
	mkdir -p files
	cp -a "$SRC_DIR"/files/. files/
fi

# --------------------------------------------------------------- 6. build
echo "==> Building firmware (this takes 1-3 hours)"
make -j"$(nproc)" || make -j1 V=s

# --------------------------------------------------------------- 7. collect
OUT="$SRC_DIR/out"
mkdir -p "$OUT"
cp -v bin/targets/mediatek/filogic/openwrt-mediatek-filogic-cudy_tr3600-v1-sysupgrade.bin "$OUT/" 2>/dev/null || \
	cp -v bin/targets/mediatek/filogic/*sysupgrade*.bin "$OUT/"
cp -v bin/targets/mediatek/filogic/*rootfs*.bin "$OUT/" 2>/dev/null || true
cp -v bin/targets/mediatek/filogic/sha256sums "$OUT/" 2>/dev/null || true
ls -lh "$OUT"
echo "==> Done."
