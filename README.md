# macOS Setup (Homebrew)

This repo contains a small, modular setup script for provisioning a new macOS machine using **Homebrew**.

## Why this exists

When you get a new Mac (or do a clean install), the first hour is usually repetitive:

- install Homebrew
- install your common GUI apps
- install your common CLI tools
- run a couple of post-install steps

This repo makes that repeatable and easy to customize by keeping all install targets in plain text files.

## What it does

When you run `./setup.sh`, it will:

1. Install **Homebrew** (if missing)
2. Add taps from `brew-taps.txt`
3. Install GUI apps (casks) from `brew-casks.txt`
4. Install CLI tools (formulae) from `brew-formulae.txt`
5. Run post steps:
   - `brew postinstall node`
   - `npm install -g cline`

The script is designed to be **idempotent**: it skips items that are already installed.

## How it works (high level)

- `setup.sh` is the entrypoint.
- It sources small helper modules:
  - `lib/util.sh` for logging and parsing list files
  - `lib/brew.sh` for Homebrew-specific install logic
- It reads these list files:
  - `brew-taps.txt` (taps)
  - `brew-casks.txt` (GUI apps)
  - `brew-formulae.txt` (CLI tools)

The list parser ignores blank lines and anything after a `#` comment.

For installs, it checks if each cask/formula is already installed first, so re-running is safe.

## Files you edit

All lists are one token per line. Blank lines and `# comments` are ignored.

- `brew-taps.txt`
- `brew-casks.txt`
- `brew-formulae.txt`

## Usage

### 1) Download / copy this repo onto the new Mac

```bash
git clone <your-repo-url>
cd setup
```

### 2) (Optional) Customize what gets installed

Edit:

- `brew-taps.txt`
- `brew-casks.txt`
- `brew-formulae.txt`

### 3) Execute

```bash
chmod +x setup.sh lib/util.sh lib/brew.sh
./setup.sh
```

### Dry run

```bash
./setup.sh --dry-run
```

### Skip sections

```bash
./setup.sh --skip-casks
./setup.sh --skip-formulae
./setup.sh --skip-taps
./setup.sh --skip-post
```

### Override list file paths

```bash
TAPS_FILE=/path/to/taps.txt \
CASKS_FILE=/path/to/casks.txt \
FORMULAE_FILE=/path/to/formulae.txt \
./setup.sh
```

## Notes / troubleshooting

- Some cask tokens can change over time. If a cask fails with “No Cask with this name exists”, the script will log a warning and continue.
- Homebrew installation may prompt for your macOS password (sudo).
- If you want to validate the script syntax without running installs, you can run:
  ```bash
  bash -n setup.sh lib/util.sh lib/brew.sh
  ```
## Manual Steps
- Install OMZ https://ohmyz.sh/#install
- https://lowtechguys.com/rcmd/
