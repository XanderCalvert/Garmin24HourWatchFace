# Publishing a GitHub release

Releases host the compiled `.prg` files friends sideload to their watches. Source code stays on the repo; binaries are attached to each release.

Repo: [XanderCalvert/Garmin24HourWatchFace](https://github.com/XanderCalvert/Garmin24HourWatchFace)

## One-time: push the project

From the project folder (PowerShell):

```powershell
cd "F:\CodingProjects\Garmin\24hourclockface"

git remote add origin https://github.com/XanderCalvert/Garmin24HourWatchFace.git
# If remote already exists: git remote set-url origin https://github.com/XanderCalvert/Garmin24HourWatchFace.git

git add -A
git status
git commit -m "v1.1 watch face: layout, settings, themes, battery indicator"
git branch -M main
git push -u origin main
```

Use `master` instead of `main` if your local branch is still `master`.

`developer_key.der` and `bin/*.prg` are gitignored and are **not** pushed.

## Each release

### 1. Build all device files

```powershell
.\build-all.ps1
```

### 2. Package a zip (optional but tidy)

```powershell
.\package-release.ps1 -Version "1.1.0"
```

Creates `release/24hourclockface-1.1.0.zip` with every `.prg` plus `INSTALL.md`.

### 3. Tag and push

```powershell
git tag v1.1.0
git push origin v1.1.0
```

Also push any new source commits: `git push origin main`

### 4. Create the release on GitHub

1. Open [Releases](https://github.com/XanderCalvert/Garmin24HourWatchFace/releases) → **Draft a new release**.
2. **Choose a tag:** `v1.1.0` (create from `main` if needed).
3. **Title:** e.g. `v1.1.0`
4. **Description:** short changelog; link to [INSTALL.md](INSTALL.md) for install steps.
5. **Attach files:** upload either:
   - `release/24hourclockface-1.1.0.zip`, or
   - individual files from `bin/`: `24hourclockface-enduro3.prg`, `24hourclockface-fenix6xpro.prg`, etc.
6. **Publish release**.

Friends go to **Releases → Assets**, download the `.prg` (or zip) for their watch, and follow [INSTALL.md](INSTALL.md).

## Adding a new watch model later

1. Download the device in **Connect IQ SDK Manager**.
2. Add `<iq:product id="…"/>` to `manifest.xml`.
3. Add the device ID to `build-all.ps1`.
4. Run `.\build-all.ps1`, publish a new release with the extra `.prg`.

## Connect IQ store (optional later)

GitHub releases are **sideload only**. Phone settings in Garmin Connect require publishing to the [Connect IQ store](https://developer.garmin.com/connect-iq/submit-an-app/) (or a private beta). Sideload + on-watch **Display** menu works without the store.
