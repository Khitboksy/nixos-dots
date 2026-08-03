---
  name: repo-management
  description: Always load before any git operation.
    Clone, fetch, reset, or repository reuse.
    Enforces /var/opencode/clones/host/owner/repo layout and prevents duplicate clones.
---

# Repo-Management

Provide a Consistent method for cloning, updating, and reusing repositories

## Never

- create duplicate clones
- clone into:
  - random working directories
  - `$HOME`
  - etc...

unless explicitly instructed

## Clone Location

Repositories belong beneath `/var/opencode/clones`

**Structure**: `<host>/<owner>/<repository>`

**Examples**:

- `/var/opencode/clones/khitboksy/nixos-dots`
- `/var/opencode/clones/codeberg/example/project`
- `/var/opencode/clones/forgejo/example/project`

## Before Cloning

Check whether the repository already exists

If it exists:

- reuse it
- fetch updates
- avoid creating another one

Do not create multiple copies of the same repository

## Updating

When a clean repository is required:

- fetch
- reset to the desired revision
- remove/stash untracked files if appropriate

## Repository Selection

If multiple tasks use the same repository, they should all reuse the same
clone.

Temporary work should happen elsewhere, like `/var/opencode/tmp`

**Do not** modify the cached repository unnecessarily

If experimentation is required, create a temporary working copy inside
the current task directory, `/var/opencode/tmp/<task-name>`

## Temporary Working copies

When edits might leave the repository dirty:

Create a temporary copy beneath `/var/opencode/tmp/<task-name>/`
The cached clone should remain usable for future tasks

## Creating new repositories

You will *never* initialize a git repo. The *user* manages git, you write code.
