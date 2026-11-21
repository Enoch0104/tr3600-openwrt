include $(TOPDIR)/rules.mk

PKG_NAME:=srun
PKG_VERSION:=0.6.2
PKG_RELEASE:=2

PKG_SOURCE:=srun-$(PKG_VERSION)-aarch64-unknown-linux-musl.tar.xz
PKG_SOURCE_URL:=https://github.com/zu1k/srun/releases/download/$(PKG_VERSION)/
PKG_HASH:=25c2e3645f6fb508d186812790165f7ed3f9d17fc2fef5257c9417957ed4c526

PKG_LICENSE:=GPL-3.0-or-later
PKG_MAINTAINER:=zu1k <i@zu1k.com>

PKG_FLAGS:=nonshared

include $(INCLUDE_DIR)/package.mk

define Package/srun
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Captive Portal
  TITLE:=SRun (ShenLan) campus portal authentication client
  URL:=https://github.com/zu1k/srun
  DEPENDS:=@(aarch64||aarch64_cortex-a53)
endef

define Package/srun/description
  Rust-based CLI client for SRun (ShenLan) campus network web portal
  authentication. Supports login, logout, multi-account and interface
  binding. This package ships the upstream prebuilt aarch64 musl binary.
endef

# The release tarball has the binary at archive root (no top-level
# directory), so the default unpack (tar --strip-components=1) would
# throw the single-component path away. Extract without stripping and
# normalise the result to $(PKG_BUILD_DIR)/srun.
define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	tar -C $(PKG_BUILD_DIR) -xf $(DL_DIR)/$(PKG_SOURCE)
	[ -f $(PKG_BUILD_DIR)/srun ] || \
		find $(PKG_BUILD_DIR) -maxdepth 2 -type f -name srun -exec mv {} $(PKG_BUILD_DIR)/srun \;
endef

# Prebuilt binary - nothing to compile.
define Build/Compile
endef

define Package/srun/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/srun $(1)/usr/bin/srun
endef

$(eval $(call BuildPackage,srun))
