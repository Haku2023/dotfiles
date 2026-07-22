# dotbox — dotfiles dev box for Apple Container

A reproducible Linux dev environment (zsh + nvim + your `~/dotfiles`) that runs on
[Apple Container](https://github.com/apple/container) on macOS. Each container is a
lightweight Linux VM; this image bakes Homebrew + your tools and mounts your dotfiles
live so configs stay editable from the Mac.

| | |
|---|---|
| **Image name** | `dotbox` (tag `dotbox:latest`) |
| **Architecture** | `linux/arm64` (Apple Silicon) |
| **Runs as** | `root` — required ([why](#why-it-runs-as-root)) |
| **Memory** | helper runs with `-m 4g` (default is 1 GB, too small for treesitter) |
| **Launch with** | `~/dotfiles/container/dotbox.sh` |

---

## Files in this folder

| File | Purpose |
|------|---------|
| `Containerfile` | Build recipe: Ubuntu + Homebrew + CLI tools + zsh plugins + tree-sitter CLI |
| `entrypoint.zsh` | On start: runs `~/dotfiles/install_new.sh` to symlink configs, then execs your command (defaults to login zsh) |
| `dotbox.sh` | Launch helper — sets all mounts, `-m 4g`, and optional project dir |
| `README.md` | This file |

---

## Quick start

```bash
# 1. Build the image (first build takes a few minutes — installs Homebrew)
container build -t dotbox -f ~/dotfiles/container/Containerfile ~/dotfiles/container

# 2. Launch
~/dotfiles/container/dotbox.sh            # interactive zsh
~/dotfiles/container/dotbox.sh nvim       # straight into nvim
```

### Work on a project

The helper takes an optional project directory as its **first argument** — it's mounted
at `/root/work` and you start there. Anything after it is the command to run:

```bash
~/dotfiles/container/dotbox.sh ~/projects/app          # shell in the project
~/dotfiles/container/dotbox.sh ~/projects/app nvim .   # open nvim in the project
```

Rule: first arg is an existing directory → it's the **project**; the rest is the
**command**. The project is editable live from both macOS and the container.

### Shorter: add an alias

In `~/dotfiles/zsh/zshrc.d/aliases.zsh` (runs on the **Mac**, where you launch from):
```zsh
alias dotbox="$HOME/dotfiles/container/dotbox.sh"
```
Then daily usage is just: `dotbox ~/projects/app nvim`

> You never edit the `container run` command by hand — all flags live in `dotbox.sh`.
> Change something once there and every launch picks it up.

---

## Apple Container basics

### Image vs. container (two different "names")

| Thing | Example | Used with |
|-------|---------|-----------|
| **Image** — the template/blueprint | `dotbox`, `ubuntu`, `alpine` | `container run`, `container build -t` |
| **Container** — a running/stopped instance | random ID, or `--name mybox` | `container start`, `stop`, `rm`, `exec` |

```bash
container image ls     # list images   → use these after `run`
container ls           # running containers
container ls -a        # all containers → use these after `start`/`stop`/`rm`
```

### run vs. start (a common trap)

- **`container run <image>`** — creates a **new** container from an **image**.
  Passing a *container* name here makes it try to pull that name from Docker Hub
  (→ `401 Unauthorized`).
- **`container start -ai <container>`** — wakes an **existing, stopped** container
  (`-a` attach output, `-i` attach input).

```bash
container run  -it --name mybox dotbox   # new container from image
container start -ai mybox                 # resume that same container later
```

### Closing / cleaning up

```bash
exit                 # (or Ctrl-D) inside the shell — stops the container
# Ctrl-P, Ctrl-Q     # detach but leave it running
container stop mybox # stop from outside
container kill mybox # force kill
container rm mybox   # delete a stopped container
container prune      # remove all stopped containers
```

### Accessing Mac folders (bind mounts)

There is no Docker-Desktop-style shared-folder GUI — the `-v` flag *is* the share:

```bash
-v /Users/you/path:/path/in/container        # read-write
-v /Users/you/data:/data:ro                  # read-only
```

Edits are live in both directions. **Mounts can only be set at create/run time** —
you cannot add a mount to an already-created container.

Copy files without a mount:
```bash
container cp <id>:/path/in/container ./local   # container → Mac
container cp ./local <id>:/path/in/container   # Mac → container
```

### Memory & CPU

Set at run time (cannot be changed on a running container — start a fresh one):
```bash
-m 4g      # memory (dotbox.sh sets this; default 1 GB is too small for treesitter)
-c 4       # CPUs
```

---

## Why it runs as root

Two Apple Container 1.0 facts forced this design:

1. **Named volumes are broken** — they fail to boot the VM
   (`storage device attachment is invalid`). So persistence uses plain host
   **bind mounts** under `~/.cache/dotbox/` instead.
2. **Bind mounts appear owned by `root` (uid 0) inside the container.** A non-root
   user can't write to any mounted path → `E739`/`E303` "permission denied" from nvim,
   failed `lazy-lock.json` writes, etc.

Running as root makes the root-owned mounts writable. This is safe: "root" here is
root **inside a throwaway Linux VM**, fully isolated from macOS — it is *not* root on
your Mac and can only touch the paths you explicitly mount.

The only catch: **Homebrew refuses to run as root** — so use `dbrew` (below).

---

## Installing packages

Homebrew is installed at build time as a non-root `dev` user (its installer refuses
root). At runtime you use the **`dbrew`** wrapper, which runs brew as `dev`; root can
then use whatever it installs (everything lives in the shared `/home/linuxbrew` prefix).

| Need | How | Persists? |
|------|-----|-----------|
| Try a package once | `dbrew install <pkg>` (inside the container) | ❌ lost on next `--rm` run |
| Add a permanent tool | edit `Containerfile`, rebuild | ✅ baked into image |

### Rebuilds use layer caching (not "from zero")

Each Containerfile line is a cached layer. A rebuild reuses everything up to the
**first changed line**, then re-runs that line and everything after it.

- Installing **Homebrew itself** sits above the package line → always cached.
- Editing the `brew install` line reinstalls **all packages on that line**.
- **Tip:** add new packages on their *own* `RUN brew install` line so only the new
  ones reinstall:

```dockerfile
RUN brew install neovim fzf fd bat eza zoxide mcfly   # frozen → stays cached
RUN brew install gdb gfortran gcc node make           # add new stuff here
```

### `RUN` user context (gotcha)

A `RUN` executes as whatever `USER` is currently active.
- Brew packages → on the brew line, while `USER dev`.
- Anything writing to system dirs like `/usr/local/bin` → **must be after `USER root`**,
  or you get `Permission denied` at **build** time (this bit the tree-sitter CLI step).

---

## Language servers & conda

Some tooling can't come from Homebrew or mason and is baked into the image directly:

| Tool | Source | Why not mason/brew |
|------|--------|--------------------|
| `clangd` | apt (`clangd`) | mason has no `linux/arm64` prebuilt → "platform is unsupported" |
| `python3` / `pip` | apt | needed by python LSPs (e.g. `fortls`); base image had no Python |
| conda | Miniforge (Linux/aarch64) at `/opt/conda` | a macOS conda (`~/Tools`) is Mach-O and can't run in a Linux VM |

- **clangd:** installed system-wide and on `$PATH`. Remove `clangd` from your mason
  `ensure_installed` so mason stops trying to download it — `lspconfig` picks up the
  system binary automatically.
- **conda:** `/opt/conda/bin` is on `$PATH`, so `conda` works out of the box. To
  activate environments:
  ```bash
  source /opt/conda/etc/profile.d/conda.sh && conda activate <env>
  ```
  This is a **separate, Linux** conda from your macOS `~/Tools` one — they can't be
  shared. To reuse env definitions: `conda env export > env.yml` on macOS, then
  `conda env create -f env.yml` inside the container.

---

## Persistence

Nvim plugins, treesitter parsers, zsh completion cache, etc. live under the bind
mounts the helper sets:

```
~/.cache/dotbox/share  → /root/.local/share   (nvim plugins, built .so files)
~/.cache/dotbox/state  → /root/.local/state   (swap, undo, shada)
~/.cache/dotbox/cache  → /root/.cache         (zsh zcompdump, nvim parser cache)
```

These survive `--rm`. To reset nvim from scratch: `rm -rf ~/.cache/dotbox/share`.

> Things installed at runtime via `dbrew` or `curl` into `/usr/local/bin` live in the
> **container layer**, which is *not* mounted — so they vanish on the next `--rm`.
> Bake them into the image for permanence.

---

## Troubleshooting

### nvim: `permission denied` creating `.local/share` / `.local/state` (`E739`/`E303`)
The container isn't running as root, so it can't write to the root-owned bind mounts.
Use `dotbox.sh` (image runs as root). See [Why it runs as root](#why-it-runs-as-root).

### Treesitter parser fails to install (often `latex`)
Two distinct causes — check in this order:

1. **`Killed` / `parser.c: No such file or directory`** → **out of memory.**
   `tree-sitter generate` on big grammars is OOM-killed under the default 1 GB; it then
   leaves no `src/parser.c` / `src/tree_sitter/parser.h`, so the compile fails with a
   misleading "no such file". Fix: more RAM (`dotbox.sh` already passes `-m 4g`). Memory
   can't change on a running container — exit, relaunch, then `:TSInstall latex`.
2. **`ENOENT 'tree-sitter'`** → the **CLI is missing.** The Homebrew `tree-sitter`
   formula is the **library only** (no CLI binary), so `dbrew install tree-sitter` won't
   give you the command. The prebuilt CLI is baked into the image (`/usr/local/bin/tree-sitter`).
   To add it manually:
   ```bash
   curl -fsSL https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-arm64.gz \
     | gunzip > /usr/local/bin/tree-sitter && chmod +x /usr/local/bin/tree-sitter
   rehash && tree-sitter --version
   ```

To see `generate`'s real (nvim-hidden) error, run it by hand:
`cd ~/.cache/nvim/tree-sitter-<lang> && tree-sitter generate`.
If you don't need a grammar, just drop it from your treesitter `ensure_installed`.

### `cannot open shared object file: ...libfzf.so` (telescope-fzf-native)
The plugin's native C lib wasn't compiled (e.g. a headless `Lazy sync` segfaulted and
skipped build steps). Compile it **inside the container** (Linux/arm64 — never on the Mac):
```bash
cd ~/.local/share/nvim/lazy/telescope-fzf-native.nvim && make
```
`make: Nothing to be done for 'all'` means it's already built — just restart nvim.

### mason: `clangd` → "The current platform is unsupported"
There's no `linux/arm64` clangd prebuilt for mason. Use the system one (baked in via
apt) instead, and drop `clangd` from mason's `ensure_installed`. See
[Language servers & conda](#language-servers--conda).

### mason: `fortls` → "Unable to find python3 installation in PATH"
The base image had no Python; it's now installed via apt. After a rebuild + fresh
container, `fortls` installs fine (mason/pip). `gfortran` is already on the brew line.

### conda / python binaries give "exec format error"
You're trying to run **macOS** binaries (e.g. your `~/Tools` miniconda) in the Linux
VM. Use the image's Linux conda at `/opt/conda` instead — see
[Language servers & conda](#language-servers--conda).

### Tool errors right after adding it to the image (mason `npm ENOENT`, etc.)
Those log lines are usually **stale** — from a container built *before* you added the
tool. Rebuild the image, start a **fresh** container, then retry the action
(`:TSUpdate`, `:MasonInstall <pkg>`). The image sets `PATH` to include the brew prefix
globally, so nvim's spawned processes find brew tools without any shell init.

### `which <tool>` says "not found" right after installing it
zsh caches the command table at startup. Refresh it:
```bash
rehash        # or: hash -r
```
(Nvim searches `$PATH` directly and isn't affected — just restart nvim.)

### LazyVim plugins didn't finish building
Don't rely on headless `nvim --headless "+Lazy! sync" +qa` (it can segfault and skip
native builds). Just open nvim normally the first time — LazyVim installs and builds
interactively. To force builds: `:Lazy` then press `I`, or `:Lazy build <plugin>`.

### `401 Unauthorized ... registry-1.docker.io`
You ran `container run <container-name>`. `run` takes an **image**; use
`container start -ai <container-name>` to resume an existing container.

---

## How the image is wired (summary)

```
FROM ubuntu:24.04
  apt: zsh git curl build-essential sudo locales ...        # cached
  USER dev
  install Homebrew → /home/linuxbrew/.linuxbrew             # cached (slow)
  brew install neovim fzf fd bat eza zoxide mcfly \
              gdb gfortran gcc node make                    # edit → reinstalls this line
  USER root ; HOME=/root
  tree-sitter CLI → /usr/local/bin                          # needs root (system dir)
  apt: clangd python3 python3-pip python3-venv              # mason can't supply these on arm64
  Miniforge (Linux/aarch64) → /opt/conda ; PATH+=/opt/conda/bin
  clone zsh plugins → /root/.zsh-plugins                    # p10k, autosuggestions, vi-mode, fast-syntax
  dbrew wrapper → /usr/local/bin/dbrew                      # runs `brew` as the dev user
  ENTRYPOINT entrypoint.zsh → runs install_new.sh, execs CMD (default: zsh -l)
```

Runtime mounts (set by `dotbox.sh`): `~/dotfiles`, the three `~/.cache/dotbox/*`
persistence dirs, and an optional project at `/root/work`.
```
