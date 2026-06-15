# VibeRetro68

A reference guide and project template for building classic Macintosh (System 6 and 7, 68K) applications on modern Apple Silicon Macs using the Retro68 cross-compiler toolchain.

## Using This for a New Project

This repo is a template. If you're starting your own project, download a zip instead of cloning so you get a clean slate without our git history:

1. Click **Code → Download ZIP** on GitHub, or:

   ```bash
   curl -L https://github.com/erikbuild/VibeRetro68/archive/refs/heads/main.zip -o VibeRetro68.zip
   unzip VibeRetro68.zip
   cd VibeRetro68-main
   ```

2. Initialize your own repo:

   ```bash
   git init
   git add -A
   git commit -m "Initial commit from VibeRetro68 template"
   ```

3. Rename the project. Anywhere `MyApp` appears (CMakeLists.txt's `project()`, the resource file basename, the About window's app-name string, etc.), substitute your own name.

## Quick Start

### One-shot setup

```bash
make setup
```

That runs the four sub-steps in order:

| Step | What it does |
|------|--------------|
| 1. `brew bundle` | Install the Homebrew formulae listed in [Brewfile](Brewfile) (cmake, boost, flex, etc.) |
| 2. `make fetch-deps` | Clone Retro68, download emulator binaries, ROMs, and the System 7.5.3 disk image into `deps/` |
| 3. `make build-retro68` | Build the Retro68 toolchain (~30-60 min, one-time) |
| 4. `make doctor` | Verify every piece is in place; exits non-zero on any failure |

Homebrew itself is required up front — `make setup` errors out with install instructions if `brew` isn't on `PATH`.

Every target is idempotent, so `make setup` is safe to re-run after a partial install or a `git pull` that adds new deps.

The `deps/` directory is gitignored — every clone builds its own toolchain. See [deps/retro68/README.md](deps/retro68/README.md) for layout.


### BasiliskII Networking

![BasiliskII slirp network setup](docs/basilisk_network.png)

#### First-time network setup

BasiliskII uses SLiRP for networking. On the first launch, open the MacTCP control panel and configure it with the SLiRP defaults:

Open the MacTCP Control Panel, select Ethernet, type in 10.0.2.15 to the IP address, and click "More".
- **Class**: A
- **Obtain Address**: Manually
- **IP Address**: 10.0.2.15
- **Gateway**: 10.0.2.2
- **DNS**: 10.0.2.3 (set domain to `local`), default
- **Subnet Mask**: 255.255.255.0
### Edit → Build → Run

```bash
make build         # Configure (first time) + compile
make basiliskii    # Build + launch in Basilisk II (System 7.5.3 / Quadra 950)
make minivmac      # Build + launch in Mini vMac (System 6.0.8 / Mac SE FDHD)
```

`make build` auto-configures `build/` against the Retro68 toolchain on its first run, then compiles. After that, warm builds skip straight to compilation.

The emulator targets depend on `build`, so a cold `make minivmac` from a fresh clone does the full configure → compile → launch chain in one command.

- **Basilisk II** uses `extfs` (live-synced shared folder), so a running emulator picks up new `.bin`s automatically — no restart needed while iterating.
- **Mini vMac** mmaps its disk image, so the launcher kills any running instance before relaunching with the freshly-built `.dsk`.

To target a specific app when you have multiple outputs, invoke the script directly: `scripts/run-basiliskii.sh MyApp` or `scripts/run-minivmac.sh MyApp`.

### Testing on Real Hardware

Mount `build/` over AFP on the classic Mac to easily run the compiled application.

The [TashTalk USB](https://www.tindie.com/products/feralfirmware/tashtalk-usb/) device and [GUI interface](https://github.com/FeralFirmware/TailTalk/releases) are recommended.

For physical media transfer, the post-build chain produces `build/MyApp.img` (Disk Copy 4.2 format) and `build/MyApp.hqx` (BinHex 4.0, text-safe for email).

## Versioning

Bump `/VERSION` (one line, `MAJOR.MINOR.PATCH`, each component a single digit) and rebuild — both the Finder's "Get Info" version line and the in-app About window follow automatically.

## Post-Build Artifacts

A successful `make build` produces five files in `build/`:

| File | Purpose |
|---|---|
| `MyApp` | Renamed `.APPL` data fork, tagged via `SetFile` so Basilisk II's ExtFS exposes it as a proper app |
| `MyApp.bin` | MacBinary container (any transport channel) |
| `MyApp.dsk` | Raw HFS disk image (Mini vMac, Basilisk II direct mount) |
| `MyApp.img` | Disk Copy 4.2 wrapped (real-hardware mounters: Disk Copy, MountImage, ShrinkWrap) |
| `MyApp.hqx` | BinHex 4.0 — text-safe; survives email, web, or any transport that strips type/creator |

`.hqx` requires `binhex` and `macbinary` on the build host; if either is missing, the step is silently skipped. The `SetFile` steps are skipped on Linux build hosts.

## Toolchain

All toolchain components live under `deps/retro68/` (gitignored — every clone builds its own).

| Component | Location |
|-----------|----------|
| Retro68 source | `deps/retro68/Retro68/` |
| Build output / toolchain | `deps/retro68/Retro68-build/toolchain/` |
| CMake toolchain file | `deps/retro68/Retro68-build/toolchain/m68k-apple-macos/cmake/retro68.toolchain.cmake` |
| Basilisk II | `deps/basiliskii/` |
| Mini vMac | `deps/minivmac/minivmac-macOS-SEFDHD.app` |

## Documentation

See the `docs/` directory for detailed guides:

- **[RETRO68_SETUP.md](docs/RETRO68_SETUP.md)** — Full toolchain reference: prerequisites, build flags, troubleshooting Apple Silicon issues, Universal vs Multiversal interfaces
- **[EMULATOR_SETUP.md](docs/EMULATOR_SETUP.md)** — Basilisk II (interactive testing) and Mini vMac (automated testing) configuration
- **[WORKFLOW.md](docs/WORKFLOW.md)** — The edit-build-test loop using Claude Code as a coding partner
