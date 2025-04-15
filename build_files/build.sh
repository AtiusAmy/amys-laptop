#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

dnf5 -y install --nogpgcheck --repofrompath 'terra,https://repos.fyralabs.com/terra$releasever' terra-release
dnf5 -y install terra-release-extras || true
dnf5 config-manager setopt "terra*".enabled=0


# this installs a package from fedora repos
dnf5 install -y gnome-shell-extension-appindicator gnome-shell-extension-caffeine gnome-shell-extension-tailscale-gnome-qs gnome-shell-extension-blur-my-shell gnome-shell-extension-logo-menu rclone tailscale android-tools gparted micro
dnf5 -y copr enable antiderivative/libfprint-tod-goodix-0.0.9
curl -o /etc/yum.repos.d/_copr:copr.fedorainfracloud.org:antiderivative:libfprint-tod-goodix-0.0.9.repo "https://copr.fedorainfracloud.org/coprs/antiderivative/libfprint-tod-goodix-0.0.9/repo/fedora-$(rpm -E %fedora)/antiderivative-libfprint-tod-goodix-0.0.9-fedora-$(rpm -E %fedora).repo"
rpm-ostree override replace --experimental --from repo=copr:copr.fedorainfracloud.org:antiderivative:libfprint-tod-goodix-0.0.9 --remove=libfprint libfprint-tod libfprint-tod-goodix

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging
sed -i 's@enabled=1@enabled=0@g' /etc/yum.repos.d/tailscale.repo
dnf5 -y copr disable antiderivative/libfprint-tod-goodix-0.0.9

#### Example for enabling a System Unit File
