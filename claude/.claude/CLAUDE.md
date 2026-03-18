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

## Scope & Constraints
- Keep it minimal — no extra features, no over-engineering.
- Implement the simplest thing that works, then iterate.
- If unsure whether something is in scope, ask before building it.
