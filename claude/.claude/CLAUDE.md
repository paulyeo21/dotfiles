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

## Implementation notes

Maintain `implementation-notes.md` at the repo root as a running log of
context that won't be obvious from the code, diff, or commit message later.
Create the file on first write; do not create it empty.

**Append an entry when:**
- You make a non-obvious decision the user didn't specify (library, pattern,
  file location, naming convention).
- You deviate from what the user literally asked for, and why.
- You make a tradeoff worth flagging (perf vs readability, scope cut, etc.).
- You hit a surprise or gotcha future-you would want to know.

**Do NOT append for:**
- Normal implementation steps visible in the diff.
- Anything already captured in the commit message or PR description.
- Style choices already codified in this file or a project CLAUDE.md.

**Entry format** (newest entries at the top):

    ## YYYY-MM-DD HH:MM — [decision|deviation|tradeoff|surprise] short title

    One to two short paragraphs. State what and why. For a tradeoff, name
    the alternative you didn't take and the reason. Reference file paths
    or symbols when relevant.

At the start of a session in a repo, if `implementation-notes.md` exists,
skim the most recent few entries for context before making related changes.
The file is gitignored globally — it stays personal unless force-committed.

## Session context docs

Per-session working docs live in the Obsidian vault (create folders as
needed): `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/sessions/`
with an index at `sessions/INDEX.md` — one line per doc:
`YYYY-MM-DD | repo | topic | open/closed`.

**At session start:** read `sessions/INDEX.md` if it exists. Open any
docs for the current repo marked `open` — they hold unfinished work and
next steps. Do this before re-deriving context from scratch.

**Create a doc** (`sessions/YYYY-MM-DD-<repo>-<slug>.md`) only when the
session will end with open loops, spans multiple sittings, or produced
knowledge with no code footprint. A completed, self-contained session
needs no doc — the commits are the artifact. Add an INDEX.md line when
creating.

**Required sections:** Next steps, Dead ends. Optional: Goal, State,
Decisions (pointers only — `implementation-notes.md` in the repo is
authoritative for repo decisions). Update at milestones — a phase done,
direction changed, significant dead end — not every turn.

**On wrap-up (when the user says "wrap up"):** follow the wrap-up skill —
auto-offered where skills are supported; otherwise read it directly at
`~/Library/Mobile Documents/iCloud~md~obsidian/Documents/skills/wrap-up/SKILL.md`.
Essence: promote durable knowledge out (repo decisions →
`implementation-notes.md`, cross-repo → `topics/`), make Next steps
cold-start executable, set INDEX.md status.

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
