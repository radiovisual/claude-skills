---
name: semver-release
description: Cut a Semantic Versioning release of a GitHub repository. Finds the current version from git tags, reads every commit since that release, picks the major/minor/patch bump, writes grouped release notes, updates VERSION.md, then tags and publishes a GitHub release with gh. Use when asked to release, publish or tag a new version; not for writing a single commit or opening a pull request.
argument-hint: "[major | minor | patch | <exact version>] [--pre <label>] [--dry-run]"
---

# SemVer Release

Cut the next release: work out the version from the commits, write release notes people want to read, record the
version in `VERSION.md`, and publish the tag and GitHub release.

**Input**: $ARGUMENTS

A release is public and hard to take back. Nothing is committed, tagged, pushed or published until the user has
seen the version and notes and said yes (Phase 5). With `--dry-run`, stop after showing them.

## Phase 0 — Project conventions

If `.claude/references/conventions.md` exists, read its `## release` section. Its rules win over the defaults
below (tag prefix, version files, notes format, release branch).

## Phase 1 — Preflight

```bash
git fetch --tags origin
git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'   # default branch; fallback main
git branch --show-current
git status --short
git rev-list --count HEAD..origin/{default}                                  # commits we're missing
gh auth status
```

| State | Action |
|-------|--------|
| Not on the default branch (and conventions name no release branch) | STOP: "Switch to {default} to release." |
| Uncommitted changes | STOP: "Commit or stash first; a release must match a commit." |
| Behind `origin/{default}` | STOP: "Pull first." |
| `gh` not authenticated | STOP: "Run `gh auth login`." |
| Latest CI run on HEAD failed (`gh run list --branch {default} --limit 1`) | Warn and ask before continuing. |

## Phase 2 — Current version

The **latest SemVer tag** is the current version. `VERSION.md` is for readers; if it disagrees with the tags,
trust the tags and mention the mismatch.

```bash
git tag --list --sort=-v:refname
```

- Consider only tags matching `v?MAJOR.MINOR.PATCH` (optionally `-prerelease`). Sort by SemVer precedence, not
  alphabetically: `v1.10.0` is newer than `v1.9.0`, and `v1.10.0` is newer than `v1.10.0-rc.1`.
- The current version is the highest **stable** tag. Prerelease tags only matter when continuing a prerelease line.
- Keep the project's prefix: if existing tags are `v1.2.3` use `v`; if they are `1.2.3` use none. Default `v`.
- **No tags yet:** this is the first release. Propose `0.1.0` (still changing) or `1.0.0` (stable, public API), and
  ask which. Release notes then cover the whole history, summarized.

## Phase 3 — Commits since the last release

```bash
git log {tag}..HEAD --no-merges --format='%h%x09%s%x09%an%n%b%x1e'
```

- **No commits** → STOP: "Nothing to release since {tag}."
- Skip release commits (`chore(release): …`) and merge commits.
- Note PR numbers from subjects like `(#42)`; they become links in the notes.

## Phase 4 — Choose the version

Classify each commit. Conventional Commit tags make it mechanical; for other messages, read the commit (and diff if
needed) and decide. If you still can't tell whether something breaks users, ask.

| Change | Examples | Bump (1.x and later) | Bump (0.x) |
|--------|----------|----------------------|------------|
| Breaking | `feat!:`, `fix!:`, a `BREAKING CHANGE:` footer, removed or renamed public API | **major** | minor |
| New feature | `feat:` | minor | minor |
| Fix or improvement | `fix:`, `perf:` | patch | patch |
| Internal only | `docs:`, `refactor:`, `test:`, `chore:`, `ci:`, `build:`, `style:` | patch | patch |

- The highest bump wins: one breaking commit among twenty fixes is still a major release.
- **0.x:** breaking changes bump the minor version. Going to `1.0.0` is a deliberate decision; only do it when the
  user asks.
- **Only internal changes:** say so and ask whether a release is worth it.
- **The user named a bump or version:** use it, but if it's lower than the commits call for (e.g. "patch" with a
  breaking change), warn and ask. Never reuse or go below an existing version.
- **`--pre <label>`:** produce `X.Y.Z-<label>.N`, continuing N from existing tags for that version and label (e.g.
  `v2.0.0-rc.1` → `v2.0.0-rc.2`), and publish as a prerelease.

## Phase 5 — Write the notes and confirm

Release notes are for people using the project, not for reading the git log back:

```markdown
## ⚠️ Breaking changes
- Config key `timeout` is now `timeoutMs`. Rename it in your config. (#51)

## Features
- Export orders as CSV from the orders page. (#48)

## Fixes
- Invoice totals round half-up, matching the payment provider. (a1b2c3d)

## Other changes
- Upgraded lodash to 4.17.21.

**Full changelog**: https://github.com/{owner}/{repo}/compare/{previous tag}...{new tag}
```

- Only include sections that have entries. Breaking changes always come first and say what users must do.
- Rewrite terse commit subjects into plain, user-facing sentences. Merge several commits about one change.
- Link `#N` PR numbers; otherwise cite the short hash.
- Collapse purely internal work (tests, CI, refactors) into one or two lines under **Other changes**, or leave it
  out when nobody using the project would care.
- First release: no compare link; summarize what the project does instead.

Get `{owner}/{repo}` from `gh repo view --json nameWithOwner -q .nameWithOwner`.

**Show the user**: current → next version and why (which commits drove the bump), the notes, and the files that
will change. **Wait for a yes.** Adjust and show again if they want changes.

## Phase 6 — Update files and publish

1. Write `VERSION.md` at the repository root (create it on the first release):

   ```markdown
   # Version

   Current release: **{new tag}** ({YYYY-MM-DD})

   Release notes: https://github.com/{owner}/{repo}/releases/tag/{new tag}

   This file is updated automatically with each release. Git tags are the source of truth.
   ```

2. If the project has a `CHANGELOG.md`, add the notes at the top under `## [{version}] - {YYYY-MM-DD}`. Don't create
   one unless asked; the GitHub release is the changelog.
3. If the project stores its version elsewhere (`package.json`, `pyproject.toml`, `Cargo.toml`, or files named in
   conventions), update those too, e.g. `npm version {version} --no-git-tag-version`.
4. Commit, tag and push:

   ```bash
   git add VERSION.md {other version files}
   git commit -m "chore(release): {new tag}"
   git tag -a {new tag} -m "{new tag}"
   git push origin HEAD
   git push origin {new tag}
   ```

   If the push is rejected by branch protection: delete the local tag (`git tag -d {new tag}`), put the release
   commit on a branch, open a PR, and tag the merged commit afterwards.

5. Publish:

   ```bash
   gh release create {new tag} --verify-tag --title "{new tag}" --notes-file {notes file} [--prerelease]
   ```

   Write the notes to a temporary file outside the repository first.

## Output

Print the new version, the release URL (`gh release view {new tag} --json url -q .url`), and the files changed.
If anything failed after the tag was pushed, say exactly what exists (commit, tag, release) and what's left to do;
don't retry destructive steps on your own.
