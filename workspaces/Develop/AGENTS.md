# Work Workspace Rules

Applies to repositories under `~/Develop/`.

## Context scope

- Context scope is `work`.
- Session handoffs live in the Obsidian vault under `sessions/work/`.
- Cross-repo project specs live under `projects/work/`.
- Reusable work knowledge lives under `topics/work/`; use `topics/shared/`
  only when it genuinely applies outside work too.
- Never put credentials, tokens, private keys, or customer data in context
  docs. Link to an approved secret store instead.

## Workflow

- Repo-level `AGENTS.md` or `CLAUDE.md` supplies that repo's commands,
  architecture, tests, and contribution rules; follow it before editing.
- For work spanning repositories, use the active project spec as the source
  of truth for goal, contracts, rollout order, and initiative progress.
- Preserve ticket, PR, and design-doc links when supplied; do not invent
  process requirements that are not documented in repo or project rules.
