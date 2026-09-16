# Wisteria Warewulf Rocky Linux node image


```text
ghcr.io/thewistarinstitute/wisteria-rockylinux:<rocky_version>_<year>.<month>.0
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

This follows the [Warewulf OCI/Podman image-definition model documentation](https://warewulf.org/docs/main/images/images.html#podman)

## Build triggers

`.github/workflows/build-container.yml` publishes to GHCR when:

- code is pushed to `main`;
- the scheduled workflow runs on the first day of each month;
- the workflow is run manually with `workflow_dispatch`.

> GitHub cron schedules are UTC. This template uses `0 4 1 * *`, which is midnight Eastern during daylight saving time. Adjust to `0 5 1 * *` if you want midnight Eastern during standard time. GitHub Actions cannot express a DST-aware timezone directly. Because of course it can't; that would be too kind.

## Manual build example

From the GitHub Actions UI, run **Build Warewulf node image** with:

| Input | Value |
|---|---|
| `rocky_version` | `9.8` |
| `tag_date` | `2026.8.0` |

## Import into Warewulf 4.7

On the Wisteria provisioning server:

```bash
wwctl image import docker://ghcr.io/thewistarinstitute/wisteria-rockylinux.$ROCKY_VER_$YEAR.$MONTH.0 $IMAGE_NAME
wwctl image list
```

## Files

| Path | Purpose |
|---|---|
| `Dockerfile` | Defines the Warewulf Rocky Linux node image. |
| `excludes` | Warewulf image excludes copied to `/etc/warewulf/excludes`. |
| `image_exit.sh` | Cleanup hook copied to `/etc/warewulf/image_exit.sh`. |
| `.github/workflows/build-container.yml` | GitHub Actions workflow that builds and publishes to GHCR. |
