# Warewulf Node Image - Rocky Linux 9
#
# Built for import by Warewulf 4.7+ as a node image.
# See: https://warewulf.org/docs/main/images/images.html#podman

FROM ghcr.io/warewulf/warewulf-rockylinux:9

ARG WAREWULF_VERSION=4.7.0

# Install updates, the Warewulf dracut module for network boot support,
# and site-required boot/runtime tooling.
RUN dnf update -y \
    && dnf install -y \
      "https://github.com/warewulf/warewulf/releases/download/v${WAREWULF_VERSION}/warewulf-dracut-${WAREWULF_VERSION}-1.el9.noarch.rpm" \
      vim \
    && dnf clean all

# Generate initramfs with Warewulf support.
RUN dracut --force --no-hostonly --add wwinit --add ignition --add mdraid --regenerate-all

# Copy Warewulf-specific configuration files.
COPY excludes /etc/warewulf/excludes
COPY image_exit.sh /etc/warewulf/image_exit.sh

# Run cleanup script so the published image is not carrying build caches.
RUN sh /etc/warewulf/image_exit.sh

# This image is intended to be imported by Warewulf, not run as a service.
CMD ["/bin/echo", "This image is intended to be used with the Warewulf cluster management system. Import it using: wwctl image import docker://ghcr.io/[your-org]/wisteria-rockylinux:9.8_YYYY.M.0 wisteria-rockylinux-9.8"]
