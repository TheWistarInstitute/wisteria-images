# Wisteria Warewulf Rocky Linux node image

Template repository for building and publishing a Warewulf-compatible Rocky Linux 9 node image to GitHub Container Registry (GHCR).

The image name is:

```text
ghcr.io/<owner>/wisteria-rockylinux:<rocky_version>_<year>.<month>.0
```

Example for Rocky Linux 9.8 built on the first day of August 2026:

```text
ghcr.io/<owner>/wisteria-rockylinux:9.8_2026.8.0
```

## What it builds

The `Dockerfile` starts from Warewulf's Rocky Linux base image:

```Dockerfile
FROM ghcr.io/warewulf/warewulf-rockylinux:9
```

It then installs:

- the Warewulf dracut module RPM for `WAREWULF_VERSION`;
- `ignition`;
- `mdadm`;
- regenerated initramfs images with `wwinit`, `ignition`, and `mdraid` support.

This follows the Warewulf OCI/Podman image-definition model documented at:

<https://warewulf.org/docs/main/images/images.html#podman>

## Build triggers

`.github/workflows/build-container.yml` publishes to GHCR when:

- code is pushed to `main`;
- the scheduled workflow runs on the first day of each month;
- the workflow is run manually with `workflow_dispatch`.

> GitHub cron schedules are UTC. This template uses `0 4 1 * *`, which is midnight Eastern during daylight saving time. Adjust to `0 5 1 * *` if you want midnight Eastern during standard time. GitHub Actions cannot express a DST-aware timezone directly. Because of course it can't; that would be too kind.

## Required GitHub repository setting

The workflow uses the built-in `${{ secrets.GITHUB_TOKEN }}` with:

```yaml
permissions:
  contents: read
  packages: write
```

No personal access token is required for normal GHCR publishing from the same repository.

After the first successful push, check the package visibility under the repository/org packages settings. GHCR packages often start private unless your org policy says otherwise.

## Manual build example

From the GitHub Actions UI, run **Build Warewulf node image** with:

| Input | Value |
|---|---|
| `rocky_version` | `9.8` |
| `tag_date` | `2026.8.0` |
| `warewulf_version` | `4.7.0` |

That publishes:

```text
ghcr.io/<owner>/wisteria-rockylinux:9.8_2026.8.0
```

## Import into Warewulf 4.7

On the Wisteria provisioning server:

```bash
wwctl image import docker://ghcr.io/<owner>/wisteria-rockylinux:9.8_2026.8.0 wisteria-rockylinux-9.8
wwctl image list
```

If the GHCR package is private, authenticate from the provisioning server first. Use a read-only token with package-read scope if your org requires it.

## Local build test

If you want to test before pushing:

```bash
docker build \
  --build-arg WAREWULF_VERSION=4.7.0 \
  -t wisteria-rockylinux:9.8_2026.8.0 .
```

Or with Podman:

```bash
podman build \
  --build-arg WAREWULF_VERSION=4.7.0 \
  -t wisteria-rockylinux:9.8_2026.8.0 .
```

## Files

| Path | Purpose |
|---|---|
| `Dockerfile` | Defines the Warewulf Rocky Linux node image. |
| `excludes` | Warewulf image excludes copied to `/etc/warewulf/excludes`. |
| `image_exit.sh` | Cleanup hook copied to `/etc/warewulf/image_exit.sh`. |
| `.github/workflows/build-container.yml` | GitHub Actions workflow that builds and publishes to GHCR. |
