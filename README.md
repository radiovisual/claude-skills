# claude-skills

[![Validate skills](https://github.com/radiovisual/claude-skills/actions/workflows/validate.yml/badge.svg)](https://github.com/radiovisual/claude-skills/actions/workflows/validate.yml)

Agent skills for Claude Code (and any agent that reads the `SKILL.md` format).
Each skill is a folder with a short `SKILL.md` entrypoint and `references/`
files the agent only opens when a task needs that detail.

Every skill here also comes with evaluation cases: prompts that should and
shouldn't trigger it, plus graded tasks with known-good and known-bad answers.
CI checks all of it on every push and pull request.

## Skills

| Skill | What it does |
|---|---|
| [feature-slicing](skills/feature-slicing/SKILL.md) | Organizes frontend code with Feature-Sliced Design (FSD): layers, slices, segments, public APIs and import rules. For adopting FSD, placing code in an existing FSD project, or fixing slice imports. Not for every new component or page. |
| [mermaid-diagrams](skills/mermaid-diagrams/SKILL.md) | Creates or fixes Mermaid diagrams in Markdown: flowcharts, sequence, ER, class, state, Gantt and architecture diagrams, including reserved-word and syntax pitfalls. Only when Mermaid is the output format. |
| [modern-css](skills/modern-css/SKILL.md) | Implements or debugs CSS layouts, responsive styles, themes and motion with native features (container queries, `:has()`, cascade layers, logical properties, `light-dark()`, and more), with browser-support caveats. Not for unrelated frontend logic. |
| [piv-commit](skills/piv-commit/SKILL.md) | Commits all uncommitted changes (tracked and untracked) as one atomic commit with a conventional `<tag>: <description>` message, then prints a What Changed summary and lists any changed `.claude/` files. Follows the `## commit` section of `.claude/references/conventions.md` when the project has one. |
| [piv-create-pr](skills/piv-create-pr/SKILL.md) | Pushes a committed feature branch and opens a GitHub pull request with `gh`. Detects the base branch, stops on the base branch, with uncommitted changes, with nothing to merge, or when a PR already exists, and writes a body with summary, changes, validation, reviewer notes and linked tickets. Follows the `## pr` section of `.claude/references/conventions.md`. |
| [piv-fix-review-findings](skills/piv-fix-review-findings/SKILL.md) | Works through code-review findings from a person or an AI. Sorts each into fix now, defer (logged as an issue), needs a human look, or noise; asks when the scope is unclear; fixes one at a time with a test; validates; and commits and pushes when the work is on a PR. |
| [slack-block-kit](skills/slack-block-kit/SKILL.md) | Builds or debugs Slack Block Kit payloads for messages, modals, App Home, streaming responses and Work Object unfurls: block and element limits, surfaces, and interaction schemas. Not for plain text formatting. |
| [slack-mrkdwn](skills/slack-mrkdwn/SKILL.md) | Formats or debugs Slack message text: mrkdwn vs. standard Markdown vs. `rich_text` vs. `plain_text`, mentions, links, dates and escaping. Not for Block Kit layout. |

### Installing skills

Claude Code looks for skills in two places:

- `~/.claude/skills/` for skills available in **every project** on your machine
- `<project>/.claude/skills/` for skills available in **that project only**,
  and to anyone else who clones it if you commit the folder

Each skill is a self-contained folder, so installing means putting that folder
in one of those places. Start a new Claude Code session (or run `/skills`) to
pick up newly installed skills. `/skills` also lists what's installed.

#### Every project (global)

Clone this repository once and symlink the skills into `~/.claude/skills/`.
Because they're links, `git pull` updates every project at once:

```bash
git clone https://github.com/radiovisual/claude-skills.git ~/claude-skills
mkdir -p ~/.claude/skills

# All skills:
for skill in ~/claude-skills/skills/*/; do ln -sfn "${skill%/}" ~/.claude/skills/; done

# Or only the ones you want:
ln -sfn ~/claude-skills/skills/modern-css ~/.claude/skills/
```

To update, run `git -C ~/claude-skills pull`. When new skills are added,
run the loop again; it's safe to repeat. To uninstall a skill, delete its
link: `rm ~/.claude/skills/modern-css`.

#### One project only

Copy the skill into the project's `.claude/skills/` folder, then commit it so
everyone working on the project gets the same version:

```bash
cd your-project
mkdir -p .claude/skills
cp -r ~/claude-skills/skills/modern-css .claude/skills/
git add .claude/skills/modern-css
```

This copy doesn't change when this repository does. Copy it again to update.

#### With the `skills` CLI

The [`skills` CLI](https://skills.sh) installs straight from this GitHub
repository, without cloning it. Only the CLI itself comes from npm; the skills
don't need to be published anywhere else. `--agent claude-code` targets Claude
Code; leave it out to choose agents interactively.

```bash
# See what's available
npx skills add https://github.com/radiovisual/claude-skills --list

# One project: run inside the project; installs into ./.claude/skills/
npx skills add https://github.com/radiovisual/claude-skills --skill modern-css --agent claude-code

# Every project: -g installs at the user level
npx skills add https://github.com/radiovisual/claude-skills --skill '*' --agent claude-code -g
```

Pass several names to `--skill` (`--skill modern-css slack-mrkdwn`) or `'*'` for
all of them. A project install also writes a `skills-lock.json` recording what
was installed. Update with `npx skills update` and uninstall with
`npx skills remove <name>`.

### Using a skill

You don't need to invoke a skill yourself. The agent sees each skill's `name`
and `description` and loads the skill when a request matches it. For example,
"why does this Slack message show `*bold*` literally?" loads `slack-mrkdwn`.
To force a specific skill, name it: "use the mermaid-diagrams skill to fix
this flowchart", or `/mermaid-diagrams` in Claude Code.

The descriptions also say what each skill is *not* for, so it stays out of
unrelated work. Asking for a JavaScript `Array.slice` explanation should not
load `feature-slicing`, for example. The routing cases in
[`evals/routing.json`](evals/routing.json) record these expectations.

## Repository layout

```
skills/<name>/SKILL.md            entrypoint: YAML frontmatter (name, description) + instructions
skills/<name>/references/*.md     detail loaded on demand; must be linked from SKILL.md
scripts/validate_skills.py        structural validator (runs in CI)
evals/routing.json                prompts and the skills each one should load
evals/workflows.json              one manual end-to-end review prompt per skill
evals/tasks/<name>.json           graded artifact tasks for each skill
evals/fixtures/<name>/            raw inputs given to the model in those tasks
evals/reference_outputs/<name>/   known-good answers (good-N) and deliberately wrong ones (bad-N)
evals/assertions/<name>/          private executable checks (JavaScript graders)
evals/runtime/                    sandboxed Docker runtime for executable graders
evals/*.py                        validation, grading, calibration and the model runner
.github/workflows/validate.yml    CI
```

## Tests and validation

Everything here runs without an API key or model calls, except the live runner
described last.

| Check | What it verifies | Needs |
|---|---|---|
| `scripts/validate_skills.py` | Frontmatter is valid; `name` matches the folder; each description is one line of at most 1024 characters; every reference file is linked from its `SKILL.md` and no link points outside the skill; each skill has `direct`, `indirect`, `negative`, `incomplete` and `boundary` routing cases and one workflow case | Python 3.10+, PyYAML |
| `python3 -m evals.validation` | Task inventory: unique IDs and prompts, valid fixture and assertion paths, at least 1 reference answer and 2 counterexamples per task, development/holdout splits that don't leak, and at least one task for every skill | Python, PyYAML, git |
| `python3 -m unittest evals.test_evals evals.test_contracts` | The harness itself: no answer leakage into prompts, trial isolation, correct reporting of blocked or failed runs | Python, PyYAML, git |
| `python3 -m evals.calibrate` | Every grader accepts every known-good answer and rejects every known-bad one for the reason it declares | Docker |

Setup and commands:

```bash
python3 -m pip install -r evals/requirements.txt

# Fast checks, no Docker needed
python3 scripts/validate_skills.py
python3 -m evals.validation
python3 -m unittest evals.test_evals evals.test_contracts

# Grader calibration: builds the sandboxed runtime image (Node, Chromium,
# Mermaid, Playwright) once, then runs every control against its grader
python3 -m evals.prepare
RUN_DOCKER_EVAL_TESTS=1 python3 -m unittest evals.test_evals evals.test_contracts
python3 -m evals.calibrate --jobs 3
python3 -m evals.calibrate --skill modern-css   # or one skill at a time
```

`evals.validation`, the unit tests and the runner read skills from the current
git commit, so they need at least one commit in the repository.

### Graders

Each task names a grader in `evals/tasks/<name>.json`:

| Grader | How it scores an answer |
|---|---|
| `contract` | JSON rules over the answer: required values, set equality, graph constraints |
| `slack-contract` | `contract` rules plus Slack payload invariants: block limits, surfaces, text objects, IDs, table shape, method fields |
| `fsd` | Feature-Sliced Design placement and import-graph checks |
| `javascript-runtime` | Runs the answer as a Node module against a private test in `evals/assertions/` |
| `css-runtime` | Loads the CSS into a fixture page in headless Chromium and measures computed styles and geometry across viewports, containers, directions, themes, focus and reduced motion |
| `mermaid-runtime` | Renders the diagram to SVG, then checks nodes, edges, messages and relationships |
| `postgres-runtime`, `drizzle-runtime`, `starlark-runtime` | Applies SQL to a disposable PostgreSQL, type-checks Drizzle schemas, or checks Bazel Starlark with Buildifier |

The runtime graders run inside the Docker sandbox with no network access. The
good and bad answers only test the graders; passing them doesn't show that a
model uses the skills well. The live model evaluation below measures that.

### Continuous integration

[`.github/workflows/validate.yml`](.github/workflows/validate.yml) runs on every
push to `main`, on every pull request, and by hand:

1. **validate**: the validator, the task inventory check and the harness unit
   tests.
2. **calibrate**: builds the Docker grading runtime and checks every good and
   bad answer. It runs only if `validate` passes. On failure, `calibration.json`
   is uploaded as a workflow artifact.

CI never calls a model and uses no secrets, so pull requests from forks are safe
to run.

### Live model evaluation (optional, local only)

`evals.runner` measures behavior against a real model, which CI doesn't do. It
runs two kinds of trials:

- **Routing:** the model sees only skill names and descriptions and chooses
  what to load.
- **Artifacts:** the model gets the skill, or no skill as a baseline, and a
  task. The grader then scores the answer.

It uses the free tier of Google's Gemini API:

```bash
export GEMINI_API_KEY=...          # key from a Google AI Studio project with billing disabled
export GEMINI_FREE_TIER=true
python3 -m evals.runner --dry-run                    # show the plan; no calls
python3 -m evals.runner --profile smoke --no-local-config --output evals/results/smoke
python3 -m evals.runner --profile coverage --no-local-config --output evals/results/coverage
python3 -m evals.runner --profile full --skill modern-css --suite task --repeats 3 \
  --no-local-config --output evals/results/css
```

Profiles are defined in [`evals/profiles.json`](evals/profiles.json):

- `smoke`: a few routing prompts and tasks, as a quick check
- `coverage`: one task per skill, with and without the skill
- `full`: everything

If you hit the quota, rerun the same command with `--resume`. To look up the key
through `gcloud` instead of an environment variable, and to check that billing
is off, copy `evals/local.example.json` to `evals/local.json` (it's gitignored)
and leave out `--no-local-config`. Results go to the gitignored `evals/results/`
folder.

## Adding a new skill

CI rejects a skill that has no eval coverage. For `skills/my-skill/`:

1. **`skills/my-skill/SKILL.md`**: frontmatter with `name: my-skill`, matching
   the folder name in lowercase kebab-case, and a one-line `description` of at
   most 1024 characters. The description should say what the skill is for and
   what it's not for. Link every file in `references/` or `scripts/` from
   `SKILL.md`, directly or through another reference.
2. **`evals/routing.json`**: add cases with `"owner": "my-skill"` covering at
   least the kinds `direct`, `indirect`, `negative`, `incomplete` and
   `boundary`. Each case needs a unique `id`, a `prompt`, `expected_skills`, a
   `rationale`, a `split` (`development` or `holdout`) and a `group`.
3. **`evals/workflows.json`**: add one `{ "skill": "my-skill", "prompt": ... }`.
4. **`evals/tasks/my-skill.json`**: add at least one task. Put its inputs in
   `evals/fixtures/my-skill/`. Give it at least one good answer and two bad
   answers in `evals/reference_outputs/my-skill/`, and list for each bad answer
   the assertion IDs it should fail. Copy an existing task file as a starting
   point: `contract` graders are the simplest (JSON rules over the answer);
   `javascript-runtime`, `css-runtime` and `mermaid-runtime` execute the answer in
   the sandbox. See [Graders](#graders) for the full list.
5. Run the fast checks and `python3 -m evals.calibrate --skill my-skill`.

## Credits

Some skills and tooling here are adapted from other open-source repositories:

- [ccheney/robust-skills](https://github.com/ccheney/robust-skills) (MIT):
  `feature-slicing`, `mermaid-diagrams`, `modern-css`, `slack-block-kit`,
  `slack-mrkdwn`, the skill validator and the evaluation harness.
- [coleam00/skills](https://github.com/coleam00/skills) (MIT): `piv-commit`,
  `piv-create-pr`, `piv-fix-review-findings`.

See [LICENSE](LICENSE).
