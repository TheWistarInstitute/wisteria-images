# Warewulf Node Image - Rocky Linux 9
#
# Built for import by Warewulf 4.7+ as a node image.
# See: https://warewulf.org/docs/main/images/images.html#podman

FROM ghcr.io/warewulf/warewulf-rockylinux:9

ARG WAREWULF_VERSION=4.7.1
ARG SLURM_VERSION=26.06.4
https://github.com/TheWistarInstitute/wisteria-slurm-builds/releases/download/slurm-26.05.4-rocky9/slurm-slurmd-26.05.4-1.el9.x86_64.rpm

# Install essential packages, remove SELinux, and install Warewulf dracut module
RUN dnf update -y \
    # Install Warewulf dracut module for network boot support
	&& dnf install -y epel-release \
    && dnf install -y \
      https://github.com/warewulf/warewulf/releases/download/v${WAREWULF_VERSION}/warewulf-dracut-${WAREWULF_VERSION}-1.el9.noarch.rpm \
      ignition \
      mdadm \
	  vim neovim \
	  Lmod \
	  autofs \
	  realmd oddjob oddjob-mkhomedir sssd adcli krb5-workstation \
    && dnf clean all 

# install Slurm packages from Wistar's GitHub releases
RUN dnf install -y https://github.com/TheWistarInstitute/wisteria-slurm-builds/releases/download/slurm-26.05.4-rocky9/slurm-26.05.4-1.el9.x86_64.rpm \
		https://github.com/TheWistarInstitute/wisteria-slurm-builds/releases/download/slurm-26.05.4-rocky9/slurm-perlapi-26.05.4-1.el9.x86_64.rpm \
		https://github.com/TheWistarInstitute/wisteria-slurm-builds/releases/download/slurm-26.05.4-rocky9/slurm-slurmd-26.05.4-1.el9.x86_64.rpm

# Generate initramfs with Warewulf support
RUN dracut --force --no-hostonly --add wwinit --add ignition --add mdraid --regenerate-all

# Copy Warewulf-specific configuration files.
COPY ./excludes /etc/warewulf/excludes
COPY ./image_exit.sh /etc/warewulf/image_exit.sh

# Run cleanup script so the published image is not carrying build caches.
RUN sh /etc/warewulf/image_exit.sh

# This image is intended to be imported by Warewulf, not run as a service.
CMD ["/bin/echo", "This image is intended to be used with the Warewulf cluster management system. Import it using: wwctl image import docker://ghcr.io/[your-org]/wisteria-rockylinux:9.8_YYYY.M.0 wisteria-rockylinux-9.8"]
