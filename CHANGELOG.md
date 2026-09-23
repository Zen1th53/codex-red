# Changelog

## 1.0.0 — Codex adaptation

- Adapted 79 offensive-security skills for Codex discovery.
- Converted 28 legacy metadata documents to Codex YAML frontmatter.
- Removed Claude-specific instruction wrappers from converted skills.
- Changed the installer to flatten skills into `${CODEX_HOME:-$HOME/.codex}/skills`.
- Renamed the machine-readable manifest to `codex-skills.json`.
- Added deterministic conversion and manifest tools.
- Preserved the upstream MIT license and attribution.
