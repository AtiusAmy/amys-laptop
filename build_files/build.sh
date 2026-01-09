#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

CHROOT="fedora-43-x86_64"

dnf5 -y copr enable ublue-os/staging ${CHROOT}
dnf5 -y copr enable ublue-os/packages ${CHROOT}
dnf5 -y copr enable antiderivative/libfprint-tod-goodix-0.0.9 ${CHROOT}


dnf5 swap -y \
    --repo=copr:copr.fedorainfracloud.org:antiderivative:libfprint-tod-goodix-0.0.9 \
    libfprint libfprint-tod
# this installs a package from fedora repos
dnf5 install -y adw-gtk3-theme tailscale gparted gnome-shell-extension-background-logo bluefin-schemas bazaar libfprint-tod-goodix
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

chmod +x /usr/share/gnome-shell/extensions/Battery-Health-Charging@maniacx.github.com/tool/installer.sh


#### Example for enabling a System Unit File
echo "import \"/usr/share/ublue-os/just/amy.just\"" >> /usr/share/ublue-os/justfile

echo "::group:: ===$(basename "$0")==="

dnf5 -y install glib2-devel meson sassc cmake dbus-devel git

git clone https://github.com/ublue-os/Logomenu /usr/share/gnome-shell/extensions/logomenu@aryan_k

# Logo Menu
# xdg-terminal-exec is required for this extension as it opens up terminals using that script
install -Dpm0755 -t /usr/bin /usr/share/gnome-shell/extensions/logomenu@aryan_k/distroshelf-helper
install -Dpm0755 -t /usr/bin /usr/share/gnome-shell/extensions/logomenu@aryan_k/missioncenter-helper
glib-compile-schemas --strict /usr/share/gnome-shell/extensions/logomenu@aryan_k/schemas

dnf5 -y remove glib2-devel meson sassc cmake dbus-devel perl-Digest

echo "::endgroup::"
