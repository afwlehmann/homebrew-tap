# AGENTS.md

## Repository Structure

- `Casks/` cask definitions (Ruby) · `scripts/` per-cask bump scripts (bash) · `.github/workflows/` CI + livecheck · `flake.nix` dev shell · `.editorconfig` · `LICENSE`

## Dev Environment

- Work inside `nix develop` at the repo root — provides pinned `nixfmt`,
  `shellcheck`, `shfmt`, `convco`, and Homebrew.
- One-shot: `nix develop -c <cmd>`.
- `nix flake check` runs all hooks in a sandbox (no fs writes, no network).

## Git Operations

- Use the bash tool's `workdir` parameter (never `git -C`).
- Flakes only see git-tracked files — `git add` new files before building.
- `git commit --fixup=<sha>` for fixups (not `-m "fixup!"`).
- Conventional commits enforced by `convco` (hook + CI).

## Cask Conventions

- One `.rb` file per cask in `Casks/`.
- ARM/Intel split via `on_arm`/`on_intel` blocks (not separate casks).
- Version from `Last-Modified` HTTP header as `YYYYMMDD`.
- `livecheck do skip` — unversioned URLs; detection via bump scripts + GHA.
- `zap trash:` lists all known app support/cache/preferences paths.
- No `auto_updates` unless the app ships Sparkle (check `Info.plist` for `SU*` keys).

## Bump Scripts

- Per-cask: `scripts/bump-<name>.sh`.
- Downloads both arch DMGs, computes sha256, derives version, updates the cask.
- Must run inside `nix develop` (needs `curl`, `shasum`/`sha256sum`).

## CI Workflows

- `style-and-audit.yml` — `brew style` + `brew audit --online` on every PR (matrix over all casks).
- `nix-check.yml` — `nix flake check` on every PR.
- `livecheck-dissectmac.yml` — monthly cron (`0 7 1 * *`) + `workflow_dispatch`; runs bump script, opens PR if version changed.
- `install-test.yml` — `workflow_dispatch` only; installs the cask on a macOS runner.

## Branch Protection

Require `style-and-audit` + `nix-check` status checks on `main` (one-time GitHub setting).

## Nix Conventions

- Self-contained flake — all dev tools pinned via nixpkgs.
- Indentation/line length per `.editorconfig` (spaces, 2).
- `nixfmt` formatting enforced by pre-commit hook.
