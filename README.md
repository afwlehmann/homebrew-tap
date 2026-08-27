# homebrew-tap

Private Homebrew tap for casks not available in the main Homebrew registry.

## Casks

| Cask | Description |
|------|-------------|
| `dissectmac` | Mac storage analyzer and disk visualizer |

## Usage

```bash
brew tap afwlehmann/tap
brew install --cask dissectmac
```

## Development

All agent actions must run inside `nix develop` — provides pinned `nixfmt`,
`shellcheck`, `shfmt`, `convco`, and `brew` (Homebrew).

```bash
nix develop
```

### Linting

```bash
brew style Casks/dissectmac.rb
brew audit --cask dissectmac --online
nix flake check
```

### Bumping a cask

Per-cask bump scripts live in `scripts/`:

```bash
./scripts/bump-dissectmac.sh
```

This downloads both DMGs, computes sha256, derives the version from the
`Last-Modified` HTTP header, and updates `Casks/dissectmac.rb` in place.

## License

MIT — see [LICENSE](LICENSE).
