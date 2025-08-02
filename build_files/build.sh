#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

dnf5 -y copr enable ublue-os/staging fedora-42-x86_64
dnf5 -y copr enable ublue-os/packages fedora-42-x86_64
dnf5 -y copr enable antiderivative/libfprint-tod-goodix-0.0.9 fedora-42-x86_64


dnf5 swap -y \
    --repo=copr:copr.fedorainfracloud.org:antiderivative:libfprint-tod-goodix-0.0.9 \
    libfprint libfprint-tod
# this installs a package from fedora repos
dnf5 install -y adw-gtk3-theme gnome-shell-extension-appindicator gnome-shell-extension-logo-menu gnome-shell-extension-caffeine gnome-shell-extension-blur-my-shell tailscale gparted micro gnome-shell-extension-background-logo bluefin-schemas libfprint-tod-goodix bazaar
dnf -y remove gnome-extensions-app gnome-software-rpm-ostree malcontent-control gnome-software

# Adds the main kernel repo
dnf5 copr enable -y kwizart/kernel-longterm-6.12 fedora-42-x86_64

# Remove useless kernels
readarray -t OLD_KERNELS < <(rpm -qa 'kernel-*')
if (( ${#OLD_KERNELS[@]} )); then
    rpm -e --justdb --nodeps "${OLD_KERNELS[@]}"
    dnf5 versionlock delete "${OLD_KERNELS[@]}" || true
    rm -rf /usr/lib/modules/*
    rm -rf /lib/modules/*
fi

# Install LTS kernel
dnf5 install -y \
    --enablerepo="copr:copr.fedorainfracloud.org:kwizart:kernel-longterm-6.12" \
    --allowerasing \
    kernel-longterm \
    kernel-longterm-headers \

# Get full kernel version with arch (including the arch)
KERNEL_VERSION="$(rpm -q --qf '%{VERSION}-%{RELEASE}.%{ARCH}\n' kernel-longterm)"

# Copy vmlinuz
VMLINUZ_SOURCE="/usr/lib/kernel/vmlinuz-${KERNEL_VERSION}"
VMLINUZ_TARGET="/usr/lib/modules/${KERNEL_VERSION}/vmlinuz"
if [[ -f "${VMLINUZ_SOURCE}" ]]; then
    cp "${VMLINUZ_SOURCE}" "${VMLINUZ_TARGET}"
fi

# Lock kernel packages
dnf5 versionlock add "kernel-longterm-${KERNEL_VERSION}" || true
dnf5 versionlock add "kernel-longterm-module-${KERNEL_VERSION}" || true
dnf5 versionlock add "kernel-longterm-core-${KERNEL_VERSION}" || true


# Thank you @renner for this part
# Build initramfs (without --add-drivers I get an error telling me subvols= does not exists)
export DRACUT_NO_XATTR=1
dracut --force \
  --no-hostonly \
  --kver "${KERNEL_VERSION}" \
  --add-drivers "btrfs nvme xfs ext4" \
  --reproducible -v --add ostree \
  -f "/usr/lib/modules/${KERNEL_VERSION}/initramfs.img"

chmod 0600 "/lib/modules/${KERNEL_VERSION}/initramfs.img"
# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/tailscale.repo
dnf5 -y copr disable antiderivative/libfprint-tod-goodix-0.0.9
dnf5 -y copr disable ublue-os/staging
dnf5 -y copr disable ublue-os/packages
dnf5 -y copr disable kwizart/kernel-longterm-6.12

#### Example for enabling a System Unit File
echo "import \"/usr/share/ublue-os/just/amy.just\"" >> /usr/share/ublue-os/justfile
