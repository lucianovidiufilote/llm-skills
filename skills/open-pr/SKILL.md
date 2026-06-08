---
name: open-pr
description: Create GitHub pull requests from the current git branch. Use when the user asks Codex to open a PR, create a pull request, compare the current branch with origin/main, prepare a PR description, include how to test, or use GitHub CLI (`gh`) to publish a PR from local changes.
---

# Open PR

## Workflow

Use this workflow to compare the current branch against `origin/main`, produce a useful pull request description, and open the PR with GitHub CLI.

1. Inspect repository state:
   - Run `git status --short --branch`.
   - Refuse to proceed if the branch is `main` or `master` unless the user explicitly asks to open from that branch.
   - Note uncommitted changes. Do not commit, stash, or discard them unless the user asks.

2. Refresh and compare with base:
   - Run `git fetch origin main`.
   - Use `origin/main...HEAD` for the comparison range.
   - Review `git diff --stat origin/main...HEAD`, `git diff --name-status origin/main...HEAD`, and relevant commit messages.
   - Read changed files as needed to understand behavior, not just file names.

3. Determine verification:
   - Prefer actual tests already run in the session.
   - If no tests were run, inspect the project scripts and run the narrowest useful checks when reasonable.
   - If checks cannot be run, say that directly in the PR body.

4. Draft the PR body:
   - Include a concise summary of user-facing or developer-facing changes.
   - Include a `How to test` section with commands run and their results.
   - Mention risks, migrations, config changes, or follow-ups only when relevant.
   - Avoid generic filler.

5. Open the PR:
   - Ensure the branch exists on the remote. If needed, push with `git push -u origin HEAD`.
   - Use `gh pr create --base main --head <branch> --title <title> --body-file <file>`.
   - If `gh` reports that a PR already exists, open or report that PR instead of creating a duplicate.

## Helper Script

Use `scripts/open_pr.py` when a deterministic scaffold is helpful:

```bash
python3 /path/to/gh-open-pr/scripts/open_pr.py --dry-run
python3 /path/to/gh-open-pr/scripts/open_pr.py --title "Short PR title"
```

The script fetches `origin/main`, summarizes commits and changed files, writes a temporary PR body, and optionally invokes `gh pr create`. Treat the generated body as a starting point; edit it when repo context or test evidence calls for a better description.

## PR Body Format

Prefer this structure:

```markdown
## Summary
- ...

## How to test
- `command` - passed
```

If no checks were run:

```markdown
## How to test
- Not run; reason.
```

Keep the final response to the user short: include the PR URL, the base/head branches, and the tests reported in the PR.
