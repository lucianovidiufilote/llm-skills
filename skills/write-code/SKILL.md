---
name: write-code
description: Write or modify production code using project conventions and language-specific references. Use when implementing features, refactoring, adding tests, wiring dependencies, naming code constructs, or explaining code structure decisions. For Go work, read references/go.md.
---

# Write Code

Use this skill when writing or changing code. Prefer the repository's existing patterns first, then apply the language-specific reference for unresolved choices.

## Workflow

1. Inspect the local code before deciding on structure.
   - Read nearby files, constructors, naming, tests, and package boundaries.
   - Prefer established local patterns over generic advice.

2. Select the language reference.
   - Go: read `references/go.md`.
   - For another language, add a new file under `references/<language>.md` and keep this `SKILL.md` language-neutral.

3. Make the smallest coherent change.
   - Keep behavior changes close to the feature or package that owns them.
   - Avoid new abstractions unless they remove real duplication or clarify dependency boundaries.
   - Keep data structs simple and behavior/dependency holders explicit.

4. Verify.
   - Run the narrowest meaningful formatter and tests.
   - If tests cannot run, report the blocker and the risk.

## General Conventions

- Use constructors for behavior objects that hold dependencies or require setup.
- Use direct struct literals for simple data payloads and DTOs.
- Keep transport envelopes separate from business data when it clarifies serialization or routing.
- Use names that describe the role directly; avoid overloaded terms when the architecture does not use that concept.
- Prefer boring, obvious names over clever compact names.
- Keep comments rare and useful.

## Adding Language References

When adding another language, create a separate reference file:

```text
references/go.md
references/typescript.md
references/python.md
```

Keep each reference focused on practical choices Codex should apply while editing code in that language.
