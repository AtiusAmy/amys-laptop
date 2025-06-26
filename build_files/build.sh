#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

dnf5 -y copr enable ublue-os/staging
dnf5 -y copr enable ublue-os/packages
dnf5 -y copr enable antiderivative/libfprint-tod-goodix-0.0.9


dnf5 swap -y \
    --repo=copr:copr.fedorainfracloud.org:antiderivative:libfprint-tod-goodix-0.0.9 \
    libfprint libfprint-tod
# this installs a package from fedora repos
dnf5 install -y adw-gtk3-theme gnome-shell-extension-appindicator gnome-shell-extension-logo-menu gnome-shell-extension-caffeine gnome-shell-extension-blur-my-shell rclone tailscale android-tools gparted micro gnome-shell-extension-background-logo bluefin-schemas libfprint-tod-goodix bazaar
dnf5 -y copr enable antiderivative/libfprint-tod-goodix-0.0.9
dnf -y remove gnome-extensions-app gnome-software-rpm-ostree malcontent-control gnome-software

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

#### Example for enabling a System Unit File
echo "import \"/usr/share/ublue-os/just/amy.just\"" >> /usr/share/ublue-os/justfile
