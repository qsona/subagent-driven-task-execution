# Subagent-Driven Task Execution

A Japanese-language agent skill for completing substantial work through scoped
delegation, independent review, revision, and final verification.

> **Language:** This skill is designed primarily for Japanese-language Claude
> and Codex workflows. Its instructions, prompts, and interface metadata are
> written in Japanese.

## Acknowledgement

This project was inspired by [Jesse Vincent's Superpowers project](https://github.com/obra/superpowers),
especially its subagent-driven development and independent review workflow.
This is an independent implementation and is not affiliated with or endorsed
by Jesse Vincent, obra, or the Superpowers project. See
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for attribution and the
upstream license notice.

## Overview

The skill gives the coordinating agent a repeatable workflow for research,
analysis, planning, document creation, software development, and other
multi-step work. It emphasizes evidence over status reports and separates the
person or agent doing the work from the person or agent reviewing it.

## How it works

1. Define the outcome, acceptance criteria, constraints, and verification.
2. Split the request into bounded deliverables with explicit handoffs.
3. Delegate each deliverable with only the context needed for that task.
4. Run an independent requirements and quality review.
5. Fix Critical and Important findings and review the revision again.
6. Review the integrated result and perform a final controller check.

The skill selects a direct, lightweight, or standard execution mode according
to the size and risk of the request. Subagents are used only when the host
environment makes them available and permits their use.

## Supported environments

- **Codex:** `SKILL.md` plus `agents/openai.yaml`. The metadata allows implicit
  invocation for substantial requests.
- **Claude Code:** `SKILL.md`. Install it as a personal or project skill using
  the directory conventions supported by your Claude Code version.

Host capabilities and skill installation conventions can change. Consult the
current documentation for your host before installation.

## Model routing

When the host supports per-subagent model selection, the skill requires every
dispatch to name a concrete model or an agent type that pins one. It routes
mechanical and deterministically verifiable work to an economy tier, prose and
integration work to a standard tier, and architecture, high-risk judgment, and
the final review to the strongest suitable tier.

If the host cannot pin the model, the workflow records the route as inherited,
automatic, or unknown. It may still delegate for context isolation, parallelism,
or independent review, but it does not claim that a cheaper model was used or
that usage was reduced.

## Installation

### Codex

Clone the repository and copy the repository into your personal skills folder:

```sh
git clone https://github.com/qsona/subagent-driven-task-execution.git
mkdir -p ~/.codex/skills/subagent-driven-task-execution
cp -R subagent-driven-task-execution/SKILL.md \
  subagent-driven-task-execution/agents \
  ~/.codex/skills/subagent-driven-task-execution/
```

Alternatively, download the `subagent-driven-task-execution-codex.zip` asset
from a tagged GitHub release. The archive contains `SKILL.md`,
`agents/openai.yaml`, `LICENSE`, and `THIRD_PARTY_NOTICES.md` under one
top-level skill directory. Extract that directory into `~/.codex/skills/`:

```sh
unzip subagent-driven-task-execution-codex.zip -d ~/.codex/skills/
```

### Claude Code

For a personal installation:

```sh
mkdir -p ~/.claude/skills/subagent-driven-task-execution
cp SKILL.md LICENSE THIRD_PARTY_NOTICES.md \
  ~/.claude/skills/subagent-driven-task-execution/
```

For a project installation, run this from the project root:

```sh
mkdir -p .claude/skills/subagent-driven-task-execution
cp /path/to/subagent-driven-task-execution/SKILL.md \
  /path/to/subagent-driven-task-execution/LICENSE \
  /path/to/subagent-driven-task-execution/THIRD_PARTY_NOTICES.md \
  .claude/skills/subagent-driven-task-execution/
```

The `subagent-driven-task-execution-claude.zip` release asset contains
`SKILL.md`, `LICENSE`, and `THIRD_PARTY_NOTICES.md` under one top-level skill
directory. Install it personally with:

```sh
unzip subagent-driven-task-execution-claude.zip -d ~/.claude/skills/
```

## Usage

Explicit invocation in Codex:

```text
$subagent-driven-task-execution を使って、この調査を分解・委譲し、
各成果物を独立レビューしてから全体を完成させてください。
```

Explicit invocation in Claude Code:

```text
/subagent-driven-task-execution この依頼を分解・委譲し、レビューを通して完遂してください。
```

Example request:

```text
競合3社を調査し、比較表と経営会議向けの提案メモを作ってください。
根拠を確認し、別の担当にレビューさせ、重要な指摘を修正してください。
```

## Operational notice

For substantial requests, Codex may invoke this skill implicitly because
`agents/openai.yaml` enables implicit invocation. Explicit invocation remains
available when you want to require the workflow.

Depending on the request and host permissions, the workflow may delegate work
to subagents and may write progress records or requested deliverables into the
current project. It can also recommend external actions. The skill requires the
controller to stop for new authorization before external publication, sending,
deletion, purchasing, or other consequential operations. Review the host's
permissions and the requested scope before use.

## Repository layout

```text
.
├── SKILL.md                 # Japanese workflow instructions
├── agents/openai.yaml       # Codex interface and invocation metadata
├── README.md                # Project documentation
├── LICENSE                  # License for this project
├── THIRD_PARTY_NOTICES.md   # Superpowers acknowledgement and MIT notice
├── CONTRIBUTING.md          # Contribution guidance
├── SECURITY.md              # Vulnerability reporting policy
├── CHANGELOG.md             # Release history
├── .gitignore               # Local and generated-file exclusions
├── scripts/validate.rb      # Repository and skill validation
├── scripts/package.sh       # Codex/Claude release-asset generation
├── test/                    # Validator behavior tests
└── .github/workflows/ci.yml # Validation and artifact packaging
```

`scripts/package.sh` writes generated archives and `SHA256SUMS` to `dist/`.
That directory is intentionally ignored and must not be committed.

## License and attribution

This project is licensed under the [MIT License](LICENSE), copyright 2026
qsona. Superpowers attribution and its retained MIT notice are provided in
[THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
