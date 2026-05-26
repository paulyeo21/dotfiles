# Global Claude Rules

## Planning
- Before implementing, refer to industry best practices and standards for the domain.
- Break work into phases. Complete Phase 1 fully (including tests) and stop for
  review before starting Phase 2. State the phases explicitly upfront.

## Codebase Exploration
- Before implementing in an unfamiliar subsystem, use a Task agent to explore
  the code path end-to-end: map all functions involved, their call graph, and
  identify where complexity or risk lives. Report back with a summary before
  writing any code.

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
