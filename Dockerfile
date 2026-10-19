# Warewulf Node Image - Rocky Linux 9
#
# Built for import by Warewulf 4.7+ as a node image.
# See: https://warewulf.org/docs/main/images/images.html#podman

FROM ghcr.io/warewulf/warewulf-rockylinux:9

ARG WAREWULF_VERSION=4.7.1

# Install updates, the Warewulf dracut module for network boot support,
# and site-required boot/runtime tooling.
RUN dnf update -y
RUN dnf install epel-release -y
RUN dnf install -y \
		vim neovim \
		Lmod \
		autofs \
        realmd oddjob oddjob-mkhomedir sssd adcli krb5-workstation
RUN dnf install -y https://github.com/warewulf/warewulf/releases/download/v${WAREWULF_VERSION}/warewulf-dracut-${WAREWULF_VERSION}-1.el9.noarch.rpm -o warewulf-dracut-${WAREWULF_VERSION}-1.el9.noarch.rpm
RUN dracut --force --no-hostonly --add wwinit --add ignition --add mdraid --regenerate-all
RUN dnf clean all

# Copy Warewulf-specific configuration files.
COPY ./images/excludes /etc/warewulf/excludes
COPY ./images/image_exit.sh /etc/warewulf/image_exit.sh

# Run cleanup script so the published image is not carrying build caches.
RUN sh /etc/warewulf/image_exit.sh

# This image is intended to be imported by Warewulf, not run as a service.
CMD ["/bin/echo", "This image is intended to be used with the Warewulf cluster management system. Import it using: wwctl image import docker://ghcr.io/[your-org]/wisteria-rockylinux:9.8_YYYY.M.0 wisteria-rockylinux-9.8"]
