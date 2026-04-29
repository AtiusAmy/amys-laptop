# Allow build scripts to be referenced without being copied into the final image
# Base Image

FROM ghcr.io/secureblue/silverblue-main-hardened:latest
COPY build_files/build.sh /tmp/build.sh
COPY system_files/silverblue /

## Other possible base images include:
# FROM ghcr.io/ublue-os/bazzite:latest
# FROM ghcr.io/ublue-os/bluefin-nvidia:stable
# 
# ... and so on, here are more base images
# Universal Blue Images: https://github.com/orgs/ublue-os/packages
# Fedora base image: quay.io/fedora/fedora-bootc:41
# CentOS base images: quay.io/centos-bootc/centos-bootc:stream10
# `yq` be used to pass BlueBuild modules configuration written in yaml
COPY --from=docker.io/mikefarah/yq /usr/bin/yq /usr/bin/yq

RUN \
  # add in the module source code
  --mount=type=bind,from=ghcr.io/blue-build/modules:latest,src=/modules,dst=/tmp/modules,rw \
  # add in the script that sets up the module run environment
  --mount=type=bind,from=ghcr.io/blue-build/cli/build-scripts:latest,src=/scripts/,dst=/tmp/scripts/ \
  
# run the module
config=$'\
type: gnome-extensions \n\
install: \n\
    - Caffeine # https://extensions.gnome.org/extension/517/caffeine/ \n\
    - AppIndicator and KStatusNotifierItem Support # https://extensions.gnome.org/extension/615/appindicator-support/ \n\
    - Blur my Shell # https://extensions.gnome.org/extension/3193/blur-my-shell/ \n\
' && \
/tmp/scripts/run_module.sh "$(echo "$config" | yq eval '.type')" "$(echo "$config" | yq eval -o=j -I=0)"

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.

RUN mkdir -p /var/lib/alternatives && \
    /tmp/build.sh && \
    ostree container commit
    
### LINTING
## Verify final image and contents are correct.


