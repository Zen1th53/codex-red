# codex-red v1.0.0

First public Codex-native release.

## Highlights

- 79 offensive-security skills across 23 categories.
- 28 legacy skill documents converted to Codex-compatible YAML frontmatter.
- 79/79 packages pass the Codex skill validator.
- Flat installer targets `${CODEX_HOME:-$HOME/.codex}/skills` for automatic discovery.
- Machine-readable `codex-skills.json` manifest.
- Deterministic conversion and manifest-building tools.
- Supply-chain review of repository helper scripts and workflows.
- Original MIT license and upstream attribution preserved.

## Install

```bash
git clone https://github.com/Zen1th53/codex-red.git
cd codex-red
./install.sh --dry-run
./install.sh
```

Install a single category with `./install.sh --category recon` or another category listed in the README.

## Validation

- Codex skill validator: 79 passed, 0 failed.
- Installer smoke test: 79 directories and 79 `SKILL.md` files installed.
- Repository history begins with a clean Codex adaptation root commit.
