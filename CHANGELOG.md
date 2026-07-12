# Changelog

All notable changes to this project will be documented here.

## Unreleased

- Limit description-guided automatic invocation to top-level Claude Fable 5
  sessions while retaining explicit invocation for other Claude models and
  requiring explicit invocation in Codex.
- Prepare the Japanese-language Claude and Codex skill for public release.
- Add project documentation, licensing, third-party attribution, and CI checks.
- Require explicit per-dispatch model routing when the host supports it, add
  economy/standard/frontier selection signals, and record unpinned routes
  without claiming model or usage guarantees.
