#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y gnome-shell-extension-appindicator gnome-shell-extension-caffeine tailscale android-tools gparted micro
dnf5 -y copr enable antiderivative/libfprint-tod-goodix-0.0.9
dnf5 remove -y libfprint 
dnf5 -y swap \
    --repo copr:copr.fedorainfracloud.org:antiderivative:libfprint-tod-goodix-0.0.9 \
    libfprint-tod libfprint-tod
dnf5 versionlock add libfprint-tod
dnf5 install -y libfprint-tod-goodix
dnf5 install -y libfprint

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging
dnf5 -y copr disable antiderivative/libfprint-tod-goodix-0.0.9

#### Example for enabling a System Unit File
systemctl enable fprintd
