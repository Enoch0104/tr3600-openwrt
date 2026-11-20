include $(TOPDIR)/rules.mk

PKG_NAME:=srun
PKG_VERSION:=0.6.2
PKG_RELEASE:=1

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
  TITLE:=SRun (深澜) campus portal authentication client
  URL:=https://github.com/zu1k/srun
  DEPENDS:=@(aarch64||aarch64_cortex-a53)
endef

define Package/srun/description
  Rust-based CLI client for SRun (深澜) campus network web portal
  authentication. Supports login, logout, multi-account and interface
  binding. This package ships the upstream prebuilt aarch64 musl binary.
endef

# Prebuilt binary - nothing to compile.
define Build/Compile
endef

define Package/srun/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/srun $(1)/usr/bin/srun
endef

$(eval $(call BuildPackage,srun))
