# Changelog

All notable changes to this project will be documented here.

## Unreleased

- Limit description-guided automatic invocation to top-level sessions using
  Claude Fable while retaining explicit invocation for other Claude models
  and requiring explicit invocation in Codex.
- Expand the skill description into explicit trigger conditions: invoke
  automatically for any request that involves actual work (research,
  analysis, planning, document or material creation, spreadsheets,
  development, fixes, review), including follow-up work raised
  mid-conversation, with the decision to execute directly or run the full
  workflow made after invocation; sync `scripts/validate.rb`'s required
  description phrases to the updated policy.
- Prepare the Japanese-language Claude and Codex skill for public release.
- Add project documentation, licensing, third-party attribution, and CI checks.
- Require explicit per-dispatch model routing when the host supports it, add
  economy/standard/frontier selection signals, and record unpinned routes
  without claiming model or usage guarantees.
