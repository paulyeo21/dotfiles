# Global Agent Rules

This file is the single source of truth for global agent instructions.
It is read by Claude Code as `~/.claude/CLAUDE.md` and by pi as
`~/.pi/agent/AGENTS.md` (both are symlinks to this file, wired up in
`setup.sh`). Keep guidance tool-neutral.

## Planning
- Before implementing, refer to industry best practices and standards for the domain.
- Break work into phases. Complete Phase 1 fully (including tests) and stop for
  review before starting Phase 2. State the phases explicitly upfront.

## Codebase Exploration
- Before implementing in an unfamiliar subsystem, use a Task agent to explore
  the code path end-to-end: map all functions involved, their call graph, and
  identify where complexity or risk lives. Report back with a summary before
  writing any code.

## Exploration reports
- When a task involves exploring code or designing a plan before implementing,
  include an "Exploration" section in the answer before the plan/conclusion:
  - What was examined (files, symbols, call paths) and why
  - Approaches or hypotheses considered and ruled out, with the reason
  - Surprises, gotchas, or wrong turns hit along the way
  - How the conclusion follows from the above
- Report the real trail, not a retroactively tidy story — dead ends are the
  valuable part.

## Communication
- When the user's question is verbose, restate it concisely before answering.

## Scope & Constraints
- Keep it minimal — no extra features, no over-engineering.
- Implement the simplest thing that works, then iterate.
- If unsure whether something is in scope, ask before building it.

## Repository memory and decisions

Agent memory lives in the Obsidian vault:
`~/Library/Mobile Documents/iCloud~md~obsidian/Documents/`.

Identify a repository by normalized remote (`host/owner/repo`, stripping
scheme, credentials, and `.git`), not checkout/worktree basename. Prefer
`origin`; use an existing index mapping when it intentionally differs. If
there is no remote or mapping, ask before creating memory.

Repositories are indexed in `repos/INDEX.md`:
`scope | repository | memory | status`. An active repository's curated
current truths live at `repos/<scope>/<host>/<owner>/<repo>/MEMORY.md`;
important decisions get independent ADR-style files under its `decisions/`.

**MEMORY.md contains only stable current knowledge:** architecture,
conventions, gotchas, operational facts, and links to decisions. Rewrite it
when truth changes; do not append a chronological diary. A decision record
captures context, alternatives, consequences, evidence, and status. If a
decision should be shared with teammates, promote it to tracked repo docs or
an ADR — personal vault memory is not the team source of truth.

**Concurrency:** re-read shared memory immediately before a small targeted
edit. Prefer a new decision file over rewriting unrelated memory. Never put
temporary branch state or unproven hypotheses in shared repo memory.

**Legacy transition:** repo-root `implementation-notes.md` files are
read-only migration sources. Do not create or update them. Read the current
and main-worktree copies when relevant until that repository is migrated;
never merge or delete legacy notes without review.

## Session and project context

**Scope from cwd** (use path boundaries — `Develop1` starts with `Develop`):
- Under `~/Develop/` → `work`
- Under `~/Develop1/` → `personal`
- Outside both → use an existing index entry; ask before creating context

One normalized record is kept for every **substantive session**: code/config
edits, project artifact changes, non-trivial investigation, or decisions.
Quick Q&A needs no record. Session docs live under `sessions/<scope>/`, use
`sessions/SESSION-TEMPLATE.md`, and are indexed in `sessions/INDEX.md`:
`started | scope | repository | workstream | topic | status | doc`.
Use `YYYY-MM-DD-HHMMSS-<repo>-<slug>.md` so parallel sessions do not collide.
The doc summarizes the session; never copy the raw transcript.

Cross-repo source-of-truth docs live under
`projects/<scope>/<workstream>/SPEC.md`, indexed by `projects/INDEX.md`:
`scope | workstream | repositories | spec | status`. Repository entries are
canonical `host/owner/repo` IDs.

**At session start:** read all three indexes if they exist. Open (1) the
active repository MEMORY, (2) `active` project specs listing the repository,
and (3) `open` session docs for it. Closed sessions are history: search them
only when current memory/specs point there or the task needs provenance.
Read relevant legacy implementation notes during migration. Do this before
re-deriving context from scratch.

**During the session:** create and index the session doc when work becomes
substantive. Update at milestones, not every turn. Required sections: Goal,
Outcome, Dead ends, Promoted to, Links; add Next steps while work remains
open. Project specs own cross-repo state; session docs own execution history
and handoff state.

**On wrap-up:** follow the wrap-up skill — auto-offered where supported;
otherwise read it at
`~/Library/Mobile Documents/iCloud~md~obsidian/Documents/skills/wrap-up/SKILL.md`.
Finalize the session record, promote stable conclusions to the correct
shared artifact, and mark it `closed` unless executable work remains. Closed
session docs are immutable history except for factual corrections.

## Code editing principles

These apply to every code change, in every repo, every session. They are
about how the diff itself should look and feel — not about what to build.

### Before writing the change

1. **Critique first.** Briefly, out loud: is there a simpler approach? Can
   existing code be reused or extended instead of adding a new abstraction?
   Is the change even necessary, or does it solve a problem that won't
   matter in three months?
2. **Match existing conventions** in the project over what is theoretically
   "best" in isolation. Consistency is a feature. If the codebase uses
   pattern X and your instinct says pattern Y is cleaner, use X — or
   argue for the switch explicitly as a separate change.
3. **Read the surrounding code** before editing. Understand the call sites,
   the tests, and one level up the abstraction chain. Pattern-matching
   from a single file in isolation is how subtle bugs get introduced.

### While writing the change

4. **Smallest viable diff.** No speculative changes, no unrelated refactors,
   no reformatting hunks that obscure the real change. If a refactor is
   warranted, it goes in its own commit and gets called out separately.
5. **Boring beats clever.** Optimize for the reader six months from now,
   not for elegance today. Code that needs a comment to explain *what* it
   does (vs *why*) is usually too clever.
6. **Don't invent APIs or imports.** Verify symbols exist before using them
   — read the file, grep the codebase, check the package. Hallucinated
   symbols cost more time than they save.

### After writing the change

7. **Surface trade-offs explicitly.** If a choice favors short-term ease
   over long-term maintainability (or vice versa), say so. If you picked
   approach A over B, briefly say why.
8. **State what you did NOT change** when it's relevant. Silence on
   tangentially related code is often a bug — call out the thing you saw
   but deliberately left alone, so the user can confirm that was right.
9. **Self-review the diff** before handing it back. Read it as if you
   were the reviewer. Are there hunks you can't justify? Reformatting you
   didn't intend? Drop them.

### Tests are the contract

10. When fixing a bug, add or modify a test that pins the new behavior
    before declaring done. When adding behavior, ensure there is a test
    covering it. "Tests pass" without a test for the new behavior is not
    done.

### When the task is unclear

11. Ask before building. A 30-second clarifying question beats a 30-minute
    diff in the wrong direction. If forced to assume, state the assumption
    explicitly at the top of the response so the user can correct it cheaply.
